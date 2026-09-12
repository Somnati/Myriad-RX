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
import os
import random as _rnd

# a tuning sweep can override the roster's shape from the environment
# (TW_CURVE, TW_BASE = a multiplier on every base); the shipped values
# are the defaults
_ENV_CURVE = float(os.environ.get("TW_CURVE", "0") or 0)
_ENV_BASE  = float(os.environ.get("TW_BASE", "1") or 1)

# ---------------------------------------------------------------- knobs
SLOTS_BASE   = 12      # TILE_SLOTS_BASE - the slots row grows it (2026-09-10)
SLOT_STEP    = 1
SLOTS_MAX    = 32
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
# ⚖️ THE FABRICATOR IS A BUDGET (his spec): 10s base, 5s removable by
# UPGRADES, 3s reserved for abilities that do not exist yet, 2s floor.
# FAB_CAP is what makes the reservation real - a floor alone would let
# upgrades take every second there is and leave the abilities worthless.
FAB_STEP     = 0.1     # TILE_FAB_STEP (6 frames) - his increment
FAB_CAP      = 5.0     # TILE_FAB_CAP  (300 frames) - upgrades' share
FAB_MIN      = 2.0     # TILE_FAB_MIN  (120 frames) - the floor for all
PROFIT_STEP  = .25     # TILE_PROFIT_STEP - the board's share of the dial
                       # multiplier is (1+STEP)^lv - 1: COMPOUNDING, zero
                       # at level 0 (his call: the upgrade IS the chain)
RARITY_STEP  = 50      # TILE_RARITY_STEP - percentage points a level
DIAL_DIV     = 100     # TILE_DIAL_DIV - board output that DOUBLES dials
RB_GATE = 8                # the divisor's decade - below it flux floors to 0
FLUX_DIV, FLUX_STEP, FLUX_POW = 1e8, .01, 1.0   # +1% a flux LINEAR (his call); 1e8 is the brake
BANK_BASE    = 0       # TILE_BANK_BASE - his call, nothing until bought
BANK_STEP    = 1       # TILE_BANK_STEP

# COSTS ARE IN DECADES: cost = base x 10^(e x level). tile_upg prices in
# log space and the roster carries the log, so `e` is the exponent.
# EVERY ROW CURVES (his call): the span from base to top is spent
# unevenly, so early levels are cheap and the last lands on the ceiling.
# max is where the price REACHES the ceiling, which mostly sets how fine
# the early rungs are. See tile_upg - "curve" 1 would be a straight line.
CURVE = _ENV_CURVE if _ENV_CURVE > 0 else 1.25   # TILE_UPG_CURVE (2026-09-12: 1.25, see main_macros)
UPG = {
    # ⚖️ THE SPLIT (his design, 2026-09-12): the dial profit boost is NOT
    # a shard row any more - it is the first rung of the FLUX LADDER
    # (FUPG below), bought with flux, permanent through a reset. The
    # shard roster is the board's ENGINE and a reset wipes it whole.
    "bank":   {"base": 75000, "curve": CURVE, "top": 150, "max": 30},
    "rarity": {"base": 15000, "curve": CURVE, "top": 308, "max": 60},
    "fab":    {"base": 30000, "curve": CURVE, "top": 308, "max": 50},
    # the two chance rows (2026-09-10): 1% + 1%/level to 50% (tile_chance_rate)
    "dup":    {"base": 150000, "curve": CURVE, "top": 308, "max": 49},
    "tierup": {"base": 150000, "curve": CURVE, "top": 308, "max": 49},
    # the board itself (2026-09-10): the first four hand-priced (`pre`),
    # then the shared curve from the last of them to e308 at the cap
    "slots":  {"base": 30000, "pre": [3e4, 3e5, 3e6, 3e7], "curve": CURVE, "top": 308,
               "max": (SLOTS_MAX - SLOTS_BASE) // SLOT_STEP},
}
CHANCE_BASE, CHANCE_STEP, CHANCE_CAP = 1, 1, 50
for _k in UPG:
    UPG[_k]["base"] *= _ENV_BASE
    if "pre" in UPG[_k]: UPG[_k]["pre"] = [x * _ENV_BASE for x in UPG[_k]["pre"]]

# THE FLUX LADDER (tile_flux_config): cost = base x curve^lv in flux,
# permanent. profit is the export (the dial boost, (1+STEP)^lv - 1 of
# the board's output); slots and the rarity floor ride the board
FUPG = {
    "profit": {"base": 1, "curve": 1.6, "max": 50},
    "slots":  {"base": 8, "curve": 2.0, "max": 4},
    "rarity": {"base": 4, "curve": 1.8, "max": 10},
}
FLUX_RAR = 50          # TILE_FLUX_RAR - the floor's rate a level

def fupg_cost(kind, lv):
    u = FUPG[kind]
    return math.ceil(u["base"] * u["curve"] ** lv)

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
    lg = math.log10(u["base"])
    infl = u.get("inflate", False)
    pre = u.get("pre", [])
    if lv < len(pre):
        # the hand-set opening (tile_upg's `pre` lane)
        lg = math.log10(pre[lv])
    elif "curve" in u:
        top = u["top"]
        if infl:
            # the raw curve stops short so the INFLATED last level lands
            # on the stated top - tile_upg does the same
            top = (u["top"] + math.log10(FLUX_DIV / FLUX_STEP)) / 2
        if pre:
            lg0 = math.log10(pre[-1])
            lg = lg0 + (top - lg0) * ((lv - len(pre) + 1) / (u["max"] - len(pre))) ** u["curve"]
        else:
            lg += (top - lg) * (lv / u["max"]) ** u["curve"]
    else:
        lg += u["e"] * lv
    if infl:
        # the flux a player who had EARNED this much would hold, and the
        # output bonus that flux gives, charged back as the price
        lb = (lg - math.log10(FLUX_DIV)) + math.log10(FLUX_STEP)
        lg += lb if lb > 6 else math.log10(1 + 10 ** lb)
    return 10.0 ** lg


def upg_maxed(kind, lv):
    m = UPG[kind]["max"]
    return m is not None and lv >= m


# ------------------------------------------------------------ the table
class Table:
    def __init__(self, seed=7):
        self.rng = _rnd.Random(seed)
        self.lv = {k: 0 for k in UPG}
        self.flv = {k: 0 for k in FUPG}   # the flux ladder - survives a reset
        self.tier = []
        self.stored = 0
        self.fab = 0.0
        self.am = 0.0
        self.shards = 0.0
        self.earned = 0.0      # lifetime - what a table rebirth prices off
        self.flux = 0.0
        self.made = 0
        self.merges = 0
        self.log = []          # (t, kind, new level, cost)

    # derived, never stored - the same law the GML follows
    def slots(self):    return SLOTS_BASE + SLOT_STEP * self.lv["slots"] + self.flv["slots"]
    def fab_t(self):
        # the CAP limits what upgrades may take; MIN limits everything
        cut = min(FAB_CAP, FAB_STEP * self.lv["fab"])
        return max(FAB_MIN, FAB_T_BASE - cut)
    def bank_max(self): return BANK_BASE + BANK_STEP * self.lv["bank"]

    def chance(self, k):
        # tile_chance_rate: the shared law of the two chance rows
        return min(CHANCE_CAP, CHANCE_BASE + CHANCE_STEP * self.lv[k])
    def rb_boost(self):
        # tile_rebirth_boost: flux held, braked by a power under 1
        return 1 + FLUX_STEP * self.flux ** FLUX_POW

    def rarity(self):
        # tile_rarity_rate: the flat base, then the upgrade as a
        # MULTIPLIER (DE's chain). No deck bonus - nothing grants it yet.
        # + the flux ladder's floor, before the shard row multiplies
        return (RARITY_BASE + FLUX_RAR * self.flv["rarity"]) * (1 + RARITY_STEP * self.lv["rarity"] / 100.0)

    def gps(self):
        # ⚖️ THE PROFIT UPGRADE IS NOT HERE ANY MORE. It scales the
        # board's CONTRIBUTION TO DIAL PROFIT, not the board - see
        # dial_boost. What multiplies output now is the table's own
        # rebirth, which reaches both lanes because output is one thing.
        # PER TILE, FLOORED (tile_out, 2026-09-10): the flux boost lands
        # on each tile's face and is rounded down there, and the board's
        # rate is the sum of the faces.
        b = self.rb_boost()
        return sum(math.floor(tile_gps(t) * b) for t in self.tier)

    def dial_boost(self):
        # tile_dial_boost: DE's chain (1 + board total / DIAL_DIV) with
        # the board's share GATED by the profit upgrade - f(0) = 0, so
        # an unbought upgrade is an unwired board, and f compounds per
        # level. THIS is where the upgrade's value lands; measuring it
        # on gps (as this twin used to) reports it as worth nothing.
        f = (1 + PROFIT_STEP) ** self.flv["profit"] - 1   # the flux ladder's level
        return 1 + self.gps() * f / DIAL_DIV

    def rb_calc(self):
        # tile_rebirth_calc: flux = earned / DIV, off lifetime EARNED
        if self.earned < 10 ** RB_GATE:
            return 0
        return math.floor(self.earned / FLUX_DIV)

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
            # duplication: a second tile, if there is room for it
            if self.stored < self.bank_max() + self.free():
                if self.rng.random() * 100 < self.chance("dup"):
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
                # +1, or +2 on a tier-up roll (TILE_BONUS_TIER is parked)
                self.tier[seen[t]] += 1
                if self.rng.random() * 100 < self.chance("tierup"):
                    self.tier[seen[t]] += 1
                self.tier.pop(i)
                self.merges += 1
                return True
            seen[t] = i
        return False

    def try_fbuy(self, kind):
        """one rung of the flux ladder, off the pile (tile_fupg)"""
        if self.flv[kind] >= FUPG[kind]["max"]:
            return False
        c = fupg_cost(kind, self.flv[kind])
        if self.flux < c:
            return False
        self.flux -= c
        self.flv[kind] += 1
        return True

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


_ENV_SEED = int(os.environ.get("TW_SEED", "7") or 7)


RESET_IDLE = 3 * 3600   # a player resets once the board has gone this long without a buy


def run(hours, buy=True, seed=None, resets=False):
    """a greedy day. resets=True plays it as a player would: once flux is
    on offer and the board has gone RESET_IDLE without buying anything -
    the plateau - the table is reset (the flux banked, the engine wiped)
    and the cheap ladder starts over. The reset lands in the log as a
    purchase of kind 'RESET' so the gaps are measured against it too."""
    if seed is None: seed = _ENV_SEED
    tb = Table(seed)
    last = 0
    for t in range(int(hours * 3600)):
        tb.step(1.0)
        if buy:
            if tb.try_buy(t + 1): last = t + 1
            if resets and tb.rb_calc() >= 1 and (t + 1 - last) >= RESET_IDLE:
                paid = tb.rb_calc()
                tb.flux += paid
                tb.log.append((t + 1, "RESET", int(paid), tb.earned))
                # the engine wiped, the ladder and the flux kept
                keep_flv, keep_flux = dict(tb.flv), tb.flux
                seed2 = tb.rng.random()
                tb2 = Table(int(seed2 * 1e9))
                tb2.flv, tb2.flux, tb2.log = keep_flv, keep_flux, tb.log
                tb = tb2
                last = t + 1
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
print("3. THE PURCHASE TIMELINE  (greedy: cheapest affordable, 24h; a RESET once the")
print("   board has sat %s without a buy and flux is on offer - the player's plateau)" % hms(RESET_IDLE))
tb = run(24, resets=True)
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
print("      levels at 24h: " + ", ".join("%s %d" % (k, tb.lv[k]) for k in UPG) + "  (the ladder: none - no reset yet)")
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
say(3 <= n1h <= 14,
    "the first hour buys 3-14 (seeds land 11-14 on this shape)",
    "%d - neither a slot machine nor a wall" % n1h)
if gaps:
    say(max(gaps) <= 6 * 3600,
        "no gap over 6h in the first day (a reset counts - it is what a player does at the wall)",
        "longest %s" % hms(max(gaps)))
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
print("7. DO THE SHARD UPGRADES MATTER?  (buy everything vs buy nothing)")
print("      measured on BOARD OUTPUT - the engine is what shards buy now;")
print("      the dial boost is the flux ladder's (section 8b)")
print()
print("      %-6s %11s %11s %8s" % ("hours", "gps none", "gps all", "worth"))
worth = 1.0
for h in (1, 6, 24):
    x = run(h, buy=False)
    y = run(h, buy=True)
    worth = y.gps() / max(x.gps(), 1e-9)
    print("      %-6d %11s %11s %7.2fx" % (h, eng(x.gps()), eng(y.gps()), worth))
say(worth >= 2,
    "a day of shard upgrades is worth at least 2x on board output",
    "%.2fx" % worth)

print()
print("      what the 24h levels are actually worth:")
print("        fab    lv%d -> fabricator %.2fs (from %.1fs; -%.1fs is the cap)"
      % (tb.lv["fab"], tb.fab_t(), FAB_T_BASE, FAB_CAP))
print("        rarity lv%d -> rate %.0f (from %d; %d is one floor shift)"
      % (tb.lv["rarity"], tb.rarity(), RARITY_BASE, R_CUT))
print("        bank   lv%d -> hopper %d tiles" % (tb.lv["bank"], tb.bank_max()))

# --- 7b. THE FABRICATOR AGAINST THE CEILING -------------------------
print()
print("7b. THE FABRICATOR'S LADDER  (his spec: -5s from upgrades by 1e308)")
print("      %-6s %9s %10s" % ("level", "fab_t", "costs"))
for lv in (0, 5, 10, 25, 40, 50):
    cut = min(FAB_CAP, FAB_STEP * lv)
    print("      %-6d %8.2fs %10s"
          % (lv, max(FAB_MIN, FAB_T_BASE - cut), eng(upg_cost("fab", lv))))
_top = UPG["fab"]["max"]
say(abs(FAB_STEP * _top - FAB_CAP) < 1e-9,
    "the last level lands exactly on the budget",
    "-%.1fs, his number" % (FAB_STEP * _top))
say(upg_cost("fab", _top - 1) < 1e308,
    "and the ladder ends inside the ceiling",
    "level %d costs %s" % (_top, eng(upg_cost("fab", _top - 1))))
say(FAB_T_BASE - FAB_CAP - 3.0 >= FAB_MIN - 1e-9,
    "three seconds stay open for the abilities",
    "%.1fs after upgrades, %.1fs after three 1s abilities"
    % (FAB_T_BASE - FAB_CAP, FAB_T_BASE - FAB_CAP - 3.0))

# --- 8. THE TABLE'S OWN REBIRTH --------------------------------------
print()
print("8. THE TABLE'S REBIRTH  (flux = earned / %s, off lifetime EARNED)" % eng(FLUX_DIV))
print("      %-8s %9s %10s %10s" % ("played", "earned", "flux paid", "output x"))
for h in (0.25, 1, 6, 24):
    z = run(h)
    f = z.rb_calc()
    print("      %-8s %9s %10s %9.2fx"
          % (hms(h * 3600), eng(z.earned), eng(f), 1 + FLUX_STEP * f ** FLUX_POW))
z = run(24)
say(z.rb_calc() >= 1,
    "a day of play pays flux",
    "%s - a prestige nobody can reach in a session is a prestige nobody "
    "meets" % eng(z.rb_calc()))

# ⚖️ THE LOOP ACROSS REBIRTHS is the thing that can actually run away:
# flux is proportional to earned, earned to output, output to flux. Six
# rebirths of six hours each, banking flux every time, and the question
# is whether run six is a bigger number or a DIFFERENT GAME.
print()
print("      six rebirths, six hours each, flux banked and carried (HELD - nothing spent):")
print("      %-4s %10s %10s %10s" % ("run", "start x", "earned", "flux total"))
carry = 0.0
ratio = 1.0
first = None
for r in range(1, 7):
    # a FRESH table each run: board, shards, earned AND every SHARD
    # upgrade level back to zero - tile_rebirth_do's law. The flux
    # carries, and so would the ladder's levels (none bought here)
    tbl = Table(seed=7 + r)
    tbl.flux = carry
    for tt in range(6 * 3600):
        tbl.step(1.0)
        tbl.try_buy(tt + 1)
    paid = tbl.rb_calc()
    carry += paid
    if first is None: first = tbl.earned
    ratio = tbl.earned / first
    print("      %-4d %9.2fx %10s %10s" % (r, tbl.rb_boost(), eng(tbl.earned), eng(carry)))
say(ratio < 1e4,
    "run six earns under 1e4x run one - the brake holds",
    "%.0fx; FLUX_POW is the lever if this ever fails" % ratio)

# --- 8b. THE FLUX LADDER: the decision -------------------------------
# ⚖️ THE SPLIT (2026-09-12). Held flux is +1% output a point; the ladder
# spends it. The decision is real only if BOTH answers are good: a
# player who buys the export gives up table strength for dial strength,
# and the game should not simply reward one of them. Six rebirths again,
# now SPENDING on the profit rung whenever it is affordable, against
# the holder above: the spender's table must earn less (the price is
# real) and the spender's dial boost must be worth having.
print()
print("8b. THE FLUX LADDER  (spend on the export vs hold for +1%)")
print("      rung   profit costs   slots costs   rarity costs")
for lv in (0, 1, 3, 5, 10, 20):
    print("      %-6d %13s %13s %14s" % (lv, fupg_cost("profit", lv),
          fupg_cost("slots", min(lv, FUPG["slots"]["max"] - 1)), fupg_cost("rarity", min(lv, FUPG["rarity"]["max"] - 1))))
print("      %-4s %10s %10s %10s %8s %12s" % ("run", "earned", "flux held", "ladder", "start x", "dial boost"))
carry2 = 0.0
lvl = {k: 0 for k in FUPG}
earned_spend = None
for r in range(1, 7):
    tbl = Table(seed=7 + r)
    tbl.flux = carry2
    tbl.flv = dict(lvl)
    # spend at the start of the run: every profit rung the pile covers
    while tbl.try_fbuy("profit"): pass
    for tt in range(6 * 3600):
        tbl.step(1.0)
        tbl.try_buy(tt + 1)
    paid = tbl.rb_calc()
    carry2 = tbl.flux + paid
    lvl = dict(tbl.flv)
    earned_spend = tbl.earned
    print("      %-4d %10s %10s %10s %7.2fx %11.2fx" % (r, eng(tbl.earned), eng(carry2), "lv%d" % lvl["profit"],
          tbl.rb_boost(), tbl.dial_boost()))
say(earned_spend < first * ratio,
    "the spender's table earns LESS than the holder's by run six - the price is real",
    "%s vs %s" % (eng(earned_spend), eng(first * ratio)))
say(lvl["profit"] >= 3,
    "...and the spender holds a real export by then - the ladder is reachable",
    "profit lv%d" % lvl["profit"])
# the ladder's own brake: each rung's price grows faster than a run's flux
say(FUPG["profit"]["curve"] > 1.4,
    "the profit rung's price climbs geometrically - the ladder cannot be bought whole",
    "x%.1f a rung" % FUPG["profit"]["curve"])

print()
print("=" * 74)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
