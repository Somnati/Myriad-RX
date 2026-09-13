"""exped_twin.py - the expedition loop, simulated.

The house pattern (tiles_twin, battery_twin): model the shipped maths in
Python, state the invariants out loud, print HOLDS or FAILS. Tune here,
port the numbers back - never the other way round.

WHAT IS ASKED (2026-09-13, built blind while he was away): a crew walks
five rooms on a world of tier 1..4; rooms are finds, rests, traps and
fights by the biome's weights; a fight is the crew against one foe in
initiative order; the crew is routed when everyone is down. Is a solo
tier-1 trip survivable, is a solo tier-3 trip the suicide it should be,
does a crew of three make a tier-3 world reasonable, and how fast do
bonds climb? The laws are exped_room / exped_fight_new / exped_fight_turn
/ exped_tick_one / exped_bond_add, term for term; the macros are read
from main_macros.gml so the twin cannot drift from the game.

Run:  python datafiles/exped_twin.py
"""

import math
import os
import random
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_mac = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
_bio = open(os.path.join(ROOT, "scripts", "exped_biomes", "exped_biomes.gml"), encoding="utf-8").read()
_per = open(os.path.join(ROOT, "scripts", "sprite_personalities", "sprite_personalities.gml"), encoding="utf-8").read()
_fn  = open(os.path.join(ROOT, "scripts", "exped_fight_new", "exped_fight_new.gml"), encoding="utf-8").read()


def macro(name):
    m = re.search(r"^#macro\s+" + name + r"\s+([-\d.]+)", _mac, re.M)
    if not m:
        raise SystemExit("main_macros has no #macro " + name)
    return float(m.group(1))


EXPED_ROOMS  = int(macro("EXPED_ROOMS"))
EXPED_TRAVEL = macro("EXPED_TRAVEL")
EXPED_RETURN = macro("EXPED_RETURN")
EXPED_DIST0  = macro("EXPED_DIST0")
EXPED_PARTY  = int(macro("EXPED_PARTY"))
BOND_TRIP    = macro("EXPED_BOND_TRIP")
BOND_WIN     = macro("EXPED_BOND_WIN")
BOND_ROUT    = macro("EXPED_BOND_ROUT")

# the biomes' room weights, read off exped_biomes
BIOMES = {}
for m in re.finditer(r'name\s*:\s*"(\w+)".*?rooms\s*:\s*\{([^}]*)\}', _bio, re.S):
    w = {k: float(v) for k, v in re.findall(r"(\w+)\s*:\s*([\d.]+)", m.group(2))}
    BIOMES[m.group(1)] = w
if not BIOMES:
    raise SystemExit("could not read the biomes' room weights")
# the personalities' pace
PACES = [float(p) for p in re.findall(r"pace\s*:\s*([\d.]+)", _per)]
# the fight's numbers, read off exped_fight_new
def _num(pat, default):
    m = re.search(pat, _fn)
    return float(m.group(1)) if m else default
# (the formulas below mirror exped_fight_new / exped_fight_turn; the
# constants are checked against the source so a retune shows here)
assert "60 + 15 * _pace + _bonus" in _fn, "member hit formula moved - update the twin"
assert "5 + 3 * _pace" in _fn, "member init formula moved"
assert "(6 + 3 * _d.tier) * (1 + .7 * (_up - 1))" in _fn, "foe hp formula moved"
assert "45 + 5 * _d.tier" in _fn, "foe hit formula moved"
assert ".5 + .5 * _d.tier" in _fn, "foe dmg formula moved"
assert ".6 * (_up - 1)" in _fn, "foe swings formula moved"
HP0 = 10   # exped_start: 10 + 2 x rarity rung
assert "_h = 10 + (_sp[$ \"rar\"] ?? 0) * 2" in open(os.path.join(ROOT, "scripts", "exped_start", "exped_start.gml"), encoding="utf-8").read(), "crew hp moved"

LUCK_MOD = 1.2   # luck_mod at zero luck points (the flat +.2)

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label + (("   " + detail) if detail else ""))


def roll_perc(p, rng):
    return rng.random() * 100 < p


def coin(x, rng):
    """exped_fight_turn's _coin: a real paid as whole points"""
    f = math.floor(x)
    return f + (1 if rng.random() < x - f else 0)


# ---------------------------------------------------------------- the laws
def fight(crew, tier, bond_mean, rng):
    """exped_fight_new + exped_fight_turn. crew: list of dicts {hp, hpmax, pace}.
    Mutates hp. Returns won."""
    up = [m for m in crew if m["hp"] > 0]
    n = len(up)
    bonus = min(10, bond_mean / 10) if n >= 2 else 0
    party = [{"m": m, "hit": min(95, max(40, 60 + 15 * m["pace"] + bonus)), "init": 5 + 3 * m["pace"], "dmg": 2} for m in up]
    fhp = round((6 + 3 * tier) * (1 + .7 * (n - 1)))
    foe = {"hp": fhp, "hit": min(90, max(30, 45 + 5 * tier)), "init": 4 + tier, "dmg": .5 + .5 * tier, "swings": .6 * (n - 1)}
    for _turn in range(200):
        order = sorted([("a", i, party[i]["init"]) for i in range(len(party))] + [("b", -1, foe["init"])],
                       key=lambda o: (-o[2], 0 if o[0] == "a" else 1))
        for side, i, _ in order:
            if side == "a":
                pm = party[i]
                if pm["m"]["hp"] <= 0: continue
                if roll_perc(pm["hit"] * LUCK_MOD, rng):
                    q = roll_perc(10 * LUCK_MOD, rng)
                    foe["hp"] = max(0, foe["hp"] - pm["dmg"] * (2 if q else 1))
                    if foe["hp"] > 0 and roll_perc(15, rng):
                        pm["m"]["hp"] = max(0, pm["m"]["hp"] - 1)
            else:
                if foe["hp"] <= 0: continue
                for _sw in range(1 + coin(foe["swings"], rng)):
                    alive = [p for p in party if p["m"]["hp"] > 0]
                    if not alive: break
                    t = rng.choice(alive)
                    if roll_perc(foe["hit"], rng):
                        t["m"]["hp"] = max(0, t["m"]["hp"] - max(1, coin(foe["dmg"], rng)))
                        if t["m"]["hp"] > 0 and roll_perc(15 * LUCK_MOD, rng):
                            foe["hp"] = max(0, foe["hp"] - 1)
            alive_n = sum(1 for p in party if p["m"]["hp"] > 0)
            if foe["hp"] <= 0 or alive_n == 0:
                return foe["hp"] <= 0 and alive_n > 0
    return False


def pick(weights, rng):
    tot = sum(weights.values())
    r = rng.random() * tot
    for k, w in weights.items():
        r -= w
        if r <= 0: return k
    return list(weights)[-1]


def trip(n, tier, biome, rng, rar=0, bond_mean=0):
    """exped_tick_one's delve: five rooms. Returns dict(routed, finds, wins, hp_left, rooms)."""
    crew = [{"hp": HP0 + rar * 2, "hpmax": HP0 + rar * 2, "pace": rng.choice(PACES)} for _ in range(n)]
    rooms = [pick(BIOMES[biome], rng) for _ in range(EXPED_ROOMS)]
    finds = wins = 0
    routed = False
    for kind in rooms:
        if kind == "find":
            finds += 1
        elif kind == "rest":
            for m in crew:
                if m["hp"] > 0: m["hp"] = min(m["hpmax"], m["hp"] + 3)
        elif kind == "trap":
            dmg = 1 + rng.randint(0, tier)
            up = [m for m in crew if m["hp"] > 0]
            who = rng.choice(up) if up else crew[0]
            who["hp"] = max(0, who["hp"] - dmg)
            if all(m["hp"] <= 0 for m in crew): routed = True
        else:
            if fight(crew, tier, bond_mean, rng): wins += 1
            else: routed = True
        if routed: break
    return {"routed": routed, "finds": finds, "wins": wins,
            "hp_left": sum(m["hp"] for m in crew) / sum(m["hpmax"] for m in crew), "rooms": rooms}


def duration(tier, routed_at=None):
    return EXPED_DIST0 * 2 ** (tier - 1)


# ======================================================================
print(__doc__.strip().splitlines()[0])
print("=" * 74)
rng = random.Random(7)
N = 3000

# --- 1. THE DANGER TABLE ------------------------------------------------
print()
print("1. ROUT RATE  (crew size x tier, %d trips each, all biomes mixed, common sprites, no bonds)" % N)
print("      %-6s" % "crew" + "".join("%9s" % ("tier %d" % t) for t in (1, 2, 3, 4)))
rout = {}
for n in (1, 2, 3):
    row = []
    for t in (1, 2, 3, 4):
        r = 0
        for _ in range(N):
            b = rng.choice(list(BIOMES))
            if trip(n, t, b, rng)["routed"]: r += 1
        rout[(n, t)] = r / N
        row.append("%8.0f%%" % (100 * r / N))
    print("      %-6d" % n + "".join(row))
say(rout[(1, 1)] < .25, "a solo tier-1 trip routs under a quarter of the time", "%.0f%%" % (100 * rout[(1, 1)]))
say(rout[(1, 3)] > rout[(1, 1)] + .2, "a solo trip gets clearly more dangerous by tier 3", "t1 %.0f%% -> t3 %.0f%%" % (100 * rout[(1, 1)], 100 * rout[(1, 3)]))
say(rout[(3, 3)] < rout[(1, 3)] - .15, "three make a tier-3 world safer than one does", "solo %.0f%% -> three %.0f%%" % (100 * rout[(1, 3)], 100 * rout[(3, 3)]))
say(rout[(3, 4)] > .15, "...but tier 4 still bites a crew of three", "%.0f%%" % (100 * rout[(3, 4)]))
say(rout[(1, 1)] > .03, "and a solo tier-1 trip is not free either", "%.0f%%" % (100 * rout[(1, 1)]))

# --- 2. BY BIOME ------------------------------------------------------
print()
print("2. BY BIOME  (solo, tier 2)")
for b in BIOMES:
    r = f = 0
    for _ in range(N):
        tr = trip(1, 2, b, rng)
        r += tr["routed"]; f += tr["finds"]
    print("      %-8s rout %3.0f%%   finds/trip %.2f   rooms %s" % (b, 100 * r / N, f / N,
          " ".join("%s %.0f" % (k, v) for k, v in BIOMES[b].items())))

# --- 3. A FIGHT ON ITS OWN ---------------------------------------------
print()
print("3. ONE FIGHT  (fresh crew, mean pace, win %% by crew size x tier)")
print("      %-6s" % "crew" + "".join("%9s" % ("tier %d" % t) for t in (1, 2, 3, 4)))
fw = {}
for n in (1, 2, 3):
    row = []
    for t in (1, 2, 3, 4):
        w = 0
        for _ in range(N):
            crew = [{"hp": HP0, "hpmax": HP0, "pace": rng.choice(PACES)} for _ in range(n)]
            if fight(crew, t, 0, rng): w += 1
        fw[(n, t)] = w / N
        row.append("%8.0f%%" % (100 * w / N))
    print("      %-6d" % n + "".join(row))
say(fw[(1, 1)] > .7, "a fresh solo wins a tier-1 fight most of the time", "%.0f%%" % (100 * fw[(1, 1)]))
say(fw[(1, 4)] < .5, "a fresh solo loses a tier-4 fight more often than not", "%.0f%%" % (100 * fw[(1, 4)]))
say(fw[(3, 3)] < .995 and fw[(3, 4)] < .8, "three still lose fights at the frontier - a crew is not a formality",
    "t3 %.0f%%, t4 %.0f%%" % (100 * fw[(3, 3)], 100 * fw[(3, 4)]))
say(fw[(1, 2)] > .8 and fw[(1, 3)] > .4, "one sprite can take a tier-2 fight, and has a real chance at tier 3",
    "t2 %.0f%%, t3 %.0f%%" % (100 * fw[(1, 2)], 100 * fw[(1, 3)]))

# --- 4. BONDS ---------------------------------------------------------
print()
print("4. BONDS  (a pair that always goes together, tier-1 worlds; exped_bond_add)")
bond = 0
trips_to = {"mates": None, "inseparable": None}
hist = []
for k in range(1, 40):
    tr = trip(2, 1, rng.choice(list(BIOMES)), rng, bond_mean=bond)
    bond = max(0, min(100, bond + BOND_TRIP + BOND_WIN * tr["wins"] - (BOND_ROUT if tr["routed"] else 0)))
    hist.append(bond)
    if trips_to["mates"] is None and bond >= 25: trips_to["mates"] = k
    if trips_to["inseparable"] is None and bond >= 60: trips_to["inseparable"] = k
print("      after trips 1..12: " + " ".join(str(int(b)) for b in hist[:12]))
say(trips_to["mates"] is not None and 3 <= trips_to["mates"] <= 6, "mates (25) inside three to six trips together", "trip %s" % trips_to["mates"])
say(trips_to["inseparable"] is not None and 7 <= trips_to["inseparable"] <= 14, "inseparable (60) inside seven to fourteen", "trip %s" % trips_to["inseparable"])
# the bonus's worth: the same pair at tier 3, bond 0 vs bond 100
r0 = sum(trip(2, 3, "stone", rng, bond_mean=0)["routed"] for _ in range(N)) / N
r1 = sum(trip(2, 3, "stone", rng, bond_mean=100)["routed"] for _ in range(N)) / N
say(r1 < r0, "an inseparable pair routs less than strangers do", "%.0f%% -> %.0f%% at tier 3" % (100 * r0, 100 * r1))
say(r0 - r1 < .15, "...but the bond is a lean, not a cheat", "%.0f points" % (100 * (r0 - r1)))

# --- 5. THE CLOCK AND THE LOOT --------------------------------------
print()
print("5. THE CLOCK  (a tier's trip length, and finds per HOUR of clock at x1)")
print("      %-6s %10s %12s %12s %10s" % ("tier", "trip", "finds/trip", "finds/hour", "rout"))
fph = {}
for t in (1, 2, 3, 4):
    f = r = 0
    for _ in range(N):
        tr = trip(1, t, rng.choice(list(BIOMES)), rng)
        f += tr["finds"]; r += tr["routed"]
    d = duration(t)
    fph[t] = (f / N) / (d / 3600)
    print("      %-6d %9.0fs %12.2f %12.1f %9.0f%%" % (t, d, f / N, fph[t], 100 * r / N))
say(fph[1] > fph[4], "a tier-1 world pays more FINDS an hour than tier 4 (tier pays in rarity and tier, not count)",
    "%.1f vs %.1f" % (fph[1], fph[4]))
say(duration(4) <= 3600, "the longest world on offer is under an hour at x1 (the mock's scale)", "%.0fs" % duration(4))

# --- 6. RARITY HELPS ---------------------------------------------------
print()
print("6. A RARE SPRITE  (hp %d + 2 x rung: solo tier-3 rout by rarity)" % HP0)
rr = {}
for rar in (0, 3, 7):
    rr[rar] = sum(trip(1, 3, "living", rng, rar=rar)["routed"] for _ in range(N)) / N
    print("      rung %d  hp %2d  rout %3.0f%%" % (rar, HP0 + 2 * rar, 100 * rr[rar]))
say(rr[7] < rr[0] - .2, "an ultimate survives tier 3 far better than a common", "%.0f%% -> %.0f%%" % (100 * rr[0], 100 * rr[7]))

print()
print("=" * 74)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
