"""tiles_twin.py - the tile table's shard economy, simulated.

The house pattern (forge_twin, ngu_twin, timebank_twin): model the
shipped maths in Python, state the invariants out loud, and print HOLDS
or FAILS. Tune here, port the numbers back - never the other way round.

WHAT IS BEING TESTED. The tile table earns SHARDS, and shards buy tile
upgrades, and those upgrades make the table earn more shards. That is a
closed positive-feedback loop with no external brake, so the only thing
standing between it and a runaway is the cost curve. This script exists
to prove the curve wins.

The model is tile_gps / tile_roll_tier / tiles_tick's fabricator and
auto-merger / tiles_merge / tile_upg, term for term.

Run:  python datafiles/tiles_twin.py
"""

import math
import random as _rnd

# ---------------------------------------------------------------- knobs
SLOTS_BASE   = 16
FAB_T_BASE   = 10.0    # seconds per fabricated tile
AM_MULT      = 1.5     # auto-merge interval = fab_t x this
STORED_MAX   = 10

# the rarity ladder (rarity_odds, tile knobs)
R_SCALE, R_GROW, R_CUT = .3, .03, 800

# the upgrades: base cost in shards, and what one level does
# TUNED BY THE SWEEP AT THE BOTTOM OF THIS FILE, not by taste. The
# first pass had bases in the tens and multipliers under 2.5, and the
# table bought all twenty-six upgrades in six minutes - the loop simply
# outran its own prices. Shards accrue at tile_gps rates, which reach
# hundreds per second within minutes and climb as t^1.5, so the bases
# belong in the hundreds of thousands and the multipliers above 3.
# CUT TO TWO (2026-09-08, his call), and the cost story changed with
# them. The old four were MULTIPLICATIVE in effect - a speed FACTOR, a
# luck step that shifted a whole spread - so they compounded and needed
# multipliers above 3 to stay ahead. These two are LINEAR (+10% of the
# rate a level, -0.1s a level) against a geometric price, so the loop
# decelerates by construction and x1.5 is enough. The bases are his,
# deliberately reachable.
UPG = {
    #            base      mult    what a level gives
    "profit": {"base": 1000,  "mult": 3.0},   # gps x (1 + .10 * lv)
    "fab":    {"base": 10000, "mult": 3.0},   # fab_t - 6 frames, floor 30
}
SPEED_FACTOR = .88
# ⚖️ SECONDS HERE, FRAMES IN THE GAME. main_macros stores TILE_FAB_STEP
# as 6 and TILE_FAB_MIN as 30 because tiles_tick counts delta (frames at
# 60hz); this twin has always worked in seconds, so they are /60. Getting
# this wrong once already cost a run: FAB_MIN of 30 read as 30 SECONDS
# and floored the fabricator above its own base, so the upgrade did
# nothing and the twin cheerfully reported it as bought ten times.
FAB_STEP     = 0.1    # main_macros TILE_FAB_STEP (6 frames)
FAB_MIN      = 0.5    # main_macros TILE_FAB_MIN  (30 frames)
PROFIT_STEP  = .10    # main_macros TILE_PROFIT_STEP
LUCK_STEP    = 60
SLOT_STEP    = 2
BANK_STEP    = 8

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label
          + (("   " + detail) if detail else ""))


# ------------------------------------------------------------- the maths
def tile_gps(tier):
    """tile_gps, in plain floats (the arb packing is log10 anyway)."""
    if tier <= 1:
        return 1.0
    if tier == 2:
        return 3.0
    if tier == 3:
        return 7.0
    g = 10.0 ** (.36 * (tier - 1))
    return g * (1 + (.26 + .08 * max(tier - 2, 0)) * (tier - 1))


def rarity_odds(rate, n=14):
    """rarity_odds, the shared band ladder."""
    base = 100.0
    f = (rate % cut_of(rate)) / R_CUT if False else (rate / R_CUT) % 1.0
    f = f ** 1.65
    f = (((base + 100) / (100 + (base + 100 - 100) * f)) - 1) * 100
    f = ((base - f) / base) % 1.0
    shift = min(int(rate // R_CUT), n - 1)
    bands = n - shift
    w = [base * (1 - f)]
    for r in range(1, bands):
        a = base * (R_SCALE + R_GROW * min(r, 5)) ** r
        b = base * (R_SCALE + R_GROW * min(r - 1, 5)) ** (r - 1)
        w.append(a + (b - a) * f)
    tot = sum(w)
    out = [0.0] * n
    for i, x in enumerate(w):
        out[shift + i] = x / tot
    return out


def cut_of(_):
    return R_CUT


def roll_tier(rate, rng):
    o = rarity_odds(rate)
    p = rng.random()
    acc = 0.0
    for i, x in enumerate(o):
        acc += x
        if p < acc:
            return i + 1
    return len(o)


def upg_cost(kind, lv):
    u = UPG[kind]
    return u["base"] * u["mult"] ** lv


# ------------------------------------------------------------ the table
class Table:
    def __init__(self, seed=7):
        self.rng = _rnd.Random(seed)
        self.lv = {k: 0 for k in UPG}
        self.tier = []
        self.stored = 0
        self.fab = 0.0
        self.am = 0.0
        self.shards = 0.0
        self.made = 0
        self.merges = 0

    # derived, never stored - the same law the GML follows
    # the retired knobs are FIXED now - the board keeps its base shape
    # and only the two live upgrades move
    def slots(self):    return SLOTS_BASE
    def fab_t(self):    return max(FAB_MIN, FAB_T_BASE - FAB_STEP * self.lv["fab"])
    def bank_max(self): return STORED_MAX
    def luck(self):     return 0
    def gps_mult(self): return 1 + PROFIT_STEP * self.lv["profit"]

    def gps(self):
        # the profit boost multiplies the BOARD's total, as tiles_tick
        # does - result-side, so it can never compound into itself
        return sum(tile_gps(t) for t in self.tier) * self.gps_mult()

    def free(self):
        return self.slots() - len(self.tier)

    def step(self, dt):
        # fabricate
        self.fab += dt
        while self.fab >= self.fab_t():
            self.fab -= self.fab_t()
            if self.stored >= self.bank_max():
                self.fab = self.fab_t()      # full, waits (never lost)
                break
            self.stored += 1
            self.made += 1
        # drain the bank onto free slots
        while self.stored > 0 and self.free() > 0:
            self.stored -= 1
            self.tier.append(roll_tier(self.luck(), self.rng))
        # auto-merge
        self.am += dt
        period = self.fab_t() * AM_MULT
        while self.am >= period:
            self.am -= period
            if not self._merge():
                self.am = period             # full, waiting
                break
        # the deadlock failsafe: a full board with no pair tiers its
        # lowest tile up, so play never stalls
        if self.free() == 0 and not self._has_pair():
            self.tier[self.tier.index(min(self.tier))] += 1
        # shards
        self.shards += self.gps() * dt

    def _has_pair(self):
        return len(self.tier) != len(set(self.tier))

    def _merge(self):
        seen = {}
        for i, t in enumerate(self.tier):
            if t in seen:
                self.tier[seen[t]] += 1
                self.tier.pop(i)
                self.merges += 1
                return True
            seen[t] = i
        return False


# ======================================================================
print(__doc__.strip().splitlines()[0])
print("=" * 70)

# --- 1. THE VALUE CURVE -----------------------------------------------
print()
print("1. WHAT A TIER IS WORTH  (tile_gps)")
print("      tier    value      x the tier below")
prev = None
for t in (1, 2, 3, 4, 6, 8, 10, 12, 14):
    v = tile_gps(t)
    print("      %4d  %10.3g   %s" % (t, v, "-" if prev is None else "%.2fx" % (v / prev)))
    prev = v
r = tile_gps(10) / tile_gps(9)
say(r > 2, "merging up beats hoarding",
    "a tier is worth %.2fx the one below, and it costs TWO of them" % r)

# --- 2. THE SPREAD ----------------------------------------------------
print()
print("2. THE FABRICATOR'S SPREAD  (luck 0, then upgraded)")
for rate in (0, 240, 600, 1200):
    o = rarity_odds(rate, 10)
    live = " ".join("t%d %.1f%%" % (i + 1, p * 100) for i, p in enumerate(o) if p > .004)
    print("      luck %4d:  %s" % (rate, live))
say(rarity_odds(1200, 10)[0] == 0,
    "luck eventually retires the bottom tier entirely",
    "past each cutoff the lowest tier stops spawning, not just thins")

# --- 3. THE LOOP ------------------------------------------------------
# The whole point. Run the table, buy the cheapest affordable upgrade
# whenever one is affordable, and watch the WAIT between purchases.
print()
print("3. DOES THE LOOP DECELERATE?  (buy the cheapest affordable, always)")
tb = Table()
t = 0.0
dt = 1.0
buys = []
last_buy_t = 0.0
LIMIT = 60 * 60 * 24 * 30       # thirty days of simulated table
while t < LIMIT and len(buys) < 26:
    tb.step(dt)
    t += dt
    while True:
        aff = [(upg_cost(k, tb.lv[k]), k) for k in UPG
               if upg_cost(k, tb.lv[k]) <= tb.shards]
        if not aff:
            break
        cost, kind = min(aff)
        tb.shards -= cost
        tb.lv[kind] += 1
        buys.append((t - last_buy_t, kind, t))
        last_buy_t = t

print("      #   bought   waited      at        board  luck  fab   top tier")
for i, (wait, kind, at) in enumerate(buys):
    if i % 3 and i != len(buys) - 1:
        continue
    print("      %2d  %-6s  %7.1fm  %8.1fh   %3d   %4d  %4.1fs  %d"
          % (i + 1, kind, wait / 60, at / 3600, tb.slots(), tb.luck(),
             tb.fab_t(), max(tb.tier) if tb.tier else 0))

if len(buys) >= 12:
    early = sum(w for w, _, _ in buys[2:6]) / 4
    late  = sum(w for w, _, _ in buys[-4:]) / 4
    say(late > early * 3,
        "the wait between purchases GROWS - the cost curve wins",
        "buys 3-6 averaged %.1f min apart, the last four %.1f min (x%.0f)"
        % (early / 60, late / 60, late / early))
else:
    say(False, "the loop stalled before 12 purchases",
        "only %d in thirty days - the costs are too steep" % len(buys))

# --- 4. NOT A RUNAWAY -------------------------------------------------
print()
print("4. IS IT A RUNAWAY?")
print("      after %.0f days: %d tiles made, %d merges, top tier %d"
      % (t / 86400, tb.made, tb.merges, max(tb.tier) if tb.tier else 0))
print("      income %.3g shards/sec, next purchase costs %.3g"
      % (tb.gps(), min(upg_cost(k, tb.lv[k]) for k in UPG)))
secs_to_next = min(upg_cost(k, tb.lv[k]) for k in UPG) / max(tb.gps(), 1e-9)
print("      which is %.1f hours of the CURRENT rate" % (secs_to_next / 3600))
say(secs_to_next > 3600,
    "the next purchase is always a real wait, never a formality",
    "%.1f h at the rate the table has just reached" % (secs_to_next / 3600))

# --- 5. EVERY UPGRADE GETS BOUGHT -------------------------------------
print()
print("5. IS ANY UPGRADE DEAD?")
for k in UPG:
    n = sum(1 for _, kind, _ in buys if kind == k)
    print("      %-6s  bought %2d times   (base %d, x%.1f a level)"
          % (k, n, UPG[k]["base"], UPG[k]["mult"]))
say(all(any(kind == k for _, kind, _ in buys) for k in UPG),
    "every upgrade is worth buying at some point",
    "one nobody ever buys is one that should not exist")

print()
print("=" * 70)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
