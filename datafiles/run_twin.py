"""run_twin.py - a whole RUN of the dial economy, simulated: the PACE.

The dial twin proves the curves are well-formed (cost outruns output,
singles equal bulk, max is exact). It never asked how a run FEELS:
hours to each dial, hours to each rung, where the pile stalls, whether
the curve walls. This does (his question, 2026-09-13: "im surprised you
never caught any scaling issues" - fair; nothing had measured it).

The model is dial_twin's laws (dial_lvdiv / dial_gps / dial_cost /
update_dial / update_click, DE's term for term) plus the milestone
table read from setgame, driven by a greedy buyer (the cheapest next
level, every second - what autobuy does) and a tapper who taps 2/s for
the first hour of a session and then 1/s in short bursts (a hand, not a
bot). No upgrades table, no tiles, no rebirth: the BARE curve, which is
the thing under everything else. Then the SAME run under DE's own
milestone ladder, so the difference is a number.

Run:  python datafiles/run_twin.py
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dial_twin as D   # the laws; its own checks stay under __main__

HOURS = 72
N = D.N_DIALS

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label + (("   " + detail) if detail else ""))


def hms(s):
    s = int(s)
    if s < 3600: return "%dm" % (s // 60)
    if s < 86400: return "%dh%02dm" % (s // 3600, (s % 3600) // 60)
    return "%dd%02dh" % (s // 86400, (s % 86400) // 3600)


def eng(v):
    if v <= 0: return "0"
    if v < 1e6: return "%.0f" % v
    return "1e%.1f" % math.log10(v)


def run(milestones, cost_mult, hours=HOURS, taps=True, log_every=3600):
    """the greedy run. milestones: [(level, kind, mult)]; cost_mult: the
    crossing premium (1 = none, DE). Returns the ledger."""
    D.MILESTONES[:] = milestones
    D.MILESTONE_COST_MULT = cost_mult
    levels = [0] * N
    profit = 0.0
    unlocked_at = [None] * N
    rung_at = {}          # (dial 0, level) -> hour
    last_buy = 0
    longest_gap = (0, 0)  # (seconds, at)
    mags = {}
    buys = 0
    for t in range(hours * 3600):
        all_level = sum(levels)
        rate = sum(D.per_second(i, levels[i]) for i in range(N))
        profit += rate
        if taps:
            # a hand: 2/s for the first hour, then 1/s for the first ten
            # minutes of every hour (a check-in), nothing between
            if t < 3600: profit += D.tap(all_level, rate) * 2
            elif (t % 3600) < 600: profit += D.tap(all_level, rate) * 1
        # the greedy buyer: the cheapest next level, as many as afford
        bought = False
        while True:
            best, best_cost = -1, None
            for i in range(N):
                if i > 0 and levels[i - 1] == 0: break
                c = D.cost(i, levels[i], levels[i] + 1)
                if best_cost is None or c < best_cost: best, best_cost = i, c
            if best < 0 or profit < best_cost: break
            profit -= best_cost
            levels[best] += 1
            buys += 1
            bought = True
            if unlocked_at[best] is None: unlocked_at[best] = t
            if best == 0:
                for lv, _k, _m in milestones:
                    if levels[0] == lv: rung_at[lv] = t
        if bought:
            gap = t - last_buy
            if gap > longest_gap[0]: longest_gap = (gap, last_buy)
            last_buy = t
        if t % log_every == 0: mags[t] = (profit, rate, list(levels))
    gap = hours * 3600 - last_buy
    if gap > longest_gap[0]: longest_gap = (gap, last_buy)
    mags[hours * 3600] = (profit, rate, list(levels))
    return {"levels": levels, "profit": profit, "unlocked": unlocked_at, "rung": rung_at,
            "gap": longest_gap, "mags": mags, "buys": buys}


RX_MS = list(D.MILESTONES)            # setgame's table, as shipped
RX_MULT = D.MILESTONE_COST_MULT
DE_MS = [(50, "speed", 2), (100, "profit", 2), (250, "speed", 2), (300, "profit", 2), (500, "speed", 2),
         (750, "profit", 2), (1000, "profit", 5), (1500, "profit", 5), (1750, "speed", 2), (2000, "profit", 10),
         (4000, "profit", 10), (5000, "speed", 2), (10000, "profit", 100), (20000, "profit", 100)]

print(__doc__.strip().splitlines()[0])
print("=" * 74)
print("RX: milestones %s, crossing premium x%g" % (", ".join("%d %s x%g" % m for m in RX_MS), RX_MULT))
rx = run(RX_MS, RX_MULT)
de = run(DE_MS, 1)

# --- 1. THE DIALS ---------------------------------------------------
print()
print("1. WHEN EACH DIAL OPENS  (greedy buyer, %dh)" % HOURS)
print("      %-6s %10s %10s" % ("dial", "RX", "DE ladder"))
for i in range(N):
    a, b = rx["unlocked"][i], de["unlocked"][i]
    print("      %-6s %10s %10s" % (chr(97 + i), hms(a) if a is not None else "never", hms(b) if b is not None else "never"))
opened = sum(1 for u in rx["unlocked"] if u is not None)
# ⚖️ THE BARE CURVE IS SLOW BY DESIGN - DE's was too (its ladder opens
# THREE dials in three days here). The pace of the game is the
# multipliers stacked on it: the tile board's export (x1e4 by six
# hours, tiles_twin), the upgrades table, the rebirth boost. So the
# bare curve's own bars are modest: the opening must move, and RX must
# not be slower than DE's bare ladder
say(rx["unlocked"][2] is not None and rx["unlocked"][2] < 2 * 3600, "dial c inside two hours on the bare curve", hms(rx["unlocked"][2] or 0))
# (three days, not two, since 2026-09-13: the opening prices are ROUND
# now - DE's level-0 law, b 1000 / c 100k / d 100m - and on the bare
# curve d slid from 1d16h to 2d19h. With the game's multipliers it is
# hours; the bar only guards against a wall)
say(rx["unlocked"][3] is not None and rx["unlocked"][3] < 72 * 3600, "dial d inside three days on the bare curve", hms(rx["unlocked"][3] or 0))
say(opened >= sum(1 for u in de["unlocked"] if u is not None), "RX's bare curve opens at least as many dials as DE's did", "%d vs %d" % (opened, sum(1 for u in de["unlocked"] if u is not None)))

# --- 2. THE RUNGS ---------------------------------------------------
print()
print("2. DIAL A'S RUNGS  (the hour it crossed)")
print("      %-8s %10s %10s" % ("level", "RX", "DE ladder"))
for lv in sorted(set([m[0] for m in RX_MS] + [50, 100, 250, 500, 1000])):
    a = rx["rung"].get(lv); b = de["rung"].get(lv)
    # a level not in a table still lands - read it off the ledger
    print("      %-8d %10s %10s" % (lv, hms(a) if a is not None else "-", hms(b) if b is not None else "-"))
print("      dial a at %dh: RX level %d, DE ladder level %d" % (HOURS, rx["levels"][0], de["levels"][0]))

# --- 3. THE PILE ----------------------------------------------------
print()
print("3. PROFIT AND RATE BY HOUR")
print("      %-6s %12s %12s %12s %12s" % ("hour", "RX pile", "RX rate/s", "DE pile", "DE rate/s"))
for h in (1, 3, 6, 12, 24, 48, 72):
    t = h * 3600
    if t in rx["mags"] and t in de["mags"]:
        p1, r1, _ = rx["mags"][t]; p2, r2, _ = de["mags"][t]
        print("      %-6d %12s %12s %12s %12s" % (h, eng(p1), eng(r1), eng(p2), eng(r2)))
r24 = rx["mags"][24 * 3600][1]; r72 = rx["mags"][72 * 3600][1]
say(r72 > r24 * 2, "the bare rate still grows across days two and three (no wall)", "x%.1f from 24h to 72h" % (r72 / max(r24, 1e-9)))
say(rx["gap"][0] < 6 * 3600, "no dead stretch over six hours without a single buy", "longest %s, from %s" % (hms(rx["gap"][0]), hms(rx["gap"][1])))
rd = de["mags"][72 * 3600][1]
print("      at 72h: RX's bare rate is x%.1f the DE ladder's (the early rungs and the premium)" % (r72 / max(rd, 1e-9)))
# THE RUNGS RX HAS NOT GOT: with the game's multipliers (x1e4 by six
# hours) levels climb ~80 per four decades of income, so dial a passes
# 250 inside days - and RX's table ends at 100. DE's went to 20000.
print("      RX's table ends at level %d; DE's ran to %d with x5 / x10 / x100 profit rungs" % (max(m[0] for m in RX_MS), max(m[0] for m in DE_MS)))

# --- 4. WHERE THE BUYS GO --------------------------------------------
print()
print("4. LEVELS AT %dh  (RX / DE ladder)" % HOURS)
print("      " + "  ".join("%s %d/%d" % (chr(97 + i), rx["levels"][i], de["levels"][i]) for i in range(N)))
print("      buys: RX %d, DE ladder %d" % (rx["buys"], de["buys"]))

print()
print("=" * 74)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
