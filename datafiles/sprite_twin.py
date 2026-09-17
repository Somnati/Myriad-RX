"""sprite_twin.py - THE SPRITE SHEET'S TWIN (2026-09-14, his pitch: classes,
levels, gear, the tech demo's combat engine). A Python replica of cbt_hit /
cbt_fight_turn / cbt_ai, sprite_stats / sprite_pawn, foe_gen and the xp law
(sprite_xp_need / sprite_xp_quest), so the balance can be read without a
build. Reads the macros from main_macros so a knob moved there moves here.

Prints:
  1. class vs the roster at par (1 v 1, same level): win rate per class per foe
  2. a party of three at par: rout rate by level
  3. up-level / down-level: a level-5 warrior vs level 8 and level 2 foes
  4. the ladder: kills a level (his SPRITE_LV_KILLS), quests a level
  5. HOLDS / FAILS on the claims the design makes
The abilities (2026-09-17, the evilities) are mirrored too: rungs by level
off the pawn's rng, the newest four worn, their lanes on the pawn.
The elements pass (2026-09-17) is mirrored: every pawn a signed resistance
table (+20 / -20 off the triangle for an elemental kind, a random pair
otherwise), skills carrying fire / water / nature, the ailments (poison /
slow / leech), light's buffs against dark's nerfs cancelling, the cantor.

Tune here, port back. Run: python datafiles/sprite_twin.py
"""
import math, random, re, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
def macro(name, default):
    s = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
    m = re.search(r"#macro\s+%s\s+([-.\d]+)" % name, s)
    return float(m.group(1)) if m else default
LV_KILLS = macro("SPRITE_LV_KILLS", 30)
LV_PTS   = macro("SPRITE_LV_PTS", 3)
XP_PT    = macro("SPRITE_XP_PER_PT", 1)
Q_LO     = macro("SPRITE_QUEST_XP_LO", 2)
Q_HI     = macro("SPRITE_QUEST_XP_HI", 5)
ROOMS    = int(macro("EXPED_ROOMS", 5))
FOE_B    = macro("SPRITE_FOE_BUDGET", .9)

BAL = dict(hitcurve_a=-160, hitcurve_b=250, hp_per_point=3.75, hp_flat_add=4, spd_to_eva=.5,
           tic_spd_base=1, tic_spd_div=2, def_div=3, def_lerp_low=.8, dmg_lerp_low=.4, dmg_lerp_high=1.1,
           perf_lerp_high=1.2, crit_lerp_low=.4, crit_lerp_high=1, ttk_multi=1.4, dmg_to_maxhp=.1,
           mp_gain=1, mp_gain_qual=2, mp_start_frac=.5, cnt_mult=.7, cnt_falloff=.5, cnt_chain=3,
           # the elements pass (2026-09-17): cbt_balance's knobs, mirrored
           res_step=20, res_min=-50, res_max=50, fire_bonus=1.1, ail_skill=60, ail_basic=20, ail_turns=3, boss_ail=.5,
           poison_pct=.04, slow_rate=.6, haste_rate=1.25, leech_pct=.4, buff_pct=.25, buff_turns=3, regen_pct=.05)
ELEMS = ["fire", "water", "nature"]
BEATS = {"fire": "nature", "water": "fire", "nature": "water"}
WEAK  = {"fire": "water", "water": "nature", "nature": "fire"}
# ---- the abilities (2026-09-17, the evilities): ability_config / ability_unlocks / ability_gen, mirrored ----
ABIL = [  # (key, tier, lane, lo, hi, pair, cost_lane, cost_v)
    ("stout", 1, "hp", 4, 8), ("brawn", 1, "atk", 4, 8), ("bookish", 1, "mag", 4, 8), ("thickskin", 1, "def", 4, 8),
    ("warded", 1, "mdef", 4, 8), ("quick", 1, "spd", 4, 8), ("keeneye", 1, "hit", 4, 8), ("lucky", 1, "luck", 1, 1),
    ("fireproof", 1, "res_fire", 6, 10), ("waterproof", 1, "res_water", 6, 10), ("thornproof", 1, "res_nature", 6, 10),
    ("vicious", 2, "crit", 3, 6), ("spiteful", 2, "cnt", 4, 8), ("venomous", 2, "ail_poison", 10, 18), ("chilling", 2, "ail_slow", 10, 18),
    ("antidote", 2, "immune_poison", 1, 1), ("surefoot", 2, "immune_slow", 1, 1), ("unmarked", 2, "immune_leech", 1, 1),
    ("adrenal", 2, "low_atk", 15, 30), ("mending", 2, "regen", 1, 2),
    ("fleet", 3, "tic", 8, 14), ("bane", 3, "boss", 12, 20), ("scholar", 3, "xp", 15, 30), ("aegis", 3, "res_all", 5, 8),
    ("vampiric", 3, "life", 8, 15), ("elemental", 3, "elemdmg", 8, 15), ("berserk", 3, "atk", 15, 25, None, "def", -8),
    ("titan", 4, "atk", 12, 18, "def"), ("savant", 4, "mag", 12, 18, "mdef"), ("undying", 4, "undying", 1, 1), ("swift", 4, "crit", 6, 10, "tic"),
]
ABIL_LADDER = [(1, 1), (4, 1), (8, 1), (14, 2), (20, 2), (30, 3), (45, 3), (60, 3), (80, 4), (100, 4)]
ABIL_RMULT = [1, 1.3, 1.6, 2, 2.4, 2.8, 3.2, 3.6]
def rarity_roll(rng, rate):
    # calculate_rarity's shape, near enough: a geometric walk up the rungs
    r = 0; p = .3
    while r < 7 and rng.random() < p: r += 1; p *= .55
    return r
def ability_gen(rng, maxtier):
    pool = [(a, 3 if a[1] == maxtier else 1) for a in ABIL if a[1] <= maxtier]
    tot = sum(w for _, w in pool); x = rng.random() * tot; pick = pool[0][0]
    for a, w in pool:
        if x < w: pick = a; break
        x -= w
    rar = rarity_roll(rng, 100 + maxtier * 40)
    lo, hi = pick[3], pick[4]
    val = round((lo + (hi - lo) * rng.random()) * ABIL_RMULT[rar] * 10) / 10
    if pick[2].startswith("immune") or pick[2] in ("undying", "luck"): val = max(1, round(val))
    return dict(key=pick[0], tier=pick[1], lane=pick[2], val=val, pair=(pick[5] if len(pick) > 5 else None),
                cost=((pick[6], pick[7]) if len(pick) > 7 else None))
def ability_effects(lst):
    o = dict(hp=0, atk=0, mag=0, def_=0, mdef=0, spd=0, hit=0, crit=0, cnt=0, luck=0, res={"fire": 0, "water": 0, "nature": 0},
             immune=[], ail="", ailc=0, low_atk=0, boss=0, xp=0, tic=0, life=0, elemdmg=0, regen=0, undying=False)
    def lane(k): return "def_" if k == "def" else k
    for a in lst:
        ln, v = a["lane"], a["val"]
        if ln.startswith("res_"):
            if ln == "res_all":
                for e in o["res"]: o["res"][e] += v
            else: o["res"][ln[4:]] += v
        elif ln.startswith("immune_"): o["immune"].append(ln[7:])
        elif ln.startswith("ail_"):
            if v > o["ailc"]: o["ail"], o["ailc"] = ln[4:], v
        elif ln == "undying": o["undying"] = True
        else: o[lane(ln)] += v
        if a["pair"]: o[lane(a["pair"])] += v
        if a["cost"]: o[lane(a["cost"][0])] += a["cost"][1]
    return o
def abilities_for(rng, lv, n=4):
    lst = [ability_gen(rng, t) for (l, t) in ABIL_LADDER if lv >= l]
    return lst[-n:] if len(lst) > n else lst

def res_gen(rng, elem=""):
    r = {"fire": 0, "water": 0, "nature": 0}
    if elem in BEATS: r[WEAK[elem]] = -BAL["res_step"]; r[BEATS[elem]] = BAL["res_step"]; return r
    w = rng.randrange(3); st = (w + 1 + rng.randrange(2)) % 3
    r[ELEMS[w]] = -BAL["res_step"]; r[ELEMS[st]] = BAL["res_step"]; return r
KEYS = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"]

# sprite_classes (the shapes must match the GML table)
CLASSES = {
    "warrior": dict(shape={"hp":7,"mp":3,"atk":7,"mag":1,"def":6,"mdef":2,"spd":4,"hit":7}, crit=6,  cmulti=1.6, cnt=8,  magic=False, skill="strike",  tmpls=[0, 3, 6]),
    "mage":    dict(shape={"hp":4,"mp":6,"atk":2,"mag":8,"def":2,"mdef":6,"spd":4,"hit":6}, crit=5,  cmulti=1.8, cnt=2,  magic=True,  skill="bolt",    tmpls=[4, 4, 7, 1]),
    "rogue":   dict(shape={"hp":5,"mp":4,"atk":6,"mag":2,"def":4,"mdef":3,"spd":7,"hit":7}, crit=14, cmulti=1.8, cnt=10, magic=False, skill="concuss", tmpls=[1, 3, 5, 7]),
    "cleric":  dict(shape={"hp":6,"mp":6,"atk":3,"mag":6,"def":5,"mdef":6,"spd":3,"hit":5}, crit=3,  cmulti=1.5, cnt=3,  magic=True,  skill="mend",    tmpls=[2, 4, 6, 8]),
    "ranger":  dict(shape={"hp":5,"mp":4,"atk":6,"mag":3,"def":4,"mdef":4,"spd":6,"hit":7}, crit=10, cmulti=1.7, cnt=6,  magic=False, skill="strike",  tmpls=[3, 0, 5]),
}
# foe_gen's roster
FOES = {
    "goblin":   dict(shape={"hp":5,"mp":3,"atk":6,"mag":2,"def":5,"mdef":3,"spd":7,"hit":7},  crit=8,  cmulti=1.6, cnt=8,  erode=1,   magic=False, skill="concuss", gear=.3),
    "bandit":   dict(shape={"hp":6,"mp":3,"atk":7,"mag":1,"def":6,"mdef":3,"spd":5,"hit":7},  crit=7,  cmulti=1.6, cnt=7,  erode=1,   magic=False, skill="strike",  gear=.8),
    "wolf":     dict(shape={"hp":6,"mp":2,"atk":7,"mag":1,"def":3,"mdef":2,"spd":8,"hit":7}, crit=10, cmulti=1.7, cnt=5,  erode=1,   magic=False, skill="",        gear=0),
    "slime":    dict(shape={"hp":8,"mp":6,"atk":3,"mag":3,"def":6,"mdef":6,"spd":2,"hit":4}, crit=5,  cmulti=1.5, cnt=4,  erode=.25, magic=False, skill="reform",  gear=0, elem="water", ail="slow", tags=["slime"]),
    "skeleton": dict(shape={"hp":6,"mp":4,"atk":8,"mag":1,"def":6,"mdef":4,"spd":3,"hit":6},  crit=8,  cmulti=1.8, cnt=6,  erode=1,   magic=False, skill="strike",  gear=.5, school="dark", tags=["undead"]),
    "wisp":     dict(shape={"hp":3,"mp":6,"atk":2,"mag":8,"def":2,"mdef":6,"spd":5,"hit":6},  crit=6,  cmulti=1.8, cnt=2,  erode=1,   magic=True,  skill="drain",   gear=0, elem="nature"),
    "rat":      dict(shape={"hp":5,"mp":4,"atk":6,"mag":1,"def":4,"mdef":2,"spd":7,"hit":8}, crit=10, cmulti=1.6, cnt=12, erode=1,   magic=False, skill="concuss", gear=.1),
    # the cantor (2026-09-17): the light kind that mends its pack
    "cantor":   dict(shape={"hp":4,"mp":7,"atk":2,"mag":6,"def":5,"mdef":6,"spd":4,"hit":5},  crit=4,  cmulti=1.5, cnt=2,  erode=1,   magic=True,  skill="mend",    gear=.2, school="light"),
}
def eff(shape): return sum(v if v <= 6 else 6 + 2 * (v - 6) for v in shape.values())
for n, c in list(CLASSES.items()) + list(FOES.items()):
    assert eff(c["shape"]) == 40, (n, eff(c["shape"]))

def par_pts(lv): return 40 + LV_PTS * (max(1, lv) - 1)
def foe_xp(pts): return round(pts / (par_pts(1) * FOE_B) * XP_PT * 10) / 10   # v2: a level-1 par foe pays 1
def xp_need(lv): return max(1, round(LV_KILLS * par_pts(lv) / par_pts(1) * XP_PT))
def xp_quest(lv, done=1): return round(par_pts(lv) / par_pts(1) * XP_PT * (Q_LO + (Q_HI - Q_LO) * max(0, min(1, done))) * 10) / 10

# ---- gear_gen's points (the names do not matter here) ----
FAM = {  # slot -> [(lines)]
    "w1": [{"atk":3,"hit":1}, {"atk":4}, {"atk":3,"def":1}, {"atk":2,"spd":1,"hit":1}, {"mag":3,"mp":1}, {"mag":2,"hit":2}, {"atk":2,"hit":2}, {"atk":2,"spd":1,"hit":1}],
    "armor": [{"def":4,"hp":2}, {"def":3,"hp":1,"mdef":1}, {"def":2,"spd":2}, {"mdef":3,"mp":2,"def":1}, {"mdef":2,"spd":2,"hit":1}, {"hp":3,"def":2}],
}
def gear_pts(slot, lv, rar, rng):
    lines = rng.choice(FAM[slot])
    budget = (1.5 + .5 * max(1, lv)) * (1 + .4 * rar)
    ws = sum(lines.values())
    return {k: round(budget * v / ws * rng.uniform(.85, 1.15), 1) for k, v in lines.items()}

class Skill:
    def __init__(self, name, cost, targ, magic, mult=0, leech=0, healp=0, stag=0, kind="", elem="", school="", ail="", buf="", nerf=""):
        self.name, self.cost, self.targ, self.magic = name, cost, targ, magic
        self.mult, self.leech, self.healp, self.stag, self.kind = mult, leech, healp, stag, kind
        self.elem, self.school, self.ail, self.buf, self.nerf = elem, school, ail, buf, nerf
LIB = {
    "strike":  Skill("strike", 3, "enemy", False, mult=1.6, kind="strike"),
    "reform":  Skill("reform", 4, "self", False, kind="reform", school="light"),
    "drain":   Skill("drain", 3, "enemy", True, mult=.8, leech=.6, kind="drain", school="dark", ail="leech"),
    "mend":    Skill("mend", 4, "ally", True, kind="mend", school="light"),
    "concuss": Skill("concuss", 3, "enemy", False, mult=.7, stag=.45, kind="concuss"),
    "bolt":    Skill("bolt", 3, "enemy", True, mult=1.5, kind="bolt", elem="nature"),
}
def skill_gen(tmpl, rng):
    if tmpl == 0: return Skill("gen-heavy", rng.randint(3, 5), "enemy", False, mult=rng.uniform(1.4, 2.1), kind="heavy", elem=(rng.choice(ELEMS) if rng.random() < .34 else ""))
    if tmpl == 1: return Skill("gen-drain", rng.randint(3, 5), "enemy", True, mult=rng.uniform(.6, 1.0), leech=rng.uniform(.4, .8), kind="drain", school="dark", ail="leech")
    if tmpl == 2: return Skill("gen-heal", rng.randint(4, 6), "ally", True, healp=rng.uniform(.28, .5), kind="heal", school="light")
    if tmpl == 3: return Skill("gen-stagger", rng.randint(2, 4), "enemy", False, mult=rng.uniform(.55, .8), stag=rng.uniform(.3, .6), kind="stagger")
    if tmpl == 4: return Skill("gen-spell", rng.randint(3, 5), "enemy", True, mult=rng.uniform(1.3, 1.9), kind="spell", elem=rng.choice(ELEMS))
    if tmpl == 5:
        poison = rng.random() < .5
        return Skill("gen-venom", rng.randint(3, 4), "enemy", False, mult=rng.uniform(.8, 1.1), kind="venom", elem=("nature" if poison else "water"), ail=("poison" if poison else "slow"))
    if tmpl == 6: return Skill("gen-bless", rng.randint(3, 5), "ally", True, kind="bless", school="light", buf=rng.choice(["buf_atk", "buf_def", "buf_hit", "haste"]))
    if tmpl == 7: return Skill("gen-hex", rng.randint(3, 5), "enemy", True, mult=rng.uniform(.4, .6), kind="hex", school="dark", nerf=rng.choice(["nerf_atk", "nerf_def", "nerf_hit"]))
    return Skill("gen-cleanse", rng.randint(4, 6), "ally", True, healp=rng.uniform(.12, .2), kind="cleanse", school="light")

class Pawn:
    def __init__(self, name, arch, lv, team, rng, gear=None, boss=False, skills=None):
        budget = par_pts(lv) * (FOE_B if team == 1 else 1) * (1.4 if boss else 1)
        pts = {k: arch["shape"][k] * budget / 40 for k in KEYS}
        for it in (gear or []):
            for k, v in it.items(): pts[k] += v
        # the abilities (2026-09-17): the rungs the level has passed, the newest four worn
        ab = ability_effects(abilities_for(rng, lv, 4))
        for k in ("atk", "mag", "def", "mdef", "spd", "hit"): pts[k] *= 1 + ab["def_" if k == "def" else k] / 100
        self.ab = ab
        self.name, self.team, self.lv = name, team, lv
        self.pts_total = sum(pts.values())
        self.maxhp = math.floor(pts["hp"] * BAL["hp_per_point"] * (1 + ab["hp"] / 100) + BAL["hp_flat_add"])   # (whole hp, 2026-09-15 - sprite_pawn / foe_gen floor it)
        self.hp = self.maxhp
        self.maxmp = max(1, round(pts["mp"])); self.mp = math.ceil(self.maxmp * BAL["mp_start_frac"])
        self.atk, self.def_, self.mag, self.mdef, self.spd, self.hit = pts["atk"], pts["def"], pts["mag"], pts["mdef"], pts["spd"], pts["hit"]
        self.eva = pts["spd"] * BAL["spd_to_eva"]
        self.crit_rate, self.crit_multi, self.cnt = arch["crit"] + ab["crit"] + ab["luck"] * .5, arch["cmulti"], arch["cnt"] + ab["cnt"]
        self.erode = arch.get("erode", 1)
        self.magic = arch["magic"]
        self.skills = skills if skills is not None else ([LIB[arch["skill"]]] if arch["skill"] else [])
        self.tic = rng.random() * .3
        self.tic_spd = (BAL["tic_spd_base"] + math.sqrt(max(0, pts["spd"])) / BAL["tic_spd_div"]) * (1 + ab["tic"] / 100)
        # the elements pass (2026-09-17): the table, the bite, the clocks
        self.elem = arch.get("elem", ""); self.ail_k = arch.get("ail", "") or ab["ail"]; self.ail_c = 0 if arch.get("ail", "") else ab["ailc"]
        self.tags = list(arch.get("tags", [])) + ["immune_" + k for k in ab["immune"]]; self.boss = boss
        self.res = res_gen(rng, self.elem if team == 1 else "")
        for e in self.res: self.res[e] = max(BAL["res_min"], min(BAL["res_max"], self.res[e] + ab["res"][e]))
        self.undying_used = False
        self.ail = {"poison": 0, "slow": 0, "leech": 0}; self.bf = {"atk": 0, "def": 0, "hit": 0, "spd": 0}; self.nf = {"atk": 0, "def": 0, "hit": 0}
        self.regen = 0; self.leecher = None

def sprite_pawn(cls, lv, rng, gear=None):
    c = CLASSES[cls]
    sk = [LIB[c["skill"]]]
    n = max(1, min(3, 1 + lv // 10))
    for i in range(n): sk.append(skill_gen(c["tmpls"][i % len(c["tmpls"])], rng))
    return Pawn(cls, c, lv, 0, rng, gear=gear, skills=sk)

def foe_pawn(kind, lv, rng, boss=False):
    f = FOES[kind]
    gear = []
    if rng.random() < f["gear"]:
        gear.append(gear_pts("w1", lv, 1 if rng.random() < .25 else 0, rng))
        if rng.random() < .6: gear.append(gear_pts("armor", lv, 1 if rng.random() < .25 else 0, rng))
    return Pawn(kind, f, lv, 1, rng, gear=gear, boss=boss)

class Fight:
    def __init__(self, party, foes, rng):
        self.party, self.foes, self.all = party, foes, party + foes
        self.rng = rng; self.turn = 0; self.over = False; self.won = False; self.thr = 1
    def status(self, u, t, key):
        b = BAL
        if t.hp <= 0: return False
        undead = "undead" in t.tags; slime = "slime" in t.tags
        if ("immune_" + key) in t.tags: return False
        turns = max(1, round(b["ail_turns"] * (b["boss_ail"] if t.boss else 1)))
        bturns = max(1, round(b["buff_turns"] * (b["boss_ail"] if (t.boss and t.team == 1) else 1)))
        if key == "poison":
            if undead or slime: return False
            t.ail["poison"] = turns; return True
        if key == "slow":
            if t.bf["spd"] > 0: t.bf["spd"] = 0; return True
            t.ail["slow"] = turns; return True
        if key == "leech":
            if undead: return False
            t.ail["leech"] = turns; t.leecher = u; return True
        if key == "regen": t.regen = bturns; return True
        if key == "haste":
            if t.ail["slow"] > 0: t.ail["slow"] = 0; return True
            t.bf["spd"] = bturns; return True
        if key.startswith("buf_"):
            k = key[4:]
            if t.nf[k] > 0: t.nf[k] = 0; return True
            t.bf[k] = bturns; return True
        if key.startswith("nerf_"):
            k = key[5:]
            if t.bf[k] > 0: t.bf[k] = 0; return True
            t.nf[k] = bturns; return True
        return False
    def purge(self, t, school, one=False):
        if school == "light":
            if one:
                for k in ("poison", "slow", "leech"):
                    if t.ail[k] > 0: t.ail[k] = 0; return 1
                return 0
            for k in t.ail: t.ail[k] = 0
            for k in t.nf: t.nf[k] = 0
            t.leecher = None
        else:
            for k in t.bf: t.bf[k] = 0
            t.regen = 0
        return 1
    def hit(self, u, t, mult=1, label="", cdepth=0, magic=False, elem=None, ail=""):
        b, rng = BAL, self.rng
        basic = (label == "" and cdepth == 0)
        if elem is None: elem = u.elem
        if ail == "" and basic: ail = u.ail_k
        m_atk = 1 + (b["buff_pct"] if u.bf["atk"] > 0 else 0) - (b["buff_pct"] if u.nf["atk"] > 0 else 0)
        if u.ab["low_atk"] > 0 and u.hp < u.maxhp * .35: m_atk += u.ab["low_atk"] / 100
        m_hit = 1 + (b["buff_pct"] if u.bf["hit"] > 0 else 0) - (b["buff_pct"] if u.nf["hit"] > 0 else 0)
        m_def = 1 + (b["buff_pct"] if t.bf["def"] > 0 else 0) - (b["buff_pct"] if t.nf["def"] > 0 else 0)
        apow = (u.mag if magic else u.atk) * m_atk
        dpow = (t.mdef if magic else t.def_) * m_def
        uhit = u.hit * m_hit
        s = uhit + t.eva
        hc = 50
        if s > 0:
            r = uhit / s
            hc = max(1, min(99, b["hitcurve_a"] * r * r + b["hitcurve_b"] * r))
        roll = rng.random() * 100
        if roll >= hc: return 0
        q = (hc - roll) / hc
        crit = rng.random() * 100 < u.crit_rate
        dmg = apow * mult
        dmg -= (dpow * (1 + (b["def_lerp_low"] - 1) * q)) / b["def_div"]
        lo = dmg * b["dmg_lerp_low"]
        hi = dmg * (b["perf_lerp_high"] if q >= .97 else b["dmg_lerp_high"])
        dmg = lo + (hi - lo) * q
        if crit:
            cl = (u.crit_multi - 1) * b["crit_lerp_low"]; ch = (u.crit_multi - 1) * b["crit_lerp_high"]
            dmg *= 1 + cl + (ch - cl) * q
        dmg *= b["ttk_multi"]
        if elem in BEATS:
            rs = max(b["res_min"], min(b["res_max"], t.res[elem]))
            dmg *= 1 - rs / 100
        if elem == "fire": dmg *= b["fire_bonus"]
        if u.ab["boss"] > 0 and t.boss: dmg *= 1 + u.ab["boss"] / 100
        if u.ab["elemdmg"] > 0 and elem in BEATS and not basic: dmg *= 1 + u.ab["elemdmg"] / 100
        dmg = max(.1, round(dmg * 10) / 10)
        stag = (1 + t.spd / 3) * (.01 + ((.085 if q >= .97 else .05) - .01) * q)
        if crit: stag += (1 + t.spd / 3) * .03
        t.tic -= stag * self.thr
        t.hp = max(0, t.hp - dmg)
        if t.hp <= 0 and t.ab["undying"] and not t.undying_used: t.hp = 1; t.undying_used = True
        t.maxhp = max(1, t.maxhp - dmg * b["dmg_to_maxhp"] * t.erode)
        if t.hp > t.maxhp: t.hp = t.maxhp
        if u.ab["life"] > 0 and u.hp > 0: self.heal(u, dmg * u.ab["life"] / 100)
        if t.ail["leech"] > 0 and t.leecher is u and u.hp > 0: self.heal(u, dmg * b["leech_pct"])
        if ail != "" and t.hp > 0:
            ch = (b["ail_basic"] if basic else b["ail_skill"])
            if basic and u.ail_c > 0: ch = u.ail_c
            if rng.random() * 100 < ch: self.status(u, t, ail)
        if label == "" and cdepth == 0:
            u.mp = min(u.maxmp, u.mp + (b["mp_gain_qual"] if (q >= .85 or crit) else b["mp_gain"]))
        if t.hp > 0 and cdepth < b["cnt_chain"]:
            if rng.random() * 100 < t.cnt * (b["cnt_falloff"] ** cdepth):
                self.hit(t, u, b["cnt_mult"], "", cdepth + 1, False)
        return dmg
    def heal(self, t, amt):
        if t.hp <= 0: return 0   # the down stay down (the engine's rule, 2026-09-15)
        amt = max(0, round(amt * 10) / 10)
        before = t.hp; t.hp = min(t.maxhp, t.hp + amt)
        return round((t.hp - before) * 10) / 10
    def score(self, s, u, t):
        if s.kind in ("strike", "heavy"):
            sc = 50 + t.def_ * 2 + (max(0, s.mult - 1.4)) * 20 + (5 if s.kind == "strike" else 0)
            if t.hp < t.maxhp * .35: sc += 25
            return sc
        if s.kind == "reform": return 0 if u.hp > u.maxhp * .35 else 85
        if s.kind == "drain": return 40 + (1 - u.hp / u.maxhp) * 45
        if s.kind == "mend": return (1 - t.hp / t.maxhp) * 95 + (20 if any(v > 0 for v in t.ail.values()) else 0)
        if s.kind == "heal": return (1 - t.hp / t.maxhp) * (80 + s.healp * 40) + (20 if any(v > 0 for v in t.ail.values()) else 0)
        if s.kind in ("concuss", "stagger"): return 35 + t.spd * 4 + (t.tic / self.thr) * 25
        if s.kind in ("bolt", "spell"):
            sc = 50 + t.def_ * 2 - t.mdef + max(0, s.mult - 1.3) * 20
            if t.hp < t.maxhp * .35: sc += 20
            if s.elem: sc -= t.res[s.elem] * .5
            return sc
        if s.kind == "venom":
            sc = 40 + (t.maxhp / max(1, u.maxhp)) * 10
            if t.ail[s.ail] > 0: sc = 12
            sc -= t.res[s.elem] * .5
            return sc
        if s.kind == "bless":
            on = t.bf["spd"] > 0 if s.buf == "haste" else t.bf[s.buf[4:]] > 0
            if on: return 0
            sc = 42 + (t.hp / t.maxhp) * 10
            if s.buf != "haste" and t.nf[s.buf[4:]] > 0: sc += 25
            return sc
        if s.kind == "hex":
            k = s.nerf[5:]
            if t.nf[k] > 0: return 10
            sc = 40 + (t.def_ if k == "def" else (t.atk if k == "atk" else t.hit)) * 2
            if t.bf[k] > 0: sc += 25
            return sc
        if s.kind == "cleanse":
            dark = sum(1 for v in t.ail.values() if v > 0) + sum(1 for v in t.nf.values() if v > 0)
            if dark == 0: return 0
            return 55 + dark * 15 + (1 - t.hp / t.maxhp) * 20
        return 0
    def ai(self, u):
        rng = self.rng; best = None; bs = -1e9
        for t in self.all:
            if t.team == u.team or t.hp <= 0: continue
            sc = 50 + (1 - t.hp / t.maxhp) * 30 + rng.random() * 12
            if sc > bs: bs, best = sc, (None, t)
        for s in u.skills:
            if u.mp < s.cost: continue
            if s.kind == "reform" and not (u.hp < u.maxhp): continue
            for t in self.all:
                if t.hp <= 0: continue
                if s.targ == "enemy" and t.team == u.team: continue
                if s.targ == "ally" and t.team != u.team: continue
                if s.targ == "self" and t is not u: continue
                sc = self.score(s, u, t)
                if sc <= 0: continue
                sc += rng.random() * 10
                if sc > bs: bs, best = sc, (s, t)
        return best
    def effect(self, s, u, t):
        if s.kind in ("strike", "heavy", "bolt", "spell"): self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
        elif s.kind == "reform": self.heal(u, u.maxhp * .4)
        elif s.kind == "drain":
            d = self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem, "leech")
            if d > 0: self.heal(u, d * (s.leech or .6))
        elif s.kind == "mend": self.heal(t, t.maxhp * .35); self.purge(t, "light", True)
        elif s.kind == "heal": self.heal(t, t.maxhp * s.healp); self.purge(t, "light", True)
        elif s.kind in ("concuss", "stagger"):
            d = self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
            if d > 0: t.tic -= self.thr * (s.stag or .45)
        elif s.kind == "venom": self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem, s.ail)
        elif s.kind == "bless": self.status(u, t, s.buf)
        elif s.kind == "hex":
            d = self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
            if d > 0: self.status(u, t, s.nerf)
        elif s.kind == "cleanse": self.heal(t, t.maxhp * s.healp); self.purge(t, "light", False)
    def step(self):
        if self.over: return
        th = 1
        for p in self.all:
            if p.hp > 0 and p.tic_spd > th: th = p.tic_spd
        self.thr = th
        def rate(p): return p.tic_spd * (BAL["slow_rate"] if p.ail["slow"] > 0 else 1) * (BAL["haste_rate"] if p.bf["spd"] > 0 else 1)
        dt = min((max(0, (th - p.tic) / max(.01, rate(p))) for p in self.all if p.hp > 0), default=None)
        if dt is None: self.over = True; return
        ready = []
        for p in self.all:
            if p.hp <= 0: continue
            p.tic += rate(p) * dt
            if p.tic >= th - 1e-4: ready.append(p)
        actor = self.rng.choice(ready)
        self.turn += 1
        if actor.ail["poison"] > 0 and actor.hp > 0:
            actor.hp = max(0, actor.hp - max(1, round(actor.maxhp * BAL["poison_pct"])))
        if actor.hp > 0 and actor.regen > 0: self.heal(actor, actor.maxhp * BAL["regen_pct"])
        if actor.hp > 0 and actor.ab["regen"] > 0: self.heal(actor, actor.maxhp * actor.ab["regen"] / 100)
        plan = self.ai(actor)
        if plan is not None and actor.hp > 0 and plan[1].hp > 0:
            s, t = plan
            if s is None: self.hit(actor, t, 1, "", 0, actor.magic)
            else: actor.mp -= s.cost; self.effect(s, actor, t)
        actor.tic -= th
        for k in actor.ail: actor.ail[k] = max(0, actor.ail[k] - 1)
        if actor.ail["leech"] == 0: actor.leecher = None
        for k in actor.bf: actor.bf[k] = max(0, actor.bf[k] - 1)
        for k in actor.nf: actor.nf[k] = max(0, actor.nf[k] - 1)
        actor.regen = max(0, actor.regen - 1)
        alive = [sum(1 for p in self.all if p.hp > 0 and p.team == k) for k in (0, 1)]
        if self.turn >= 300 and alive[0] and alive[1]: alive[0] = 0
        if alive[0] == 0 or alive[1] == 0:
            self.over = True; self.won = alive[0] > 0
    def run(self):
        while not self.over: self.step()
        return self.won, self.turn

def winrate(party_fn, foe_fn, n=400, seed=1):
    rng = random.Random(seed); w = 0; turns = 0
    for i in range(n):
        f = Fight(party_fn(rng), foe_fn(rng), rng)
        won, t = f.run(); w += won; turns += t
    return w / n, turns / n

def main():
    out = []; claims = []
    out.append("SPRITE TWIN  -  kills a level %d, +%d pts a level, xp/pt %g, quest x%g..%g, foes at x%.2f" % (LV_KILLS, LV_PTS, XP_PT, Q_LO, Q_HI, FOE_B))
    out.append("")
    # 1. class vs roster at par, 1 v 1, level 1 and level 10
    for lv in (1, 10):
        out.append("1v1 at par, level %d  (win %% / mean actions)" % lv)
        DUEL = [f for f in FOES if f != "cantor"]   # (the cantor is a pack kind - solo it is meant to be a pushover)
        out.append("  %-8s" % "" + "".join("%9s" % f for f in DUEL) + "     mean")
        means = {}
        for c in CLASSES:
            row = []; acc = 0
            for fk in DUEL:
                wr_, tn = winrate(lambda r, c=c, lv=lv: [sprite_pawn(c, lv, r)], lambda r, fk=fk, lv=lv: [foe_pawn(fk, lv, r)], n=300, seed=lv * 7 + 1)
                row.append("%5.0f/%-3.0f" % (wr_ * 100, tn)); acc += wr_
            means[c] = acc / len(DUEL)
            out.append("  %-8s" % c + "".join("%9s" % x for x in row) + "    %4.0f%%" % (means[c] * 100))
        lo, hi = min(means.values()), max(means.values())
        claims.append(("a lone sprite at par wins more than it loses, no class a pushover (50..90%%) at level %d" % lv, lo >= .5 and hi <= .9, "%.0f..%.0f%%" % (lo * 100, hi * 100)))
        out.append("")
    # 2. a party of three at par
    out.append("a party of three (warrior, mage, cleric) vs THREE par foes: win %")
    for lv in (1, 5, 10, 20):
        wr_, tn = winrate(lambda r, lv=lv: [sprite_pawn("warrior", lv, r), sprite_pawn("mage", lv, r), sprite_pawn("cleric", lv, r)],
                          lambda r, lv=lv: [foe_pawn(r.choice(list(FOES)), lv, r) for _ in range(3)], n=300, seed=lv)
        out.append("  level %2d: %3.0f%%   (%3.0f actions)" % (lv, wr_ * 100, tn))
        if lv == 5: claims.append(("three at par vs three: the crew has the edge (55..85%)", .55 <= wr_ <= .85, "%.0f%%" % (wr_ * 100)))
    wr_, tn = winrate(lambda r: [sprite_pawn("rogue", 5, r), sprite_pawn("ranger", 5, r), sprite_pawn("mage", 5, r)],
                      lambda r: [foe_pawn(r.choice(list(FOES)), 5, r) for _ in range(3)], n=300, seed=77)
    out.append("  (rogue, ranger, mage) at level 5: %3.0f%%" % (wr_ * 100))
    wr_, tn = winrate(lambda r: [sprite_pawn("warrior", 5, r), sprite_pawn("cleric", 5, r)],
                      lambda r: [foe_pawn(r.choice(list(FOES)), 5, r) for _ in range(2)], n=300, seed=78)
    out.append("  (warrior, cleric) vs two at level 5: %3.0f%%" % (wr_ * 100))
    out.append("")
    # 3. up / down
    out.append("a level-5 warrior, 1v1, vs foes of other levels: win %")
    for fl in (2, 5, 8, 11):
        wr_, tn = winrate(lambda r: [sprite_pawn("warrior", 5, r)], lambda r, fl=fl: [foe_pawn(r.choice(list(FOES)), fl, r)], n=300, seed=fl)
        out.append("  vs level %2d: %3.0f%%   pays ~%.1f xp a kill" % (fl, wr_ * 100, foe_xp(par_pts(fl) * FOE_B)))
        if fl == 11: claims.append(("six levels up, even the warrior loses more than it wins (<= 45%)", wr_ <= .45, "%.0f%%" % (wr_ * 100)))
        if fl == 2: claims.append(("three levels down is safe (>= 75%)", wr_ >= .75, "%.0f%%" % (wr_ * 100)))
    out.append("")
    # 4. the ladder
    out.append("the ladder (his law): xp a level, and what pays it")
    for lv in (1, 5, 10, 20, 50):
        need = xp_need(lv); kill = foe_xp(par_pts(lv) * FOE_B); q = xp_quest(lv, 1)
        out.append("  lv %2d -> %2d: %6d xp  =  %d par kills  or  %.1f full quests (%.1f each)" % (lv, lv + 1, need, round(need / kill), need / q, q))
    claims.append(("a level is SPRITE_LV_KILLS par kills at every level (to a rounding)", all(abs(xp_need(l) / foe_xp(par_pts(l) * FOE_B) - LV_KILLS) < 1.5 for l in (1, 7, 30, 99)), "self-similar"))
    claims.append(("a level-1 par foe pays 1 xp and level 2 is SPRITE_LV_KILLS xp away", foe_xp(par_pts(1) * FOE_B) == 1 and xp_need(1) == LV_KILLS, "%.1f xp, need %d" % (foe_xp(par_pts(1) * FOE_B), xp_need(1))))
    claims.append(("a full quest is worth fewer than ten par kills", xp_quest(10, 1) < 10 * foe_xp(par_pts(10) * FOE_B), "%.1f vs %.1f" % (xp_quest(10, 1), foe_xp(par_pts(10) * FOE_B))))
    # a trip's worth: ROOMS rooms, ~30% fights at par, + the quest
    fights = ROOMS * .3
    # THE SPLIT (his call, 2026-09-15): a pool is divided across the party - a
    # pack of 1.9 foes on average (EXPED_PACK_W1 / W2), a trio takes a third each
    pack = (35 * 1 + 40 * 2 + 25 * 3) / 100
    per_trip = (fights * pack * foe_xp(par_pts(5) * FOE_B) + xp_quest(5, .8)) / 2
    out.append("  a tier-2 trip (level 5, a crew of two, ~%.1f fights of ~%.1f, 80%% cleared, the xp split two ways) pays ~%.1f xp each: %.1f trips a level" % (fights, pack, per_trip, xp_need(5) / per_trip))
    out.append("  fights a level at par: a solo ~%d, a pair ~%d each, a trio ~%d each (packs of ~%.1f, the pool split)" % (round(xp_need(1) / pack), round(xp_need(1) / pack * 2), round(xp_need(1) / pack * 3), pack))
    out.append("")
    ok = all(c[1] for c in claims)
    for c in claims: out.append("  %s  %s  (%s)" % ("HOLDS" if c[1] else "FAILS", c[0], c[2]))
    out.append("")
    out.append("ALL HOLD" if ok else "SOMETHING FAILS - read the rows above")
    print("\n".join(out))
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
