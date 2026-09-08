"""timebank_twin.py - the time bank's balance, simulated.

The house pattern (forge_twin, ngu_twin, mandel_twin): model the shipped
maths in Python, state the invariants out loud, and make the script
print HOLDS or FAILS. Tune here, port the numbers back - never the
other way round.

The model is timebank_rate / timebank_cap / timebank_add /
timebank_spend / timebank_upg, term for term.

Run:  python datafiles/timebank_twin.py
"""

import math

# ---------------------------------------------------------------- knobs
# setgame's Create, verbatim
TB_RATE       = 5     # minutes banked per hour away, at rate_lv 0
TB_RATE_STEP  = 2     # per rate purchase
TB_RATE_CAP   = 45    # the tuned ceiling
TB_HARD_CAP   = 55    # the LAW inside timebank_rate, above the knob
TB_CAP        = 30    # bank capacity in minutes, at cap_lv 0
TB_CAP_STEP   = 30    # per capacity purchase
TB_COST_MULT  = 350   # percent per level
CAP_BASE      = 50000
RATE_BASE     = 250000

SPEEDS = [1, 2, 4, 6, 8, 10]

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
    """timebank_cap, in seconds."""
    return max(60, (TB_CAP + cap_lv * TB_CAP_STEP) * 60)


def bank_after(away_s, rate_lv, cap_lv, held=0.0):
    """timebank_add: convert an absence, clipped by the cap."""
    add = away_s * (rate_mph(rate_lv) / 60.0)
    room = max(0.0, cap_secs(cap_lv) - held)
    return min(add, room), add > room


def upg_cost(kind, level):
    """timebank_upg's closed form."""
    base = CAP_BASE if kind == "cap" else RATE_BASE
    return base * (TB_COST_MULT / 100.0) ** level


def rate_maxlv():
    lv = 0
    while TB_RATE + (lv + 1) * TB_RATE_STEP <= min(TB_RATE_CAP, TB_HARD_CAP):
        lv += 1
    return lv


# ======================================================================
print(__doc__.strip().splitlines()[0])
print("=" * 68)

# --- 1. THE LAW: time can never multiply itself -----------------------
print()
print("1. CAUSALITY - banked minutes per real hour must stay under 60")
worst = max(rate_mph(lv) for lv in range(0, 200))
say(worst < 60, "the rate is always a factor < 1",
    "worst reachable = %d min/hr (%.2fx)" % (worst, worst / 60.0))

# --- 2. THE MULTIPLIER IS PACING, NOT POWER ---------------------------
# timebank_spend: at m, one real second simulates m and consumes (m-1).
# So B banked seconds always buy exactly B extra simulated seconds,
# whatever m is. m only decides how fast you spend them.
print()
print("2. WHAT A SPEED CHOICE IS WORTH")
B = 3600.0
for m in SPEEDS:
    if m == 1:
        print("      x1     - not spending")
        continue
    real = B / (m - 1)
    extra = real * (m - 1)
    print("      x%-2d    burns 1h of bank in %5.1f min of real time"
          "  ->  +%.0f sim seconds" % (m, real / 60, extra))
say(all(abs((B / (m - 1)) * (m - 1) - B) < 1e-6 for m in SPEEDS[1:]),
    "every speed converts the bank 1:1 into simulated time",
    "the speed row is PACING, not power - worth saying on the screen")

# --- 3. WHICH KNOB ACTUALLY BINDS -------------------------------------
print()
print("3. WHICH UPGRADE IS DOING ANYTHING")
print("   the cap only matters once an absence banks more than it holds:")
print("      rate_lv  min/hr   cap_lv 0 binds after")
for lv in [0, 1, 2, 5, 10, rate_maxlv()]:
    mph = rate_mph(lv)
    hrs = cap_secs(0) / 60.0 / mph  # hours away to fill the base cap
    print("      %5d    %5d    %6.1f h away" % (lv, mph, hrs))

hrs_base = cap_secs(0) / 60.0 / rate_mph(0)
say(hrs_base <= 10,
    "the FIRST capacity purchase does something for a normal absence",
    "at rate_lv 0 the base cap needs %.1f h away before it clips" % hrs_base)

# --- 4. WHAT THE BANK IS WORTH, AS A BONUS ----------------------------
# The absence already ran as production (the hybrid). The bank is the
# extra on top, so its value is a PERCENTAGE of the absence.
print()
print("4. THE BONUS ON AN ABSENCE  (bank / away, the hybrid's extra)")
print("      away      lv 0/0     rate 5    rate 10   rate max  cap+rate max")
for away_h in (1, 4, 8, 12, 24):
    away = away_h * 3600.0
    row = []
    for rl, cl in ((0, 0), (5, 0), (10, 0), (rate_maxlv(), 0),
                   (rate_maxlv(), 10)):
        got, _ = bank_after(away, rl, cl)
        row.append("%6.1f%%" % (100.0 * got / away))
    print("      %3dh    " % away_h + "   ".join(row))

got0, _ = bank_after(8 * 3600, 0, 0)
say(0.02 <= got0 / (8 * 3600) <= 0.15,
    "a fresh account's overnight bonus is a nudge, not a second game",
    "8h away -> +%.1f%% (%.0f min of bank)" % (100 * got0 / (8 * 3600), got0 / 60))

# --- 5. THE COST LADDER -----------------------------------------------
print()
print("5. THE PRICE OF THE TWO UPGRADES  (profit, x3.5 a level)")
print("      lv    capacity        gives      rate            gives")
for lv in range(0, 12, 2):
    c = upg_cost("cap", lv)
    r = upg_cost("rate", lv)
    rr = ("+%d m/hr" % TB_RATE_STEP) if lv < rate_maxlv() else "MAXED"
    print("      %2d    %-14s  +%3d m     %-14s  %s"
          % (lv, "%.2e" % c, TB_CAP_STEP, "%.2e" % r, rr))

# the deceleration law: cost geometric, benefit linear
c0, c9 = upg_cost("cap", 0), upg_cost("cap", 9)
say((c9 / c0) > 1000,
    "cost outruns benefit (geometric price, linear minutes)",
    "10 capacity levels: price x%.0f for x%.1f the bank"
    % (c9 / c0, cap_secs(9) / cap_secs(0)))

# --- 6. THE CEILING ---------------------------------------------------
print()
print("6. THE END STATE")
mx = rate_maxlv()
print("      rate maxes at lv %d (%d min/hr), last level costs %.2e"
      % (mx, rate_mph(mx), upg_cost("rate", mx - 1)))
print("      at that rate the base cap clips after %.1f h away"
      % (cap_secs(0) / 60.0 / rate_mph(mx)))
print("      to hold a full 24h absence you need cap_lv %d"
      % math.ceil(((24 * rate_mph(mx)) - TB_CAP) / TB_CAP_STEP))
say(rate_mph(mx) == TB_RATE_CAP,
    "the rate ceiling is the tuned knob, not the hard law",
    "%d of a possible %d - headroom to raise TB_RATE_CAP later"
    % (TB_RATE_CAP, TB_HARD_CAP))

# --- 7. IS A PLAYER EVER STUCK? ---------------------------------------
# The two knobs are COMPLEMENTS: rate fills the bank, cap holds it. So
# at the point where they balance, ONE purchase alone changes nothing -
# raising the cap does nothing while the rate is the binder, and vice
# versa. That is not a fault, it is what complements do, and the pair
# together always pays.
#
# The fault to test for is therefore not "a dead purchase" but "a dead
# END": a state where buying one, then the other, still yields nothing.
# So: walk a real absence pattern, always buy the cheaper upgrade, and
# require that a step which buys nothing is always followed by one that
# does. Two barren steps in a row would mean the ladder had stalled.
print()
print("7. IS A PLAYER EVER STUCK?  (an 8h nightly absence, cheaper first)")
AWAY = 8 * 3600.0
rl = cl = 0
streak = 0
worst_streak = 0
print("      buy     rate   cap     bank from 8h away")
for step in range(16):
    before, _ = bank_after(AWAY, rl, cl)
    pick = "rate" if upg_cost("rate", rl) <= upg_cost("cap", cl) else "cap"
    if pick == "rate":
        rl += 1
    else:
        cl += 1
    after, _ = bank_after(AWAY, rl, cl)
    gained = after - before
    streak = 0 if gained > 1e-9 else streak + 1
    worst_streak = max(worst_streak, streak)
    print("      %-6s  %4d   %4dm   %5.1f -> %5.1f min   %s"
          % (pick, rate_mph(rl), cap_secs(cl) / 60, before / 60, after / 60,
             ("+%.0f" % (gained / 60)) if gained > 1e-9 else "- (pairs)"))

say(worst_streak <= 1,
    "the ladder never stalls - a barren buy is always half of a pair",
    "longest run of purchases that bought nothing: %d" % worst_streak)

# and the trap the first tuning pass actually had: a base cap so large
# that capacity is dead until an absurd absence
say(bank_after(AWAY, 0, 0)[1],
    "the base cap CLIPS a normal overnight, so capacity is a real buy",
    "8h at the base rate banks %.0f min into a %d min cap"
    % (AWAY * rate_mph(0) / 60 / 60, cap_secs(0) / 60))

print()
print("=" * 68)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
