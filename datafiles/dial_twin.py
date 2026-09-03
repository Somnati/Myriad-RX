"""dial_twin.py - the Myriad RX dial economy, simulated in plain floats.

The house python-twin method: prove the curves behave BEFORE they are
tested in the engine, and keep a place to tune them that is faster than
a build. Every formula here mirrors one GML script one-for-one:

    lvdiv()  <- dial_lvdiv        gps()  <- dial_gps
    cost()   <- dial_cost         gpc()  <- update_dial
    tap()    <- update_click

All of it is Myriad DE's law (get_gps / get_cost_v3 / get_lvdiv /
update_auto / update_clicker), so this file doubles as the readable
statement of what those shipped formulas actually do.

Run:  python dial_twin.py
"""
import math


N_DIALS = 13


# ---------------------------------------------------------------- laws
def cycle_seconds(tier):
    """dial_config: 3s doubling per dial, x2 past h, x4 past k."""
    mm = 1
    if tier >= 8:
        mm = 2
    if tier >= 11:
        mm = 4
    return 3 * (2 ** tier) * mm


def lvdiv(tier):
    """dial_lvdiv: the free-level head start that IS the tier ladder."""
    mn = 0 + (60 - 0) * min(max(tier / 5, 0), 1)
    mx = 160 + (1000 - 160) * (tier / 1000000)
    t = min(max((tier - 5) / 23, 0), 1)
    d = int(mn + (mx - mn) * t)
    d *= tier
    d += 100 * (tier // 20)
    d -= 20 * (tier // 27)
    return d


def gps(tier, level):
    """dial_gps: exponential (.0255 decades/level) + additive early lane."""
    if level <= 0:
        return 0.0
    lv = level + lvdiv(tier)
    gth = (1.7 / 100) * 1.5
    val = 10 ** (0.1 + gth * (lv - 1))
    if val < 1e10 and lv > 1:      # the packed-exponent < 10 test
        val += lv - 1
    return val


def gpc(tier, level):
    """update_dial: per-cycle payout = base x cycle-seconds x level ramp."""
    if level <= 0:
        return 0.0
    md = min(max(level / 50, 0.1), 1)
    import math
    return math.ceil(gps(tier, level) * max(1, cycle_seconds(tier) * md))


def per_second(tier, level):
    """update_dial: gpc spread over the (autoeff-stretched) cycle."""
    if level <= 0:
        return 0.0
    return gpc(tier, level) / (cycle_seconds(tier) * 1.3)


MILESTONE_COST_MULT = 10          # setgame: g.milestone_cost_mult
MILESTONES = [(25, "speed", 2), (50, "profit", 2), (75, "profit", 2), (100, "speed", 2)]

def cost(tier, frm, to, raw=False):
    """dial_cost: geometric series solved by subtraction (.05 dec/level).
    Price POINTS are rounded to whole units before subtracting, so a chain
    of singles telescopes to exactly the bulk price (the bulk law). Rungs
    inside (frm, to] add (MILESTONE_COST_MULT - 1) x that level's own raw
    price, rounded - the milestone premium."""
    if to <= frm:
        return 0
    lvd = lvdiv(tier)
    pp = 4 if frm > 0 else 3
    base = max(2, pp - 1)
    gth = 0.05 * (1 + 999 * tier / 1e6)
    a = base + gth * (frm + lvd) + gth * max(0, frm - 700)
    b = base + gth * (to + lvd) + gth * max(0, to - 700)
    pa = 10 ** pp if frm <= 0 else 10 ** pp + 10 ** a
    pb = 10 ** pp + 10 ** b
    c = max(1, math.ceil(pb) - math.ceil(pa))
    if frm <= 0 and tier == 0:
        c = 100
    if not raw and MILESTONE_COST_MULT > 1:
        for lv, _kind, _mult in MILESTONES:
            if frm < lv <= to:
                c += math.ceil(cost(tier, lv - 1, lv, True) * (MILESTONE_COST_MULT - 1))
    return c

def tap(all_level, all_gps):
    """update_click: 1 + every dial level, plus 1% of the fleet's rate."""
    v = 1 + all_level
    if all_gps >= 100:                     # DE's guard (packed exp > 2)
        v += all_gps * 0.01
    return v


# ----------------------------------------------------------------- sim
def simulate(minutes=180, taps_per_second=2.0, verbose=True):
    levels = [0] * N_DIALS
    profit = 0.0
    log = []

    for t in range(minutes * 60):
        all_level = sum(levels)
        rate = sum(per_second(i, levels[i]) for i in range(N_DIALS))
        profit += rate
        profit += tap(all_level, rate) * taps_per_second

        # greedy policy: always buy the cheapest level available, which
        # is the pressure the real player feels, not an optimal one
        while True:
            best, best_cost = -1, None
            for i in range(N_DIALS):
                if i > 0 and levels[i - 1] == 0:
                    break              # the ladder unlocks in order
                c = cost(i, levels[i], levels[i] + 1)
                if best_cost is None or c < best_cost:
                    best, best_cost = i, c
            if best < 0 or best_cost is None or profit < best_cost:
                break
            profit -= best_cost
            levels[best] += 1

        if t % 600 == 0:
            log.append((t, profit, rate, list(levels),
                        tap(sum(levels), rate)))

    if verbose:
        print(f"{'time':>7} {'profit':>12} {'rate/s':>12} {'per tap':>12}  levels")
        for t, p, r, lv, tp in log:
            owned = ",".join(str(x) for x in lv if x > 0)
            print(f"{t//60:>5}m {p:>12.3g} {r:>12.3g} {tp:>12.3g}  {owned}")
    return levels, profit


def checks():
    """The invariants worth failing loudly on."""
    ok = True

    # 1. DIAL A COSTS EXACTLY 100 - his rule, and DE's own special case
    #    in get_cost_v3. Not "about 100": the opening price is a fixed
    #    landmark, and at 1 profit per tap it is exactly 100 taps.
    first = cost(0, 0, 1)
    taps = first / tap(0, 0)
    print(f"dial a opening price: {first:.6g} ({taps:.0f} taps)", end="  ")
    if first == 100.0 and taps == 100.0:
        print("HOLDS")
    else:
        print("FAILS - must be exactly 100"); ok = False

    # 2. cost must outrun output per level, or one dial solves the game
    c_growth = 10 ** 0.05
    g_growth = 10 ** ((1.7 / 100) * 1.5)
    print(f"per-level: cost x{c_growth:.4f} vs output x{g_growth:.4f}", end="  ")
    if c_growth > g_growth:
        print("HOLDS")
    else:
        print("FAILS (levelling one dial would never decay)"); ok = False

    # 3. each new dial must beat the one below it at level 1
    print("tier ladder:", end=" ")
    bad = []
    for i in range(1, N_DIALS):
        if per_second(i, 1) <= per_second(i - 1, 1):
            bad.append(i)
    if not bad:
        print("HOLDS (every dial opens stronger than the last)")
    else:
        print(f"FAILS at {bad}"); ok = False

    # 4. the syphon must matter late without dominating early
    for rate in (10, 1e3, 1e9):
        share = (rate * 0.01) / tap(50, rate) if rate >= 100 else 0
        print(f"  syphon share of a tap at {rate:>7.0g}/s: {share:6.1%}")

    # 5. the sim must not stall
    lv, _ = simulate(180, verbose=False)
    print(f"3h greedy run reaches dials: {[i for i, x in enumerate(lv) if x > 0]}"
          f" top level {max(lv)}", end="  ")
    if sum(lv) > 50 and sum(1 for x in lv if x > 0) >= 3:
        print("HOLDS")
    else:
        print("FAILS (progression stalled)"); ok = False

    print("\nALL INVARIANTS HOLD" if ok else "\nSOMETHING FAILED")
    return ok


if __name__ == "__main__":
    checks()
    print()
    simulate(180)


def check_bulk():
    """THE BULK LAW: for every dial and every range, the sum of x1 buys
    equals the bulk price - through every milestone rung, premium included."""
    ok = True
    for tier in range(13):
        for frm in range(1, 130):
            for to in (frm + 1, frm + 10, frm + 25, frm + 100):
                singles = sum(cost(tier, l, l + 1) for l in range(frm, to))
                bulk = cost(tier, frm, to)
                if singles != bulk:
                    ok = False
                    print(f"  MISMATCH dial {tier} {frm}->{to}: singles {singles} bulk {bulk}")
    # the premium: the crossing level costs exactly MULT x its raw price
    for lv, _k, _m in MILESTONES:
        if cost(0, lv - 1, lv) != MILESTONE_COST_MULT * cost(0, lv - 1, lv, True):
            ok = False
            print(f"  PREMIUM WRONG at lv {lv}")
    print("bulk law: singles == bulk, premium == x%d:" % MILESTONE_COST_MULT, "HOLDS" if ok else "FAILS")
    return ok

if __name__ == "__main__":
    check_bulk()
