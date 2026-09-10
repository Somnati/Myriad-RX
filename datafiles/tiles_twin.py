"""tiles_twin.py - the tile table's shard economy, simulated.

The house pattern (forge_twin, ngu_twin, timebank_twin): model the
shipped maths in Python, state the invariants out loud, and print HOLDS
or FAILS. Tune here, port the numbers back - never the other way round.

WHAT IS BEING ASKED (2026-09-09, his question): how fast can the four
upgrades actually be bought, and does the pacing feel good? Those are
different questions and the second is the real one. A curve can be
perfectly safe and still feel awful in either direction - a purchase
every four seconds is a slot machine, a purchase every nine hours is a
wall, and the old deceleration invariant is happy with both.

So the headline is a PURCHASE TIMELINE and the gaps between purchases.
The invariants are still checked at the bottom, because a curve that
feels good and runs away is still broken.

The model is tile_gps / tile_rarity_rate / tile_roll_tier / tiles_tick's
fabricator and auto-merger / tiles_merge / tile_upg, term for term.

Run:  python datafiles/tiles_twin.py
"""

import math
import random as _rnd

# ---------------------------------------------------------------- knobs
SLOTS_BASE   = 16
FAB_T_BASE   = 10.0    # seconds per fabricated tile
AM_MULT      = 1.5     # auto-merge interval = fab_t x this

# the rarity ladder (rarity_odds, tile knobs)
R_SCALE, R_GROW, R_CUT = .3, .03, 400   # TILE_RARITY_CUT - his 400
RARITY_BASE  = 100     # TILE_RARITY_BASE - DE's mod_rarity_rate opener

# SECONDS HERE, FRAMES IN THE GAME. main_macros stores TILE_FAB_STEP as
# 6 and TILE_FAB_MIN as 30 because tiles_tick counts delta (frames at
# 60hz); this twin has always worked in seconds, so they are /60. Getting
# it wrong once already cost a run: FAB_MIN of 30 read as 30 SECONDS and
# floored the fabricator above its own base, so the upgrade did nothing
# and the twin cheerfully reported it bought ten times.
FAB_STEP     = 0.1     # TILE_FAB_STEP (6 frames)
FAB_MIN      = 0.5     # TILE_FAB_MIN  (30 frames)
PROFIT_STEP  = .10     # TILE_PROFIT_STEP
RARITY_STEP  = 50      # TILE_RARITY_STEP - percentage points a level
DIAL_DIV     = 100     # TILE_DIAL_DIV - board output that DOUBLES dials
RB_GATE, RB_RATE, RB_STEP = 6, 1.5, 1.0   # the table's own rebirth
BANK_BASE    = 0       # TILE_BANK_BASE - his call, nothing until bought
BANK_STEP    = 1       # TILE_BANK_STEP

# COSTS ARE IN DECADES: cost = base x 10^(e x level). tile_upg prices in
# log space and the roster carries the log, so `e` is the exponent.
UPG = {
    "profit": {"base":  1000, "e": 2.5, "max": None},  # gps x (1 + .10 lv)
    "bank":   {"base":  2500, "e": 2.5, "max": 30},    # +1 hopper tile
    "rarity": {"base":  5000, "e": 2.5, "max": None},  # rate x (1 + .50 lv)
    "fab":    {"base": 10000, "e": 2.5, "max": 95},    # -0.1s, floor 0.5s
}

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label
          + (("   " + detail) if detail else ""))


def hms(s):
    s = int(s)
    if s < 60:
        return "%ds" % s
    if s < 3600:
        return "%dm%02ds" % (s // 60, s % 60)
    if s < 86400:
        return "%dh%02dm" % (s // 3600, (s % 3600) // 60)
    return "%dd%02dh" % (s // 86400, (s % 86400) // 3600)


def eng(v):
    if v < 1e5:
        return "%.0f" % v
    return "1e%.1f" % math.log10(max(v, 1e-9))


# ------------------------------------------------------------- the maths
def tile_gps(tier):
    if tier <= 1:
        return 1.0
    if tier == 2:
        return 3.0
    if tier == 3:
        return 7.0
    g = 10.0 ** (.36 * (tier - 1))
    return g * (1 + (.26 + .08 * max(tier - 2, 0)) * (tier - 1))


def rarity_odds(rate, n=14):
    base = 100.0
    f = (rate / R_CUT) % 1.0
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
    return u["base"] * 10.0 ** (u["e"] * lv)


def upg_maxed(kind, lv):
    m = UPG[kind]["max"]
    return m is not None and lv >= m


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
        self.earned = 0.0      # lifetime - what a table rebirth prices off
        self.rb_units = 0
        self.made = 0
        self.merges = 0
        self.log = []          # (t, kind, new level, cost)

    # derived, never stored - the same law the GML follows
    def slots(self):    return SLOTS_BASE
    def fab_t(self):    return max(FAB_MIN, FAB_T_BASE - FAB_STEP * self.lv["fab"])
    def bank_max(self): return BANK_BASE + BANK_STEP * self.lv["bank"]
    def rb_boost(self):
        # tile_rebirth_boost: the table's own prestige, on OUTPUT
        return 1 + RB_STEP * self.rb_units

    def rarity(self):
        # tile_rarity_rate: the flat base, then the upgrade as a
        # MULTIPLIER (DE's chain). No deck bonus - nothing grants it yet.
        return RARITY_BASE * (1 + RARITY_STEP * self.lv["rarity"] / 100.0)

    def gps(self):
        # ⚖️ THE PROFIT UPGRADE IS NOT HERE ANY MORE. It scales the
        # board's CONTRIBUTION TO DIAL PROFIT, not the board - see
        # dial_boost. What multiplies output now is the table's own
        # rebirth, which reaches both lanes because output is one thing.
        return sum(tile_gps(t) for t in self.tier) * self.rb_boost()

    def dial_boost(self):
        # tile_dial_boost, DE's get_allmodgps: the board's total, scaled
        # by the profit upgrade, over DIAL_DIV, plus one. THIS is where
        # the profit upgrade's value actually lands, and measuring it on
        # gps (as this twin used to) would report it as worth nothing.
        return 1 + (self.gps() * (1 + PROFIT_STEP * self.lv["profit"])) / DIAL_DIV

    def rb_calc(self):
        # tile_rebirth_calc, off lifetime EARNED
        if self.earned < 10 ** RB_GATE:
            return 0
        oom = math.floor(math.log10(self.earned))
        return 1 + int((oom - RB_GATE) / RB_RATE)

    def free(self):
        return self.slots() - len(self.tier)

    def step(self, dt):
        # ---- fabricate ----
        # THE HOPPER IS OVERFLOW, NOT A CONVEYOR (tiles_tick, 2026-09-09):
        # a finished tile is kept if there is anywhere for it to go, and
        # the BOARD is the first of those places. Gating purely on hopper
        # room is what made a zero hopper a dead fabricator.
        self.fab += dt
        while self.fab >= self.fab_t():
            if self.free() == 0 and self.stored >= self.bank_max():
                self.fab = self.fab_t()      # board full AND hopper full
                break
            self.fab -= self.fab_t()
            self.stored += 1
            self.made += 1
            if self.free() > 0 and self.stored > 0:
                self.stored -= 1             # the tick's next block
                self.tier.append(roll_tier(self.rarity(), self.rng))
        while self.stored > 0 and self.free() > 0:
            self.stored -= 1
            self.tier.append(roll_tier(self.rarity(), self.rng))
        # ---- auto-merge ----
        self.am += dt
        period = self.fab_t() * AM_MULT
        while self.am >= period:
            self.am -= period
            if not self._merge():
                self.am = period             # no pair, waiting
                break
        # the deadlock failsafe: a full board with no pair tiers its
        # lowest tile up, so play never stalls
        if self.free() == 0 and not self._has_pair():
            self.tier[self.tier.index(min(self.tier))] += 1
        # ---- shards ----
        var_add = self.gps() * dt
        self.shards += var_add
        self.earned += var_add

    def _has_pair(self):
        return len(self.tier) != len(set(self.tier))

    def _merge(self):
        seen = {}
        for i, t in enumerate(self.tier):
            if t in seen:
                # TILE_BONUS_TIER is parked, so a merge is always +1
                self.tier[seen[t]] += 1
                self.tier.pop(i)
                self.merges += 1
                return True
            seen[t] = i
        return False

    def try_buy(self, t):
        """greedy: the CHEAPEST affordable upgrade, repeatedly."""
        did = False
        while True:
            best, bestc = None, None
            for k in UPG:
                if upg_maxed(k, self.lv[k]):
                    continue
                c = upg_cost(k, self.lv[k])
                if c <= self.shards and (bestc is None or c < bestc):
                    best, bestc = k, c
            if best is None:
                return did
            self.shards -= bestc
            self.lv[best] += 1
            self.log.append((t, best, self.lv[best], bestc))
            did = True


def run(hours, buy=True, seed=7):
    tb = Table(seed)
    for t in range(int(hours * 3600)):
        tb.step(1.0)
        if buy:
            tb.try_buy(t + 1)
    return tb


# ======================================================================
print(__doc__.strip().splitlines()[0])
print("=" * 74)

# --- 1. THE VALUE CURVE -----------------------------------------------
print()
print("1. WHAT A TIER IS WORTH  (tile_gps)")
print("      tier      value    x the tier below")
prev = None
for t in (1, 2, 3, 4, 6, 8, 10, 12, 14):
    v = tile_gps(t)
    print("      %4d %10s    %s" % (t, eng(v), "-" if prev is None else "%.2fx" % (v / prev)))
    prev = v
say(tile_gps(10) / tile_gps(9) > 2,
    "merging up beats hoarding", "a tier is worth >2x the one below")

# --- 2. THE SPREAD ----------------------------------------------------
print()
print("2. THE FABRICATOR'S SPREAD  (rate 100 base, x the rarity upgrade)")
print("      one floor shift costs %d of rate" % R_CUT)
for lv in (0, 1, 3, 6, 12):
    rate = RARITY_BASE * (1 + RARITY_STEP * lv / 100.0)
    o = rarity_odds(rate, 10)
    live = " ".join("t%d %.0f%%" % (i + 1, p * 100) for i, p in enumerate(o) if p > .01)
    print("      lv%-3d rate %5.0f:  %s" % (lv, rate, live))

# --- 3. THE PURCHASE TIMELINE ----------------------------------------
print()
print("3. THE PURCHASE TIMELINE  (greedy: cheapest affordable, 24h)")
tb = run(24)
print("      %-9s %-8s %-6s %10s %10s" % ("at", "upgrade", "level", "cost", "gap"))
prev_t = 0
for (t, k, lv, c) in tb.log[:20]:
    print("      %-9s %-8s %-6d %10s %10s"
          % (hms(t), k, lv, eng(c), hms(t - prev_t)))
    prev_t = t
if len(tb.log) > 20:
    print("      ... and %d more" % (len(tb.log) - 20))
if not tb.log:
    print("      (nothing was ever affordable)")

# --- 4. THE PACING ----------------------------------------------------
print()
print("4. THE PACING  (what it feels like)")
for h in (1 / 60.0, 10 / 60.0, 1, 8, 24):
    n = len([1 for (t, _, _, _) in tb.log if t <= h * 3600])
    print("      after %-8s %2d upgrade(s)" % (hms(h * 3600), n))
gaps = [tb.log[i][0] - tb.log[i - 1][0] for i in range(1, len(tb.log))]
if gaps:
    print("      gap between purchases: median %s, longest %s"
          % (hms(sorted(gaps)[len(gaps) // 2]), hms(max(gaps))))
print("      levels at 24h: " + ", ".join("%s %d" % (k, tb.lv[k]) for k in UPG))
print("      board at 24h:  top tier %d, %s shards/s, %s banked"
      % (max(tb.tier) if tb.tier else 0, eng(tb.gps()), eng(tb.shards)))

# --- 5. THE FEEL TEST -------------------------------------------------
print()
print("5. DOES IT FEEL GOOD")
first = tb.log[0][0] if tb.log else None
say(first is not None and first <= 300,
    "the first upgrade lands inside 5 minutes",
    "at %s" % (hms(first) if first else "never"))
n1h = len([1 for (t, _, _, _) in tb.log if t <= 3600])
say(3 <= n1h <= 12,
    "the first hour buys 3-12",
    "%d - neither a slot machine nor a wall" % n1h)
if gaps:
    say(max(gaps) <= 6 * 3600,
        "no gap over 6h in the first day", "longest %s" % hms(max(gaps)))
say(all(any(k == kk for (_, kk, _, _) in tb.log) for k in UPG),
    "every upgrade gets bought",
    "one nobody ever buys is one that should not exist")

# --- 6. THE RUNAWAY CHECK --------------------------------------------
print()
print("6. THE LOOP STILL DECELERATES")
a = run(6)
nxt = min(upg_cost(k, a.lv[k]) for k in UPG if not upg_maxed(k, a.lv[k]))
hour = a.gps() * 3600
say(nxt > hour,
    "at 6h the next upgrade costs more than an hour of income",
    "next %s vs an hour %s" % (eng(nxt), eng(hour)))
if len(gaps) >= 8:
    early = sum(gaps[1:5]) / 4.0
    late = sum(gaps[-4:]) / 4.0
    say(late > early,
        "the wait GROWS as the table matures",
        "early %s -> late %s" % (hms(early), hms(late)))

# --- 7. DO THE UPGRADES MATTER AT ALL? -------------------------------
# ⚖️ THE INVARIANT THIS FILE WAS MISSING, and the one that actually
# failed (2026-09-09). Every previous version asked whether the cost
# curve could be outrun. None asked whether the upgrades were WORTH
# buying - and the answer turned out to be barely. Buying all four for a
# solid day is worth ~1.6x against a merge loop that delivers ~1e6x on
# its own, because every effect here is LINEAR (+10% of the rate, -0.1s,
# +20% of a rate whose threshold is 800, +1 tile) while board income is
# EXPONENTIAL in tier and tiers climb by themselves.
#
# A cost curve cannot fix that. An upgrade nobody would miss is not a
# pacing problem, it is a design one.
print()
print("7. DO THE UPGRADES MATTER?  (buy everything vs buy nothing)")
print("      NOTE: measured on the DIAL BOOST, not on board output. The")
print("      profit upgrade no longer touches the board at all - it")
print("      scales the board's contribution to dial profit, so gps")
print("      would report the biggest upgrade in the roster as worth 0.")
print()
print("      %-6s %11s %11s %8s %11s %11s %8s"
      % ("hours", "gps none", "gps all", "worth", "dial none", "dial all", "worth"))
worth = 1.0
for h in (1, 6, 24):
    x = run(h, buy=False)
    y = run(h, buy=True)
    wg = y.gps() / max(x.gps(), 1e-9)
    worth = y.dial_boost() / max(x.dial_boost(), 1e-9)
    print("      %-6d %11s %11s %7.2fx %11s %11s %7.2fx"
          % (h, eng(x.gps()), eng(y.gps()), wg,
             eng(x.dial_boost()), eng(y.dial_boost()), worth))
say(worth >= 3,
    "a day of upgrades is worth at least 3x on the dial boost",
    "%.2fx" % worth)

print()
print("      what the 24h levels are actually worth:")
print("        profit lv%d -> dial contribution x%.2f (NOT the board)"
      % (tb.lv["profit"], 1 + PROFIT_STEP * tb.lv["profit"]))
print("        fab    lv%d -> fabricator %.1fs (from %.1fs)"
      % (tb.lv["fab"], tb.fab_t(), FAB_T_BASE))
print("        rarity lv%d -> rate %.0f (from %d; %d is one floor shift)"
      % (tb.lv["rarity"], tb.rarity(), RARITY_BASE, R_CUT))
print("        bank   lv%d -> hopper %d tiles" % (tb.lv["bank"], tb.bank_max()))

# --- 8. THE TABLE'S OWN REBIRTH --------------------------------------
print()
print("8. THE TABLE'S REBIRTH  (tile_rebirth_calc, off lifetime EARNED)")
print("      %-8s %9s %8s %10s" % ("played", "earned", "units", "output x"))
for h in (0.25, 1, 6, 24):
    z = run(h)
    u = z.rb_calc()
    print("      %-8s %9s %8d %9.1fx"
          % (hms(h * 3600), eng(z.earned), u, 1 + RB_STEP * u))
z = run(24)
say(z.rb_calc() >= 1,
    "a day of play earns at least one unit",
    "%d - a prestige nobody can reach in a session is a prestige nobody "
    "meets" % z.rb_calc())
say(z.rb_calc() <= 30,
    "and not an absurd number of them",
    "%d units = x%.0f board output" % (z.rb_calc(), 1 + RB_STEP * z.rb_calc()))

print()
print("=" * 74)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
