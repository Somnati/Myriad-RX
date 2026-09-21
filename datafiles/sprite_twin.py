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
           poison_pct=.04, slow_rate=.6, haste_rate=1.25, leech_pct=.4, buff_pct=.25, buff_turns=3, regen_pct=.05, barrier_pct=.40)
ELEMS = ["fire", "water", "nature"]
BEATS = {"fire": "nature", "water": "fire", "nature": "water"}
WEAK  = {"fire": "water", "water": "nature", "nature": "fire"}
# ---- the abilities (2026-09-17, the evilities): ability_config / ability_unlocks / ability_gen, mirrored ----
ABIL = [  # (key, tier, lane, lo, hi, pair, cost_lane, cost_v) - THE ROSTER (2026-09-17, 134 kinds; generated with ability_config)
    ("stout", 1, "hp", 4, 8),
    ("brawn", 1, "atk", 4, 8),
    ("bookish", 1, "mag", 4, 8),
    ("thickskin", 1, "def", 4, 8),
    ("warded", 1, "mdef", 4, 8),
    ("quick", 1, "spd", 4, 8),
    ("keeneye", 1, "hit", 4, 8),
    ("lucky", 1, "luck", 1, 1),
    ("fireproof", 1, "res_fire", 6, 10),
    ("waterproof", 1, "res_water", 6, 10),
    ("thornproof", 1, "res_nature", 6, 10),
    ("nimble", 1, "eva", 2, 4),
    ("deepwell", 1, "mp", 6, 10),
    ("eager", 1, "mp0", 15, 25),
    ("gourmet", 1, "potion", 20, 35),
    ("longlegs", 1, "pace", 5, 10),
    ("magpie", 1, "finds", 8, 15),
    ("regular", 1, "inn", 1, 1),
    ("haggler", 1, "haggle", 1, 1),
    ("goodcompany", 1, "bonds", 20, 40),
    ("vicious", 2, "crit", 3, 6),
    ("spiteful", 2, "cnt", 4, 8),
    ("venomous", 2, "ail_poison", 10, 18),
    ("chilling", 2, "ail_slow", 10, 18),
    ("antidote", 2, "immune_poison", 1, 1),
    ("surefoot", 2, "immune_slow", 1, 1),
    ("unmarked", 2, "immune_leech", 1, 1),
    ("adrenal", 2, "low_atk", 15, 30),
    ("mending", 2, "regen", 1, 2),
    ("ambusher", 2, "vs_full", 10, 18),
    ("butcher", 2, "vs_low", 10, 18),
    ("turtle", 2, "low_def", 15, 30),
    ("dragonscale", 2, "hi_def", 10, 20),
    ("cornered", 2, "low_eva", 20, 40),
    ("vitalstrike", 2, "crit_dmg", 20, 35),
    ("retaliator", 2, "cnt_pow", 15, 30),
    ("heavyhand", 2, "stagger", 15, 30),
    ("unshakable", 2, "steady", 15, 30),
    ("battery", 2, "mp_gain", 15, 30),
    ("mphaste", 2, "mp_haste", 3, 6),
    ("vaccinated", 2, "vaccine", 25, 40),
    ("pathfinder", 2, "sure", 20, 40),
    ("owleyed", 2, "night", 1, 1),
    ("allweather", 2, "weather", 1, 1),
    ("dangersense", 2, "hazard", 1, 1),
    ("wanderer", 2, "wander", 1, 2),
    ("hardlessons", 2, "low_xp", 50, 100),
    ("hulking", 2, "hp", 8, 14),
    ("ironhide", 2, "def", 8, 14),
    ("frugal", 2, "frugal", 15, 25),
    ("gentlehands", 2, "heal_pow", 15, 25),
    ("goodpatient", 2, "heal_recv", 15, 25),
    ("wellrested", 2, "rest_hp", 8, 15),
    ("secondwind", 2, "rest", 50, 100),
    ("goldentouch", 2, "gold", 10, 20),
    ("treasuresense", 2, "loot", 1, 2),
    ("fleet", 3, "tic", 8, 14),
    ("bane", 3, "boss", 12, 20),
    ("scholar", 3, "xp", 15, 30),
    ("aegis", 3, "res_all", 5, 8),
    ("vampiric", 3, "life", 8, 15),
    ("elemental", 3, "elemdmg", 8, 15),
    ("berserk", 3, "atk", 15, 25, None, "def", -8),
    ("opportunist", 3, "vs_ail", 15, 25),
    ("firstblood", 3, "first", 20, 35),
    ("graverobber", 3, "vs_undead", 20, 35),
    ("slimesquasher", 3, "vs_slime", 20, 35),
    ("piercer", 3, "pierce", 15, 25),
    ("reckless", 3, "atk", 15, 25, None, "hit", -10),
    ("tothedeath", 3, "atk", 15, 25, None, "taken", 15),
    ("darktouched", 3, "dark_pow", 12, 20),
    ("thickhide", 3, "thick", 3, 5),
    ("stoneskin", 3, "guard", 10, 15, None, "spd", -10),
    ("safe", 3, "immune_crit", 1, 1),
    ("resilient", 3, "absorb", 10, 20),
    ("grimharvest", 3, "kill_heal", 8, 15),
    ("souleater", 3, "kill_mp", 15, 30),
    ("vendetta", 3, "cnt_crit", 10, 20),
    ("lingering", 3, "ail_dur", 1, 1),
    ("arcane", 3, "mag", 8, 14),
    ("wardedthrough", 3, "mdef", 8, 14),
    ("windquick", 3, "spd", 8, 14),
    ("hawkeyed", 3, "hit", 8, 14),
    ("twoedged", 3, "atk", 20, 30, None, "bleed", 2),
    ("titan", 4, "atk", 12, 18, "def"),
    ("savant", 4, "mag", 12, 18, "mdef"),
    ("swift", 4, "crit", 6, 10, "tic"),
    ("oncemore", 4, "once_more", 1, 1),
    ("bulwark", 4, "def", 12, 18, "mdef"),
    ("deathwind", 4, "low_crit_dmg", 60, 100),
    ("gambler", 4, "crit_dmg", 80, 120, None, "graze", 50),
    ("deaththroes", 4, "throes", 1, 1),
    ("mprage", 4, "mp_rage", 8, 15),
    ("damagecontrol", 4, "low_guard", 30, 50),
    ("grandslam", 4, "low_crit", 15, 25),
    ("momentum", 4, "momentum", 4, 7),
    ("underdog", 4, "underdog", 12, 20),
    ("salvo", 4, "salvo", 25, 40),
    ("ruse", 4, "ruse", 15, 25),
    ("scavenger", 1, "scav", 15, 25),
    ("pickpocket", 2, "pick", 25, 40),
    ("noble", 2, "sell", 15, 25),
    ("prospector", 2, "rooms", 15, 25),
    ("courier", 3, "quest", 15, 25),
    ("artisan", 1, "work", 8, 14),
    ("busyhands", 1, "work_tap", 12, 20),
    ("fabhand", 2, "work_fab", 12, 20),
    ("mergehand", 2, "work_merge", 12, 20),
    ("tireless", 2, "nap", 30, 50),
    ("foreman", 3, "work_aura", 4, 8),
    ("homebody", 2, "home_alone", 10, 18),
    ("captain", 3, "aura_atk", 4, 8),
    ("shieldwall", 3, "aura_def", 4, 8),
    ("cheerleader", 2, "aura_hit", 4, 8),
    ("luckycharm", 3, "aura_luck", 1, 1),
    ("medic", 2, "aura_heal", 10, 18),
    ("banner", 3, "aura_xp", 8, 14),
    ("quartermaster", 2, "aura_potion", 10, 18),
    ("firetouched", 3, "fire_pow", 15, 25),
    ("watertouched", 3, "water_pow", 15, 25),
    ("naturetouched", 3, "nature_pow", 15, 25),
    ("storyteller", 2, "notes", 30, 50),
    ("soundsleeper", 1, "rest_nap", 30, 50),
    ("lightsleeper", 1, "rest_wake", 30, 50),
    ("thorns", 3, "thorns", 10, 20),
    ("pouncingtiger", 4, "hurt_atk", 5, 9),
    ("superguts", 4, "hurt_def", 5, 9),
    ("duelist", 3, "duel", 20, 35),
    ("packfighter", 2, "pack", 6, 10),
    ("lonewolf", 3, "lone", 25, 40),
    ("laststand", 4, "last", 20, 35),
    ("executioner", 4, "execute", 8, 12),
    ("coldblood", 3, "immune_stagger", 1, 1),
    ("surehands", 2, "nograze", 1, 1),
]
FLAWS = [  # (key, lane, lo, hi) - THE FIFTH SLOT (2026-09-17): one a pawn, the band DIVIDED by the rarity's multiplier
    ("coward", "atk", -14, -8),
    ("brittle", "def", -14, -8),
    ("dull", "mag", -14, -8),
    ("thinskinned", "mdef", -14, -8),
    ("sluggish", "spd", -14, -8),
    ("clumsy", "hit", -14, -8),
    ("frail", "hp", -14, -8),
    ("shallow", "mp", -18, -10),
    ("jinxed", "luck", -1, -1),
    ("flatfooted", "eva", -4, -2),
    ("slowstarter", "first", -35, -20),
    ("panicky", "low_atk", -35, -20),
    ("overconfident", "hi_def", -25, -15),
    ("glassjaw", "taken", 10, 18),
    ("wildswings", "graze", 20, 35),
    ("bleeder", "bleed", 1, 2),
    ("soft", "vaccine", -50, -30),
    ("badpatient", "heal_recv", -35, -20),
    ("wasteful", "frugal", -25, -15),
    ("leaky", "mp_haste", -6, -3),
    ("topheavy", "steady", -35, -20),
    ("featherhands", "stagger", -35, -20),
    ("fireshy", "res_fire", -14, -8),
    ("watershy", "res_water", -14, -8),
    ("thornshy", "res_nature", -14, -8),
    ("slowlearner", "xp", -30, -15),
    ("heavysleeper", "rest", -50, -30),
    ("picky", "potion", -40, -25),
    ("shortlegs", "pace", -10, -5),
    ("careless", "sure", -50, -30),
    ("butterfingers", "finds", -20, -10),
    ("spendthrift", "gold", -20, -10),
    ("prickly", "bonds", -50, -30),
    ("lazy", "work", -20, -10),
    ("shabby", "sell", -25, -15),
    ("tired", "rest_hp", -15, -8),
]
ABIL_LADDER = [(1, 1), (4, 1), (8, 1), (14, 2), (20, 2), (30, 3), (45, 3), (60, 3), (80, 4), (100, 4)]
ABIL_RMULT = [.8, 1, 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.4, 2.6, 2.8, 3, 3.3, 3.6]   # fourteen rungs (2026-09-17)
def rarity_roll(rng, rate):
    # calculate_rarity's shape, near enough: a geometric walk up the rungs
    r = 0; p = .3
    while r < 13 and rng.random() < p: r += 1; p *= .55
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
    if lane_pts(pick[2]): val = math.copysign(max(1, round(abs(val))), val)
    return dict(key=pick[0], tier=pick[1], lane=pick[2], val=val, pair=(pick[5] if len(pick) > 5 else None),
                cost=((pick[6], pick[7]) if len(pick) > 7 else None))
def lane_pts(ln):
    return ln.startswith("immune") or ln.startswith("res_") or ln in ("luck", "eva", "ail_dur", "loot", "low_crit", "cnt_crit", "once_more", "throes", "inn", "haggle", "night", "weather", "hazard", "aura_luck", "nograze")
def flaw_gen(rng):
    pick = rng.choice(FLAWS)
    rar = rarity_roll(rng, 100)
    lo, hi = pick[2], pick[3]
    val = round((lo + (hi - lo) * rng.random()) / ABIL_RMULT[rar] * 10) / 10
    if lane_pts(pick[1]): val = math.copysign(max(1, round(abs(val))), val)
    return dict(key=pick[0], tier=0, lane=pick[1], val=val, pair=None, cost=None)
class _Lanes(dict):
    def __missing__(self, k): return 0   # (every numeric lane reads 0 until something lands on it)
def ability_effects(lst):
    o = _Lanes(res={"fire": 0, "water": 0, "nature": 0}, immune=[], ail="", ailc=0, once_more=False)
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
        elif ln == "once_more": o["once_more"] = True
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
    # the thirteen (q312) - the GML table's shapes, verbatim
    "knight":    dict(shape={"hp":7,"mp":2,"atk":5,"mag":1,"def":8,"mdef":5,"spd":3,"hit":6}, crit=4,  cmulti=1.5, cnt=9,  magic=False, skill="bulwark",  tmpls=[9, 0, 6, 3]),
    "berserker": dict(shape={"hp":8,"mp":2,"atk":8,"mag":1,"def":3,"mdef":4,"spd":5,"hit":5}, crit=9,  cmulti=1.8, cnt=6,  magic=False, skill="rage",     tmpls=[15, 0, 17, 11]),
    "valkyrie":  dict(shape={"hp":6,"mp":3,"atk":7,"mag":2,"def":5,"mdef":4,"spd":6,"hit":6}, crit=8,  cmulti=1.6, cnt=8,  magic=False, skill="lunge",    tmpls=[16, 0, 3, 6]),
    "samurai":   dict(shape={"hp":5,"mp":3,"atk":7,"mag":1,"def":4,"mdef":3,"spd":6,"hit":8}, crit=16, cmulti=2.0, cnt=8,  magic=False, skill="iai",      tmpls=[0, 16, 3, 14]),
    "brawler":   dict(shape={"hp":6,"mp":4,"atk":6,"mag":1,"def":6,"mdef":3,"spd":7,"hit":6}, crit=8,  cmulti=1.6, cnt=14, magic=False, skill="flurry",   tmpls=[17, 3, 15, 0]),
    "ninja":     dict(shape={"hp":4,"mp":3,"atk":7,"mag":1,"def":3,"mdef":3,"spd":8,"hit":7}, crit=12, cmulti=1.8, cnt=10, magic=False, skill="smoke",    tmpls=[14, 5, 3, 21]),
    "thief":     dict(shape={"hp":5,"mp":3,"atk":6,"mag":2,"def":4,"mdef":4,"spd":7,"hit":7}, crit=12, cmulti=1.7, cnt=8,  magic=False, skill="pilfer",   tmpls=[18, 5, 14, 3]),
    "witch":     dict(shape={"hp":5,"mp":6,"atk":1,"mag":8,"def":3,"mdef":5,"spd":4,"hit":6}, crit=5,  cmulti=1.8, cnt=2,  magic=True,  skill="hex",      tmpls=[7, 1, 21, 12, 4]),
    "sage":      dict(shape={"hp":5,"mp":5,"atk":1,"mag":8,"def":3,"mdef":6,"spd":4,"hit":6}, crit=3,  cmulti=1.5, cnt=2,  magic=True,  skill="barrier",  tmpls=[10, 4, 19, 2]),
    "priest":    dict(shape={"hp":6,"mp":5,"atk":2,"mag":7,"def":4,"mdef":6,"spd":4,"hit":5}, crit=3,  cmulti=1.5, cnt=3,  magic=True,  skill="manaward", tmpls=[2, 8, 13, 20, 23]),
    "paladin":   dict(shape={"hp":7,"mp":3,"atk":6,"mag":3,"def":6,"mdef":5,"spd":3,"hit":6}, crit=5,  cmulti=1.5, cnt=7,  magic=False, skill="smite",    tmpls=[23, 9, 2, 0]),
    "bard":      dict(shape={"hp":5,"mp":4,"atk":6,"mag":2,"def":4,"mdef":3,"spd":7,"hit":7}, crit=6,  cmulti=1.6, cnt=4,  magic=False,  skill="song",     tmpls=[17, 22, 6, 20, 21]),
    "druid":     dict(shape={"hp":6,"mp":5,"atk":3,"mag":7,"def":4,"mdef":4,"spd":4,"hit":6}, crit=4,  cmulti=1.6, cnt=4,  magic=True,  skill="regrowth", tmpls=[13, 4, 5, 19]),
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
    def __init__(self, name, cost, targ, magic, mult=0, leech=0, healp=0, stag=0, kind="", elem="", school="", ail="", buf="", nerf="", pierce=0, crit=0, drainmp=0, lane=""):
        self.name, self.cost, self.targ, self.magic = name, cost, targ, magic
        self.mult, self.leech, self.healp, self.stag, self.kind = mult, leech, healp, stag, kind
        self.elem, self.school, self.ail, self.buf, self.nerf = elem, school, ail, buf, nerf
        self.pierce, self.crit, self.drainmp, self.lane = pierce, crit, drainmp, lane   # (q312's lanes)
LIB = {
    "strike":  Skill("strike", 3, "enemy", False, mult=1.6, kind="strike"),
    "reform":  Skill("reform", 4, "self", False, kind="reform", school="light"),
    "drain":   Skill("drain", 3, "enemy", True, mult=.8, leech=.6, kind="drain", school="dark", ail="leech"),
    "mend":    Skill("mend", 4, "ally", True, kind="mend", school="light"),
    "concuss": Skill("concuss", 3, "enemy", False, mult=.7, stag=.45, kind="concuss"),
    "bolt":    Skill("bolt", 3, "enemy", True, mult=1.5, kind="bolt", elem="nature"),
    # the thirteen (q312)
    "bulwark":  Skill("bulwark", 3, "self", False, kind="barrier", school="light", buf="barrier", lane="pres"),
    "rage":     Skill("rage", 3, "self", False, kind="rage"),
    "lunge":    Skill("lunge", 3, "enemy", False, mult=1.25, kind="pierce", pierce=.5),
    "iai":      Skill("iai", 3, "enemy", False, mult=1.3, kind="iai", crit=30),
    "flurry":   Skill("flurry", 3, "enemy", False, mult=.65, kind="flurry"),
    "smoke":    Skill("smoke", 2, "self", False, kind="smoke"),
    "pilfer":   Skill("pilfer", 2, "enemy", False, mult=.9, kind="siphon", school="dark", drainmp=3),
    "hex":      Skill("hex", 3, "enemy", True, mult=.5, kind="hex", school="dark", nerf="nerf_atk"),
    "barrier":  Skill("barrier", 4, "ally", True, kind="barrier", school="light", buf="barrier", lane="pres"),
    "manaward": Skill("manaward", 4, "ally", True, healp=.12, kind="barrier", school="light", buf="manaward", lane="mres"),
    "smite":    Skill("smite", 3, "enemy", False, mult=1.4, kind="smite", school="light"),
    "song":     Skill("song", 2, "ally", True, kind="anthem", school="light", buf="haste"),
    "regrowth": Skill("regrowth", 4, "ally", True, healp=.2, kind="regen", school="light"),
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
    if tmpl == 8: return Skill("gen-cleanse", rng.randint(4, 6), "ally", True, healp=rng.uniform(.12, .2), kind="cleanse", school="light")
    # the fifteen (q312)
    if tmpl == 9: return Skill("gen-barrier", rng.randint(3, 5), "ally", True, kind="barrier", school="light", buf="barrier", lane="pres")
    if tmpl == 10: return Skill("gen-manaward", rng.randint(3, 5), "ally", True, kind="barrier", school="light", buf="manaward", lane="mres")
    if tmpl == 11: return Skill("gen-breach", rng.randint(3, 5), "enemy", False, mult=rng.uniform(.45, .7), kind="breach", school="dark", nerf="breach", lane="pres")
    if tmpl == 12: return Skill("gen-unward", rng.randint(3, 5), "enemy", True, mult=rng.uniform(.45, .7), kind="breach", school="dark", nerf="unward", lane="mres")
    if tmpl == 13: return Skill("gen-regen", rng.randint(3, 5), "ally", True, healp=rng.uniform(.08, .16), kind="regen", school="light")
    if tmpl == 14: return Skill("gen-smoke", rng.randint(2, 4), "self", False, kind="smoke")
    if tmpl == 15: return Skill("gen-rage", rng.randint(2, 4), "self", False, kind="rage")
    if tmpl == 16: return Skill("gen-lunge", rng.randint(3, 5), "enemy", False, mult=rng.uniform(1.1, 1.4), kind="pierce", pierce=rng.uniform(.4, .6))
    if tmpl == 17: return Skill("gen-flurry", rng.randint(3, 5), "enemy", False, mult=rng.uniform(.55, .75), kind="flurry")
    if tmpl == 18: return Skill("gen-siphon", rng.randint(2, 3), "enemy", True, mult=rng.uniform(.5, .7), kind="siphon", school="dark", drainmp=rng.randint(2, 4))
    if tmpl == 19: return Skill("gen-burst", rng.randint(5, 7), "enemy", True, mult=rng.uniform(.6, .85), kind="burst", elem=rng.choice(ELEMS))
    if tmpl == 20: return Skill("gen-chorus", rng.randint(5, 7), "ally", True, healp=rng.uniform(.14, .24), kind="chorus", school="light")
    if tmpl == 21: return Skill("gen-silence", rng.randint(3, 4), "enemy", True, mult=rng.uniform(.3, .5), kind="silence", school="dark")
    if tmpl == 22: return Skill("gen-anthem", rng.randint(5, 7), "ally", True, kind="anthem", school="light", buf=rng.choice(["buf_atk", "buf_def", "haste"]))
    return Skill("gen-smite", rng.randint(3, 5), "enemy", True, mult=rng.uniform(1.1, 1.5), kind="smite", school="light")

class Pawn:
    def __init__(self, name, arch, lv, team, rng, gear=None, boss=False, skills=None):
        budget = par_pts(lv) * (FOE_B if team == 1 else 1) * (1.4 if boss else 1)
        pts = {k: arch["shape"][k] * budget / 40 for k in KEYS}
        for it in (gear or []):
            for k, v in it.items(): pts[k] += v
        # the abilities (2026-09-17): the rungs the level has passed, the newest four worn
        ab = ability_effects(abilities_for(rng, lv, 4) + [flaw_gen(rng)])   # (+ the flaw, the fifth slot - 2026-09-17)
        for k in ("atk", "mag", "def", "mdef", "spd", "hit"): pts[k] *= 1 + ab["def_" if k == "def" else k] / 100
        self.ab = ab
        self.name, self.team, self.lv = name, team, lv
        self.pts_total = sum(pts.values())
        self.maxhp = math.floor(pts["hp"] * BAL["hp_per_point"] * (1 + ab["hp"] / 100) + BAL["hp_flat_add"])   # (whole hp, 2026-09-15 - sprite_pawn / foe_gen floor it)
        self.hp = self.maxhp
        self.maxmp = max(1, round(pts["mp"] * (1 + ab["mp"] / 100))); self.mp = math.ceil(self.maxmp * max(0, min(1, BAL["mp_start_frac"] + ab["mp0"] / 100)))
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
        self.acts = 0; self.sk_used = 0; self.streak = 0   # (the big roster's counters, 2026-09-17)
        self.ail = {"poison": 0, "slow": 0, "leech": 0, "silence": 0}; self.bf = {"atk": 0, "def": 0, "hit": 0, "spd": 0, "pres": 0, "mres": 0}; self.nf = {"atk": 0, "def": 0, "hit": 0, "pres": 0, "mres": 0}
        self.regen = 0; self.leecher = None; self.evade = 0; self.sk_pierce = 0; self.sk_crit = 0   # (q312's lanes)

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
    sk = [LIB[f["skill"]]] if f["skill"] else []
    if lv >= 3:   # (q312: a generated skill of its nature, as foe_gen)
        und = "undead" in f.get("tags", [])
        pool = [1, 7, 21, 12, 11] if und else ([4, 4, 7, 12, 21, 18] if f["magic"] else [0, 3, 5, 16, 17, 15, 11])
        sk.append(skill_gen(pool[rng.randrange(len(pool))], rng))
    return Pawn(kind, f, lv, 1, rng, gear=gear, boss=boss, skills=sk)

class Fight:
    def __init__(self, party, foes, rng):
        self.party, self.foes, self.all = party, foes, party + foes
        self.rng = rng; self.turn = 0; self.over = False; self.won = False; self.thr = 1
    def status(self, u, t, key):
        b = BAL
        if t.hp <= 0: return False
        undead = "undead" in t.tags; slime = "slime" in t.tags
        if ("immune_" + key) in t.tags: return False
        turns = max(1, round(b["ail_turns"] * (b["boss_ail"] if t.boss else 1))) + (round(u.ab["ail_dur"]) if u is not None and u.ab["ail_dur"] > 0 else 0)
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
        if key in ("barrier", "manaward"):   # (q312)
            k = "pres" if key == "barrier" else "mres"
            if t.nf[k] > 0: t.nf[k] = 0; return True
            t.bf[k] = bturns; return True
        if key in ("breach", "unward"):
            k = "pres" if key == "breach" else "mres"
            if t.bf[k] > 0: t.bf[k] = 0; return True
            t.nf[k] = bturns; return True
        if key == "silence": t.ail["silence"] = turns; return True
        if key == "evade": t.evade = bturns; return True
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
            t.regen = 0; t.evade = 0
        return 1
    def hit(self, u, t, mult=1, label="", cdepth=0, magic=False, elem=None, ail=""):
        b, rng = BAL, self.rng
        basic = (label == "" and cdepth == 0)
        if elem is None: elem = u.elem
        if ail == "" and basic: ail = u.ail_k
        m_atk = 1 + (b["buff_pct"] if u.bf["atk"] > 0 else 0) - (b["buff_pct"] if u.nf["atk"] > 0 else 0)
        ua, ta = u.ab, t.ab
        hp0 = t.hp; tfull = t.hp >= t.maxhp - .01; thalf = t.hp < t.maxhp * .5; tail = t.ail["poison"] > 0 or t.ail["slow"] > 0 or t.ail["leech"] > 0
        up_u = sum(1 for p in self.all if p.hp > 0 and p.team == u.team); up_t = sum(1 for p in self.all if p.hp > 0 and p.team != u.team)
        ulast, tlast = up_u == 1, up_t == 1
        if ua["low_atk"] != 0 and u.hp < u.maxhp * .35: m_atk += ua["low_atk"] / 100
        if ua["first"] != 0 and u.acts == 0: m_atk += ua["first"] / 100
        if ua["underdog"] > 0 and t.lv > u.lv: m_atk += ua["underdog"] / 100
        if ua["hurt_atk"] > 0: m_atk += ua["hurt_atk"] / 100 * math.floor((1 - u.hp / max(1, u.maxhp)) * 5)
        m_hit = 1 + (b["buff_pct"] if u.bf["hit"] > 0 else 0) - (b["buff_pct"] if u.nf["hit"] > 0 else 0)
        if ua["last"] > 0 and ulast: m_atk += ua["last"] / 100; m_hit += ua["last"] / 100
        m_def = 1 + (b["buff_pct"] if t.bf["def"] > 0 else 0) - (b["buff_pct"] if t.nf["def"] > 0 else 0)
        if ta["low_def"] != 0 and t.hp < t.maxhp * .35: m_def += ta["low_def"] / 100
        if ta["hi_def"] != 0 and t.hp >= t.maxhp * .8: m_def += ta["hi_def"] / 100
        if ta["hurt_def"] > 0: m_def += ta["hurt_def"] / 100 * math.floor((1 - t.hp / max(1, t.maxhp)) * 5)
        if ta["last"] > 0 and tlast: m_def += ta["last"] / 100
        m_atk, m_def, m_hit = max(.1, m_atk), max(.1, m_def), max(.1, m_hit)
        apow = (u.mag if magic else u.atk) * m_atk
        dpow = (t.mdef if magic else t.def_) * m_def * (1 - ua["pierce"] / 100) * (1 - u.sk_pierce)
        uhit = u.hit * m_hit
        teva = t.eva + ta["eva"]
        if ta["low_eva"] > 0 and t.hp < t.maxhp * .25: teva *= 1 + ta["low_eva"] / 100
        s = uhit + max(0, teva)
        hc = 50
        if s > 0:
            r = uhit / s
            hc = max(1, min(99, b["hitcurve_a"] * r * r + b["hitcurve_b"] * r))
        if t.evade > 0: hc = max(1, min(99, hc * .5))   # (the smoke, q312)
        roll = rng.random() * 100
        if roll >= hc: u.streak = 0; return 0
        q = (hc - roll) / hc
        if ua["graze"] > 0 and rng.random() * 100 < ua["graze"]: q = 0
        if ua["nograze"] > 0: q = max(q, .15)
        cr = u.crit_rate + (ua["cnt_crit"] if cdepth > 0 else 0) + (ua["low_crit"] if u.hp < u.maxhp * .25 else 0) + u.sk_crit
        cm = (u.crit_multi - 1) * (1 + ua["crit_dmg"] / 100) * ((1 + ua["low_crit_dmg"] / 100) if u.hp < u.maxhp * .25 else 1)
        crit = rng.random() * 100 < cr and "immune_crit" not in t.tags
        dmg = apow * mult
        dmg -= (dpow * (1 + (b["def_lerp_low"] - 1) * q)) / b["def_div"]
        lo = dmg * b["dmg_lerp_low"]
        hi = dmg * (b["perf_lerp_high"] if q >= .97 else b["dmg_lerp_high"])
        dmg = lo + (hi - lo) * q
        if crit:
            cl = cm * b["crit_lerp_low"]; ch = cm * b["crit_lerp_high"]
            dmg *= 1 + cl + (ch - cl) * q
        dmg *= b["ttk_multi"]
        if elem in BEATS:
            rs = max(b["res_min"], min(b["res_max"], t.res[elem]))
            dmg *= 1 - rs / 100
        if elem == "fire": dmg *= b["fire_bonus"]
        if ua["boss"] > 0 and t.boss: dmg *= 1 + ua["boss"] / 100
        if ua["elemdmg"] > 0 and elem in BEATS and not basic: dmg *= 1 + ua["elemdmg"] / 100
        # the big roster's situational lanes (2026-09-17)
        if ua["vs_full"] > 0 and tfull: dmg *= 1 + ua["vs_full"] / 100
        if ua["vs_low"] > 0 and thalf: dmg *= 1 + ua["vs_low"] / 100
        if ua["vs_ail"] > 0 and tail: dmg *= 1 + ua["vs_ail"] / 100
        if ua["vs_undead"] > 0 and "undead" in t.tags: dmg *= 1 + ua["vs_undead"] / 100
        if ua["vs_slime"] > 0 and "slime" in t.tags: dmg *= 1 + ua["vs_slime"] / 100
        if ua["cnt_pow"] > 0 and cdepth > 0: dmg *= 1 + ua["cnt_pow"] / 100
        if ua["salvo"] > 0 and label != "" and u.sk_used == 0: dmg *= 1 + ua["salvo"] / 100
        if ua["momentum"] > 0: dmg *= 1 + ua["momentum"] / 100 * min(5, u.streak)
        if ua["fire_pow"] > 0 and elem == "fire": dmg *= 1 + ua["fire_pow"] / 100
        if ua["water_pow"] > 0 and elem == "water": dmg *= 1 + ua["water_pow"] / 100
        if ua["nature_pow"] > 0 and elem == "nature": dmg *= 1 + ua["nature_pow"] / 100
        if ua["duel"] > 0 and tlast: dmg *= 1 + ua["duel"] / 100
        if ua["pack"] > 0 and up_u > 1: dmg *= 1 + ua["pack"] / 100 * min(3, up_u - 1)
        if ua["lone"] > 0 and ulast: dmg *= 1 + ua["lone"] / 100
        dmg *= (1 + ta["taken"] / 100) * (1 - ta["guard"] / 100)
        if not magic:   # (the barrier and the breach, q312)
            if t.bf["pres"] > 0: dmg *= 1 - b["barrier_pct"]
            if t.nf["pres"] > 0: dmg *= 1 + b["barrier_pct"]
        else:
            if t.bf["mres"] > 0: dmg *= 1 - b["barrier_pct"]
            if t.nf["mres"] > 0: dmg *= 1 + b["barrier_pct"]
        if ta["low_guard"] > 0 and t.hp < t.maxhp * .25: dmg *= 1 - ta["low_guard"] / 100
        dmg = max(.1, round(dmg * 10) / 10)
        if ta["thick"] > 0 and dmg <= t.maxhp * ta["thick"] / 100: u.streak = 0; return 0
        if ua["execute"] > 0 and basic and not t.boss and t.hp <= t.maxhp * ua["execute"] / 100: dmg = max(dmg, t.hp)
        stag = (1 + t.spd / 3) * (.01 + ((.085 if q >= .97 else .05) - .01) * q)
        if crit: stag += (1 + t.spd / 3) * .03
        stag *= max(0, 1 + ua["stagger"] / 100) * max(0, 1 - ta["steady"] / 100)
        if "immune_stagger" in t.tags: stag = 0
        t.tic -= stag * self.thr
        t.hp = max(0, t.hp - dmg)
        if t.hp <= 0 and ta["once_more"] and hp0 > 1: t.hp = 1
        if ua["bleed"] > 0 and u.hp > 1: u.hp = max(1, u.hp - u.maxhp * ua["bleed"] / 100)
        u.streak += 1
        if ta["thorns"] > 0 and t.hp > 0 and cdepth == 0 and u.hp > 1: u.hp = max(1, u.hp - round(dmg * ta["thorns"] / 100 * 10) / 10)
        t.maxhp = max(1, t.maxhp - dmg * b["dmg_to_maxhp"] * t.erode)
        if t.hp > t.maxhp: t.hp = t.maxhp
        if ua["life"] > 0 and u.hp > 0: self.heal(u, dmg * ua["life"] / 100)
        if t.ail["leech"] > 0 and t.leecher is u and u.hp > 0: self.heal(u, dmg * b["leech_pct"])
        if t.hp > 0:
            if ta["absorb"] > 0: self.heal(t, dmg * ta["absorb"] / 100)
            if ta["mp_rage"] > 0: t.mp = min(t.maxmp, t.mp + t.maxmp * (ta["mp_rage"] / 100) * max(.25, min(1, dmg / max(1, t.maxhp) * 3)))
        elif u.hp > 0:
            if ua["kill_heal"] > 0: self.heal(u, u.maxhp * ua["kill_heal"] / 100)
            if ua["kill_mp"] > 0: u.mp = min(u.maxmp, u.mp + u.maxmp * ua["kill_mp"] / 100)
            if ta["throes"] > 0:
                for p in self.all:
                    if p.team != t.team and p.hp > 0: self.status(t, p, "nerf_atk")
        if ail != "" and t.hp > 0:
            ch = (b["ail_basic"] if basic else b["ail_skill"])
            if basic and u.ail_c > 0: ch = u.ail_c
            if ta["vaccine"] != 0: ch *= max(0, 1 - ta["vaccine"] / 100)
            if rng.random() * 100 < ch: self.status(u, t, ail)
        if label == "" and cdepth == 0:
            u.mp = min(u.maxmp, u.mp + (b["mp_gain_qual"] if (q >= .85 or crit) else b["mp_gain"]) * max(0, 1 + ua["mp_gain"] / 100))
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
        # the fifteen (q312) - the GML's scores
        foes_up = [p for p in self.all if p.hp > 0 and p.team != u.team]
        allies_up = [p for p in self.all if p.hp > 0 and p.team == u.team]
        if s.kind == "barrier":
            if t.bf[s.lane] > 0: return 0
            if not foes_up: return 0
            kind = sum(1 for p in foes_up if ((not p.magic) if s.lane == "pres" else p.magic))
            return 28 + 34 * (kind / len(foes_up)) + (1 - t.hp / t.maxhp) * (45 if s.healp > 0 else 25) + (25 if t.nf[s.lane] > 0 else 0)
        if s.kind == "breach":
            if t.nf[s.lane] > 0: return 10
            return 36 + (t.def_ if s.lane == "pres" else t.mdef) * 2 + (t.maxhp / max(1, u.maxhp)) * 8 + (30 if t.bf[s.lane] > 0 else 0)
        if s.kind == "regen":
            if t.regen > 0: return 0
            return 18 + (1 - t.hp / t.maxhp) * 60
        if s.kind == "smoke":
            if u.evade > 0: return 0
            return 24 + (1 - u.hp / u.maxhp) * 35 + len(foes_up) * 6
        if s.kind == "rage":
            if u.bf["atk"] > 0: return 0
            return 30 + (u.hp / u.maxhp) * 25
        if s.kind == "pierce": return 42 + t.def_ * 3 + (15 if t.hp < t.maxhp * .35 else 0)
        if s.kind == "iai": return 46 + u.crit_multi * 8 + (20 if t.hp < t.maxhp * .4 else 0)
        if s.kind == "flurry": return 46 - t.def_ + (20 if t.hp < t.maxhp * .35 else 0)
        if s.kind == "siphon": return 26 + (22 if t.mp >= s.drainmp else 0) + (1 - u.mp / max(1, u.maxmp)) * 30
        if s.kind == "burst":
            if len(foes_up) < 2: return 12
            return 30 + 20 * (len(foes_up) - 1) - sum(p.res[s.elem] for p in foes_up) * .3
        if s.kind == "chorus":
            if len(allies_up) < 2: return 0
            return sum(1 - p.hp / p.maxhp for p in allies_up) * 55
        if s.kind == "silence":
            if t.ail["silence"] > 0: return 0
            casts = sum(1 for k in t.skills if k.magic)
            return (40 + casts * 12 + (12 if t.magic else 0)) if casts > 0 else 6
        if s.kind == "anthem":
            k = "spd" if s.buf == "haste" else s.buf[4:]
            want = sum(1 for p in allies_up if p.bf[k] <= 0)
            if s.name == "song": return (20 * want + 8) if (want >= 1 and (len(allies_up) >= 2 or want == 1)) else 0
            if len(allies_up) < 2 or want < 2: return 0
            return 22 * want
        if s.kind == "smite": return 44 + t.def_ * 2 - t.mdef + (30 if "undead" in t.tags else 0) + (15 if t.hp < t.maxhp * .35 else 0)
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
            if s.magic and u.ail["silence"] > 0: continue   # (q312)
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
        # the fifteen (q312)
        elif s.kind == "barrier":
            if s.healp > 0: self.heal(t, t.maxhp * s.healp)
            self.status(u, t, s.buf)
        elif s.kind == "breach":
            d = self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
            if d > 0: self.status(u, t, s.nerf)
        elif s.kind == "regen": self.heal(t, t.maxhp * s.healp); self.status(u, t, "regen")
        elif s.kind == "smoke": self.status(u, u, "evade")
        elif s.kind == "rage": self.status(u, u, "buf_atk"); self.status(u, u, "nerf_def")
        elif s.kind == "pierce":
            u.sk_pierce = s.pierce; self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem); u.sk_pierce = 0
        elif s.kind == "iai":
            u.sk_crit = s.crit; self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem); u.sk_crit = 0
        elif s.kind == "flurry":
            self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
            if t.hp > 0: self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
        elif s.kind == "siphon":
            d = self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
            if d > 0:
                take = min(t.mp, s.drainmp); t.mp -= take; u.mp = min(u.maxmp, u.mp + take)
        elif s.kind == "burst":
            for p in [p for p in self.all if p.hp > 0 and p.team != u.team]:
                if p.hp > 0 and u.hp > 0: self.hit(u, p, s.mult, s.name, 0, s.magic, s.elem)
        elif s.kind == "chorus":
            for p in self.all:
                if p.hp > 0 and p.team == u.team: self.heal(p, p.maxhp * s.healp)
        elif s.kind == "silence":
            d = self.hit(u, t, s.mult, s.name, 0, s.magic, s.elem)
            if d > 0: self.status(u, t, "silence")
        elif s.kind == "anthem":
            for p in self.all:
                if p.hp > 0 and p.team == u.team:
                    self.status(u, p, s.buf)
                    if s.name == "song": self.status(u, p, "buf_atk")   # (the bard's song: haste and heart)
        elif s.kind == "smite": self.hit(u, t, s.mult * (1.5 if "undead" in t.tags else 1), s.name, 0, s.magic, s.elem)
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
        if actor.hp > 0 and actor.ab["mp_haste"] != 0: actor.mp = max(0, min(actor.maxmp, actor.mp + actor.maxmp * actor.ab["mp_haste"] / 100))
        plan = self.ai(actor)
        if plan is not None and actor.hp > 0 and plan[1].hp > 0:
            s, t = plan
            if s is None: self.hit(actor, t, 1, "", 0, actor.magic)
            else:
                cost = max(1, math.ceil(s.cost * (1 - actor.ab["frugal"] / 100))) if actor.ab["frugal"] != 0 else s.cost
                actor.mp -= cost; self.effect(s, actor, t); actor.sk_used += 1
                if actor.ab["ruse"] > 0 and actor.hp > 0: self.heal(actor, actor.maxhp * (cost / max(1, actor.maxmp)) * actor.ab["ruse"] / 100)
        actor.acts += 1
        actor.tic -= th
        for k in actor.ail: actor.ail[k] = max(0, actor.ail[k] - 1)
        if actor.ail["leech"] == 0: actor.leecher = None
        for k in actor.bf: actor.bf[k] = max(0, actor.bf[k] - 1)
        for k in actor.nf: actor.nf[k] = max(0, actor.nf[k] - 1)
        actor.regen = max(0, actor.regen - 1)
        actor.evade = max(0, actor.evade - 1)   # (q312)
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
