"""battery_twin.py - the offline battery, simulated.

The house pattern (timebank_twin, tiles_twin): model the shipped maths
in Python, state the invariants out loud, print HOLDS or FAILS. Tune
here, port the numbers back - never the other way round.

THE NUMBERS ARE READ FROM main_macros.gml (the BAT_* block), so this
twin cannot drift from the game: change a macro, rerun, read the
verdict. The laws are battery_cap / battery_rate / battery_draw /
battery_lasts / battery_upg / offline_replay's budget, term for term.

Run:  python datafiles/battery_twin.py
"""

import math
import os
import re

# ---------------------------------------------------------------- knobs
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"),
            encoding="utf-8").read()


def macro(name):
    m = re.search(r"^#macro\s+" + name + r"\s+([-\d.]+)", _src, re.M)
    if not m:
        raise SystemExit("main_macros has no #macro " + name)
    return float(m.group(1))


BAT_CAP0      = macro("BAT_CAP0")
BAT_FILL0     = macro("BAT_FILL0")
BAT_CAP_STEP  = macro("BAT_CAP_STEP")
BAT_RATE_STEP = macro("BAT_RATE_STEP")
BAT_COST0     = macro("BAT_COST0")
BAT_COST_MULT = macro("BAT_COST_MULT")
BAT_CRANK_REV = macro("BAT_CRANK_REV")
BAT_W_RUN     = macro("BAT_W_RUN")
BAT_W_FAB     = macro("BAT_W_FAB")
BAT_W_MERGE   = macro("BAT_W_MERGE")

CREDITS_PER_HOUR = 12   # setgame: g.credit_refill (the dropper's ceiling on income)

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label
          + (("   " + detail) if detail else ""))


def hms(s):
    s = int(round(s))
    h, m, sec = s // 3600, (s % 3600) // 60, s % 60
    if h: return f"{h}h {m:02d}m"
    if m: return f"{m}m {sec:02d}s"
    return f"{sec}s"


# ---------------------------------------------------------------- laws
def cap(cap_lv):
    """battery_cap"""
    return BAT_CAP0 * (1 + BAT_CAP_STEP * cap_lv)


def rate(rate_lv):
    """battery_rate: charge per real second, NOT scaled by the cap held"""
    return (BAT_CAP0 / BAT_FILL0) * (1 + BAT_RATE_STEP * rate_lv)


def fill_time(cap_lv, rate_lv):
    return cap(cap_lv) / rate(rate_lv)


def draw(r_run, r_fab, r_merge, run_on=True, fab_on=True, merge_on=True):
    """battery_draw: weight x (rate/100)^2 over the sum of weights"""
    tot = BAT_W_RUN + BAT_W_FAB + BAT_W_MERGE
    d = 0.0
    if run_on:   d += BAT_W_RUN   * (r_run / 100.0) ** 2
    if fab_on:   d += BAT_W_FAB   * (r_fab / 100.0) ** 2
    if merge_on: d += BAT_W_MERGE * (r_merge / 100.0) ** 2
    return d / tot


def lasts(charge, d):
    return float("inf") if d <= 0 else charge / d


def absence(charge, away_s, r_run, r_fab, r_merge):
    """offline_replay: the machines run min(away, charge/draw) seconds
    at their offline rates, then stop. Returns (seconds covered, charge
    left, machine-seconds of output per machine)."""
    d = draw(r_run, r_fab, r_merge)
    cov = away_s if d <= 0 else min(away_s, charge / d)
    left = max(0.0, charge - cov * d)
    out = {"run": cov * r_run / 100, "fab": cov * r_fab / 100, "merge": cov * r_merge / 100}
    return cov, left, out


def ladder_cost(lv):
    """battery_upg: BAT_COST0 x MULT^lv credits, ceil"""
    return math.ceil(BAT_COST0 * BAT_COST_MULT ** lv)


# ---------------------------------------------------------------- 1. the two ladders
print("\n== 1. the ladders (his law: equal levels fill alike; a cap ahead of its rate takes longer) ==")
print(f"  base: {hms(BAT_CAP0)} of charge, full in {hms(BAT_FILL0)} at 0/0 "
      f"({rate(0):.0f} charge-seconds per real second)")
all_equal = all(abs(fill_time(n, n) - BAT_FILL0) < 1e-6 for n in range(0, 11))
say(all_equal, "lv n / lv n fills in BAT_FILL0 for n = 0..10")
say(fill_time(10, 0) > fill_time(0, 0) * 3,
    "cap lv10 on rate lv0 takes far longer than 0/0",
    f"{hms(fill_time(10, 0))} vs {hms(fill_time(0, 0))}")
say(fill_time(0, 10) < fill_time(0, 0),
    "rate lv10 on cap lv0 fills faster than 0/0", f"{hms(fill_time(0, 10))}")
print("  cap lv :", "  ".join(f"{n}={hms(cap(n))}" for n in (0, 1, 2, 5, 10)))
print("  cost   :", "  ".join(f"lv{n}={ladder_cost(n)}cr" for n in (0, 1, 2, 5, 10)))
cum = sum(ladder_cost(n) for n in range(10))
print(f"  ten levels of ONE ladder cost {cum} credits; both ladders {2 * cum};"
      f" at {CREDITS_PER_HOUR}/h income that is {hms(2 * cum / CREDITS_PER_HOUR * 3600)} of play")
print(f"  (his numbers, 2026-09-11 - the ladders are meant to be a long sink; the first three"
      f" rungs are {ladder_cost(0)} / {ladder_cost(1)} / {ladder_cost(2)}, at {CREDITS_PER_HOUR}/h"
      f" that is {hms(ladder_cost(0) / CREDITS_PER_HOUR * 3600)} of dropper income for the first)")
say(ladder_cost(0) >= 100, "the first level costs at least 100 credits (his floor)")

# ---------------------------------------------------------------- 2. the draw law
print("\n== 2. the draw law (weight x rate^2, normalised) ==")
say(abs(draw(100, 100, 100) - 1.0) < 1e-9, "all three at 100% draw exactly 1 - the charge IS hours away")
d_nomerge = draw(100, 100, 100, merge_on=False)
say(d_nomerge < 1, "merger off draws less", f"x{d_nomerge:.2f}  ->  lasts x{1 / d_nomerge:.2f}")
d_half = draw(50, 50, 50)
say(abs(d_half - .25) < 1e-9, "everything at 50% draws a quarter", f"x{d_half:.2f}  ->  lasts x{1 / d_half:.0f}")
say(draw(5, 5, 5) < .01, "everything at 5% draws under 1%", f"x{draw(5, 5, 5):.4f}")

# ---------------------------------------------------------------- 3. what an absence yields
print("\n== 3. an absence, base capacity, from full: machine-seconds of output ==")
print("  the decision the panel's sliders are for. 'run' is the dials' output share;"
      " at the same setting every machine scales alike")
print(f"  {'away':>6} | {'rate':>5} | {'covered':>9} | {'output (run)':>12} | {'charge left':>11}")
best = {}
for away_h in (1, 3, 8, 24):
    for r in (100, 75, 50, 25, 10):
        cov, left, out = absence(BAT_CAP0, away_h * 3600, r, r, r)
        print(f"  {away_h:>4}h  | {r:>4}% | {hms(cov):>9} | {hms(out['run']):>12} | {hms(left):>11}")
        if away_h not in best or out["run"] > best[away_h][1]:
            best[away_h] = (r, out["run"])
    print("  " + "-" * 60)
print("  best rate per absence:", "  ".join(f"{h}h -> {best[h][0]}%" for h in best))
say(best[1][0] == 100, "a short absence wants full speed")
say(best[24][0] < 100, "a long absence wants the sliders DOWN - the square law pays",
    f"24h best at {best[24][0]}%: {hms(best[24][1])} of output vs {hms(absence(BAT_CAP0, 86400, 100, 100, 100)[2]['run'])} at 100%")
# the invariant behind that: over an absence longer than the charge covers,
# output at rate r is charge/draw x r = charge x r / (r^2/...) ~ 1/r - MORE at lower r
say(absence(BAT_CAP0, 86400, 50, 50, 50)[2]["run"] > absence(BAT_CAP0, 86400, 100, 100, 100)[2]["run"],
    "over a long absence 50% out-produces 100%")

# ---------------------------------------------------------------- 4. the hard stop and the top-up loop
print("\n== 4. the check-in loop ==")
away = 8 * 3600
cov, left, out = absence(BAT_CAP0, away, 100, 100, 100)
say(cov < away, "8h away at full speed runs dry", f"ran {hms(cov)}, then stopped for {hms(away - cov)}")
refill = fill_time(0, 0)
print(f"  back for {hms(refill)} refills it from empty - so a player who checks in every"
      f" {hms(BAT_CAP0)} keeps the machines running continuously")
crank_rev_per_full = BAT_CRANK_REV
crank_at_2rps = BAT_CAP0 / (2 * BAT_CAP0 / BAT_CRANK_REV)
print(f"  the crank: {int(crank_rev_per_full)} turns from empty; at 2 turns a second that is"
      f" {hms(crank_at_2rps)} - vs {hms(refill)} passive")
say(crank_at_2rps < refill, "cranking hard beats the passive charge", f"x{refill / crank_at_2rps:.1f}")

# ---------------------------------------------------------------- 5. the machines' online/offline story
print("\n== 5. offline == online ==")
print("  the replay runs the SAME prod_dials / tiles_fastforward on min(away, charge/draw)"
      " seconds at the battery's rates; the time bank banks the raw absence on top."
      " nothing here is a second formula - the twin only checks the budget arithmetic.")
cov1, _, _ = absence(BAT_CAP0, 2 * 3600, 100, 100, 100)
say(abs(cov1 - 2 * 3600) < 1e-6, "an absence inside the charge is covered whole")
cov2, left2, _ = absence(BAT_CAP0, 2 * 3600, 100, 100, 100)
say(abs((BAT_CAP0 - left2) - 2 * 3600) < 1e-6, "...and costs exactly its length in charge at draw 1")

# ---------------------------------------------------------------- 6. the optimiser
print("\n== 6. the optimiser (battery_optimise: the rates that make the most of the charge over EXACTLY the absence) ==")


def optimise(charge, away_s, r_run, r_fab, r_merge):
    """bisect the scale s so draw(s x rates) x away == charge, every machine clamped at 100"""
    rates = (r_run, r_fab, r_merge)
    smax = max(1.0, max(100.0 / max(5, r) for r in rates))
    target = charge / away_s
    def d(sc): return draw(*[min(100.0, r * sc) for r in rates])   # the search's own clamp
    if d(smax) <= target: return smax
    lo, hi = 0.0, smax
    for _ in range(60):
        mid = (lo + hi) / 2
        if d(mid) > target: hi = mid
        else: lo = mid
    return lo


print(f"  {'away':>6} | {'left at':>7} | {'output as left':>14} | {'optimised':>9} | {'output opt':>10} | {'sqrt(C x A)':>11}")
opt_ok = True
for away_h in (0.17, 1, 3, 8, 24, 168):
    for r in (100, 30):
        s_ = optimise(BAT_CAP0, away_h * 3600, r, r, r)
        ro = min(100.0, max(5.0, r * s_))     # battery_optimise's result clamp(., 5, 100)
        _, _, o0 = absence(BAT_CAP0, away_h * 3600, r, r, r)
        _, _, o1 = absence(BAT_CAP0, away_h * 3600, ro, ro, ro)
        ceil_ = math.sqrt(BAT_CAP0 * away_h * 3600)
        opt_ok = opt_ok and (o1["run"] + 1e-6 >= o0["run"]) and (o1["run"] <= min(away_h * 3600, ceil_) + 1)
        print(f"  {away_h:>5.2g}h | {r:>6}% | {hms(o0['run']):>14} | {ro:>8.0f}% | {hms(o1['run']):>10} | {hms(ceil_):>11}")
say(opt_ok, "optimised output is never below the player's setting and never above sqrt(C x A)")
say(optimise(BAT_CAP0, 600, 30, 30, 30) > 1, "10 minutes away with the rates at 30%: it scales UP",
    f"x{optimise(BAT_CAP0, 600, 30, 30, 30):.2f}")
say(optimise(BAT_CAP0, 86400, 100, 100, 100) < 1, "a day away at 100%: it scales DOWN",
    f"x{optimise(BAT_CAP0, 86400, 100, 100, 100):.2f}")

print("\n" + ("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port"))
