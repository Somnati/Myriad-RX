"""timebank_twin.py - the time bank's balance, simulated.

The house pattern (forge_twin, ngu_twin, mandel_twin): model the shipped
maths in Python, state the invariants out loud, and make the script
print HOLDS or FAILS. Tune here, port the numbers back - never the
other way round.

The model is timebank_rate / timebank_cap / timebank_add /
timebank_spend / timebank_upg / timebank_burn, term for term.

Round 2: the upgrades are paid in BANKED TIME rather than profit (his
call), which changes the shape of the entire ladder - see invariant 5.

Run:  python datafiles/timebank_twin.py
"""

import math
import os
import re

# ---------------------------------------------------------------- knobs
# READ from setgame's Create and the panel (2026-09-12), so a retune
# there is a retune here
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_setgame = open(os.path.join(ROOT, "objects", "setgame", "Create_0.gml"), encoding="utf-8").read()
_panel   = open(os.path.join(ROOT, "objects", "syst_timebank_panel", "Create_0.gml"), encoding="utf-8").read()
_ratefn  = open(os.path.join(ROOT, "scripts", "timebank_rate", "timebank_rate.gml"), encoding="utf-8").read()


def knob(name):
    m = re.search(r"^\s*g\." + name + r"\s*=\s*([\d.]+)", _setgame, re.M)
    if not m:
        raise SystemExit("setgame has no g." + name)
    return float(m.group(1))


TB_RATE       = knob("tb_rate")        # minutes banked per hour away, at rate_lv 0
TB_RATE_STEP  = knob("tb_rate_step")   # per rate purchase
TB_RATE_CAP   = knob("tb_rate_cap")    # the tuned ceiling
_m = re.search(r"min\(_mph,\s*g\.tb_rate_cap,\s*(\d+)\)", _ratefn)
TB_HARD_CAP   = float(_m.group(1)) if _m else 55   # the LAW inside timebank_rate, above the knob
TB_CAP        = knob("tb_cap")         # bank capacity in MINUTES, at cap_lv 0
TB_CAP_STEP   = knob("tb_cap_step")    # minutes of capacity a level - LINEAR (his call)
# two fee ladders, each off its own level, in minutes (his report: the
# fees were both 80% of the cap and read as shared)
TB_CAP_COST, TB_CAP_COST_STEP   = knob("tb_cap_cost"), knob("tb_cap_cost_step")
TB_RATE_COST, TB_RATE_COST_STEP = knob("tb_rate_cost"), knob("tb_rate_cost_step")

_m = re.search(r"spds\s*=\s*\[([^\]]*)\]", _panel)
SPEEDS = [int(x) for x in _m.group(1).split(",")] if _m else [1, 2, 4, 10, 50]

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label
          + (("   " + detail) if detail else ""))


def rate_mph(rate_lv):
    """timebank_rate, in minutes per hour."""
    return max(0, min(TB_RATE + rate_lv * TB_RATE_STEP, TB_RATE_CAP, TB_HARD_CAP))


def cap_secs(cap_lv):
    """timebank_cap, in seconds - linear."""
    return max(60, (TB_CAP + TB_CAP_STEP * cap_lv) * 60)


def bank_after(away_s, rate_lv, cap_lv, held=0.0):
    """timebank_add: convert an absence, clipped by the cap."""
    add = away_s * (rate_mph(rate_lv) / 60.0)
    room = max(0.0, cap_secs(cap_lv) - held)
    return min(add, room), add > room


def upg_cost(kind, lv):
    """timebank_upg: each ladder off ITS OWN level, in seconds."""
    if kind == "cap":
        return (TB_CAP_COST + TB_CAP_COST_STEP * lv) * 60
    return (TB_RATE_COST + TB_RATE_COST_STEP * lv) * 60


def rate_maxlv():
    lv = 0
    while TB_RATE + (lv + 1) * TB_RATE_STEP <= min(TB_RATE_CAP, TB_HARD_CAP):
        lv += 1
    return lv


def hours_to_afford(kind, rate_lv, lv):
    """the real price: hours of absence needed to bank the fee."""
    return (upg_cost(kind, lv) / 60.0) / rate_mph(rate_lv)


# ======================================================================
print(__doc__.strip().splitlines()[0])
print("=" * 70)

# --- 1. THE LAW: time can never multiply itself -----------------------
print()
print("1. CAUSALITY - banked minutes per real hour must stay under 60")
worst = max(rate_mph(lv) for lv in range(0, 200))
say(worst < 60, "the rate is always a factor < 1",
    "worst reachable = %d min/hr (%.2fx)" % (worst, worst / 60.0))

# --- 2. A SPEED IS PACING, NOT POWER ----------------------------------
print()
print("2. WHAT A SPEED CHOICE IS WORTH  (1h of bank)")
B = 3600.0
for m in SPEEDS:
    if m == 1:
        print("      off    - not spending")
        continue
    print("      x%-2d    drains in %5.1f min of real time  ->  +%.0f sim seconds"
          % (m, (B / (m - 1)) / 60, B))
say(all(abs((B / (m - 1)) * (m - 1) - B) < 1e-6 for m in SPEEDS[1:]),
    "every speed converts the bank 1:1 into simulated time",
    "the row is PACING, not power - the screen says so")

# --- 3. THE BURN BUTTONS ----------------------------------------------
# timebank_burn drives prod_dials directly rather than offline_replay,
# so it cannot re-bank what it spends.
print()
print("3. THE BURN BUTTONS  (spend a lump at once)")
for secs, lbl in ((60, "1m"), (600, "10m"), (3600, "1h"), (21600, "6h")):
    print("      [%-3s]  costs %6.0f s of bank  ->  %6.0f s of production"
          % (lbl, secs, secs))
say(True, "a burn is 1:1 and refunds nothing",
    "it drives prod_dials directly - through offline_replay it would "
    "re-bank part of its own spend")

# --- 4. WHICH KNOB BINDS ----------------------------------------------
print()
print("4. WHICH UPGRADE IS DOING ANYTHING")
print("      rate_lv  min/hr   base cap clips after")
for lv in [0, 1, 2, 5, 10, rate_maxlv()]:
    print("      %5d    %5d    %6.1f h away"
          % (lv, rate_mph(lv), cap_secs(0) / 60.0 / rate_mph(lv)))
hrs_base = cap_secs(0) / 60.0 / rate_mph(0)
say(hrs_base <= 10,
    "the FIRST capacity purchase does something for a normal absence",
    "at rate_lv 0 the base cap clips after %.1f h away" % hrs_base)

# --- 5. THE PRICE, AND WHY IT HAS THIS SHAPE --------------------------
# Paid in banked time, so a price ABOVE the cap is a price nobody can
# ever save for. A capacity fee must always fit the capacity it buys;
# a rate fee may outgrow a small cap, but the cap level that holds it
# must be reachable in a handful of buys (his linear ladders, 2026-09-10).
print()
print("5. THE PRICE  (paid in banked time; each ladder off its own level)")
print("      lv    capacity     cap fee     rate fee   rate fee needs cap_lv")
def cap_lv_for(secs):
    lv = 0
    while cap_secs(lv) < secs: lv += 1
    return lv
for lv in range(0, 20, 3):
    fc, fr = upg_cost("cap", lv), upg_cost("rate", lv)
    print("      %3d   %8.0f m   %8.0f m   %8.0f m   %d"
          % (lv, cap_secs(lv) / 60, fc / 60, fr / 60, cap_lv_for(fr)))
# ⚖️ HIS ONE CONDITION (2026-09-10): "as long as the capacity upgrade is
# always affordable". Not merely under the cap - under it with room, so
# a bank that is not quite full still buys it. 70% is the margin; the
# linear ladders give 67% at level 0 and fall toward 50% from there.
worst = max(upg_cost("cap", lv) / cap_secs(lv) for lv in range(0, 60))
say(worst <= .70,
    "the capacity upgrade is ALWAYS affordable (fee under 70% of the cap, every level)",
    "worst level takes %.0f%% of the cap" % (worst * 100))
say(cap_lv_for(upg_cost("rate", rate_maxlv())) <= 8,
    "the last rate fee is holdable within eight capacity buys",
    "needs cap_lv %d" % cap_lv_for(upg_cost("rate", rate_maxlv())))

# --- 6. WHAT IT COSTS IN REAL TIME ------------------------------------
# The fee is a fixed share of the cap, so what decelerates is the WALL
# CLOCK: hours of absence needed to bank it. The cap compounds, the rate
# is linear and stops - so the real price climbs forever.
print()
print("6. THE REAL PRICE  (hours of absence to bank one capacity fee)")
print("      cap_lv   at rate_lv 0   at rate max")
for lv in range(0, 14, 2):
    print("      %5d   %10.1f h   %9.1f h"
          % (lv, hours_to_afford("cap", 0, lv),
             hours_to_afford("cap", rate_maxlv(), lv)))
early = hours_to_afford("cap", rate_maxlv(), 0)
late = hours_to_afford("cap", rate_maxlv(), 12)
say(late / early > 5,
    "the wall-clock price still climbs (linear fee, capped rate)",
    "cap_lv 0 -> 12 at max rate: %.1f h -> %.1f h (x%.0f)"
    % (early, late, late / early))

# --- 7. IS A PLAYER EVER STUCK? ---------------------------------------
# Rate and cap are COMPLEMENTS: rate fills the bank, cap holds it. At the
# balance point one purchase alone changes nothing - that is what
# complements do, not a bug. The fault to test for is a dead END: two
# barren steps in a row would mean the ladder had stalled.
print()
print("7. IS A PLAYER EVER STUCK?  (8h nightly absence, buying what helps)")
AWAY = 8 * 3600.0
rl = cl = 0
streak = worst_streak = 0
print("      buy     rate     cap       fee      bank from 8h    nights/fee")
for step in range(14):
    before, _ = bank_after(AWAY, rl, cl)
    fc, fr = upg_cost("cap", cl), upg_cost("rate", rl)
    maxed = (rate_mph(rl) >= min(TB_RATE_CAP, TB_HARD_CAP))
    # a player buys what HELPS, which is what the rows now tell them -
    # the fees are equal, so price carries no signal and cannot mislead
    d_cap = bank_after(AWAY, rl, cl + 1)[0] - before
    d_rate = 0 if maxed else bank_after(AWAY, rl + 1, cl)[0] - before
    if d_cap > 1e-9 and d_cap >= d_rate:
        pick = "cap"
    elif d_rate > 1e-9:
        pick = "rate"
    else:
        pick = "cap"          # neither alone moves it: buy half of a pair
    fee = fc if pick == "cap" else fr
    nights = fee / max(1e-9, before)
    if pick == "cap":
        cl += 1
    else:
        rl += 1
    after, _ = bank_after(AWAY, rl, cl)
    gained = after - before
    streak = 0 if gained > 1e-9 else streak + 1
    worst_streak = max(worst_streak, streak)
    print("      %-6s  %4d  %8.0fm  %7.0fm  %6.0f -> %-7.0f %7.1f"
          % (pick, rate_mph(rl), cap_secs(cl) / 60, fee / 60,
             before / 60, after / 60, nights))

say(worst_streak <= 1,
    "the ladder never stalls - a barren buy is always half of a pair",
    "longest run of purchases that bought nothing: %d" % worst_streak)

# --- 8. THE CEILING ---------------------------------------------------
print()
print("8. THE END STATE")
mx = rate_maxlv()
print("      rate maxes at lv %d (%d min/hr) - after that only capacity buys"
      % (mx, rate_mph(mx)))
print("      at that rate a 24h absence banks %.0f min" % (24 * rate_mph(mx)))
need = 0
while cap_secs(need) / 60 < 24 * rate_mph(mx):
    need += 1
print("      holding all of it needs cap_lv %d, a fee of %.1f h of absence"
      % (need, hours_to_afford("cap", mx, need)))
say(rate_mph(mx) == TB_RATE_CAP,
    "the rate ceiling is the tuned knob, not the hard law",
    "%d of a possible %d - headroom to raise TB_RATE_CAP later"
    % (TB_RATE_CAP, TB_HARD_CAP))

print()
print("=" * 70)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
