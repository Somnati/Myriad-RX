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
           mp_gain=1, mp_gain_qual=2, mp_start_frac=.5, cnt_mult=.7, cnt_falloff=.5, cnt_chain=3)
KEYS = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"]

# sprite_classes (the shapes must match the GML table)
CLASSES = {
    "warrior": dict(shape={"hp":7,"mp":3,"atk":7,"mag":1,"def":6,"mdef":2,"spd":4,"hit":7}, crit=6,  cmulti=1.6, cnt=8,  magic=False, skill="strike",  tmpls=[0, 3]),
    "mage":    dict(shape={"hp":4,"mp":6,"atk":2,"mag":8,"def":2,"mdef":6,"spd":4,"hit":6}, crit=5,  cmulti=1.8, cnt=2,  magic=True,  skill="bolt",    tmpls=[4, 1]),
    "rogue":   dict(shape={"hp":5,"mp":4,"atk":6,"mag":2,"def":4,"mdef":3,"spd":7,"hit":7}, crit=14, cmulti=1.8, cnt=10, magic=False, skill="concuss", tmpls=[1, 3]),
    "cleric":  dict(shape={"hp":6,"mp":6,"atk":3,"mag":6,"def":5,"mdef":6,"spd":3,"hit":5}, crit=3,  cmulti=1.5, cnt=3,  magic=True,  skill="mend",    tmpls=[2, 4]),
    "ranger":  dict(shape={"hp":5,"mp":4,"atk":6,"mag":3,"def":4,"mdef":4,"spd":6,"hit":7}, crit=10, cmulti=1.7, cnt=6,  magic=False, skill="strike",  tmpls=[3, 0]),
}
# foe_gen's roster
FOES = {
    "goblin":   dict(shape={"hp":5,"mp":3,"atk":6,"mag":2,"def":5,"mdef":3,"spd":7,"hit":7},  crit=8,  cmulti=1.6, cnt=8,  erode=1,   magic=False, skill="concuss", gear=.3),
    "bandit":   dict(shape={"hp":6,"mp":3,"atk":7,"mag":1,"def":6,"mdef":3,"spd":5,"hit":7},  crit=7,  cmulti=1.6, cnt=7,  erode=1,   magic=False, skill="strike",  gear=.8),
    "wolf":     dict(shape={"hp":6,"mp":2,"atk":7,"mag":1,"def":3,"mdef":2,"spd":8,"hit":7}, crit=10, cmulti=1.7, cnt=5,  erode=1,   magic=False, skill="",        gear=0),
    "slime":    dict(shape={"hp":8,"mp":6,"atk":3,"mag":3,"def":6,"mdef":6,"spd":2,"hit":4}, crit=5,  cmulti=1.5, cnt=4,  erode=.25, magic=False, skill="reform",  gear=0),
    "skeleton": dict(shape={"hp":6,"mp":4,"atk":8,"mag":1,"def":6,"mdef":4,"spd":3,"hit":6},  crit=8,  cmulti=1.8, cnt=6,  erode=1,   magic=False, skill="strike",  gear=.5),
    "wisp":     dict(shape={"hp":3,"mp":6,"atk":2,"mag":8,"def":2,"mdef":6,"spd":5,"hit":6},  crit=6,  cmulti=1.8, cnt=2,  erode=1,   magic=True,  skill="drain",   gear=0),
    "rat":      dict(shape={"hp":5,"mp":4,"atk":6,"mag":1,"def":4,"mdef":2,"spd":7,"hit":8}, crit=10, cmulti=1.6, cnt=12, erode=1,   magic=False, skill="concuss", gear=.1),
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
    def __init__(self, name, cost, targ, magic, mult=0, leech=0, healp=0, stag=0, kind=""):
        self.name, self.cost, self.targ, self.magic = name, cost, targ, magic
        self.mult, self.leech, self.healp, self.stag, self.kind = mult, leech, healp, stag, kind
LIB = {
    "strike":  Skill("strike", 3, "enemy", False, mult=1.6, kind="strike"),
    "reform":  Skill("reform", 4, "self", False, kind="reform"),
    "drain":   Skill("drain", 3, "enemy", True, mult=.8, leech=.6, kind="drain"),
    "mend":    Skill("mend", 4, "ally", True, kind="mend"),
    "concuss": Skill("concuss", 3, "enemy", False, mult=.7, stag=.45, kind="concuss"),
    "bolt":    Skill("bolt", 3, "enemy", True, mult=1.5, kind="bolt"),
}
def skill_gen(tmpl, rng):
    if tmpl == 0: return Skill("gen-heavy", rng.randint(3, 5), "enemy", False, mult=rng.uniform(1.4, 2.1), kind="heavy")
    if tmpl == 1: return Skill("gen-drain", rng.randint(3, 5), "enemy", True, mult=rng.uniform(.6, 1.0), leech=rng.uniform(.4, .8), kind="drain")
    if tmpl == 2: return Skill("gen-heal", rng.randint(4, 6), "ally", True, healp=rng.uniform(.28, .5), kind="heal")
    if tmpl == 3: return Skill("gen-stagger", rng.randint(2, 4), "enemy", False, mult=rng.uniform(.55, .8), stag=rng.uniform(.3, .6), kind="stagger")
    return Skill("gen-spell", rng.randint(3, 5), "enemy", True, mult=rng.uniform(1.3, 1.9), kind="spell")

class Pawn:
    def __init__(self, name, arch, lv, team, rng, gear=None, boss=False, skills=None):
        budget = par_pts(lv) * (FOE_B if team == 1 else 1) * (1.4 if boss else 1)
        pts = {k: arch["shape"][k] * budget / 40 for k in KEYS}
        for it in (gear or []):
            for k, v in it.items(): pts[k] += v
        self.name, self.team, self.lv = name, team, lv
        self.pts_total = sum(pts.values())
        self.maxhp = math.floor(pts["hp"] * BAL["hp_per_point"] + BAL["hp_flat_add"])   # (whole hp, 2026-09-15 - sprite_pawn / foe_gen floor it)
        self.hp = self.maxhp
        self.maxmp = max(1, round(pts["mp"])); self.mp = math.ceil(self.maxmp * BAL["mp_start_frac"])
        self.atk, self.def_, self.mag, self.mdef, self.spd, self.hit = pts["atk"], pts["def"], pts["mag"], pts["mdef"], pts["spd"], pts["hit"]
        self.eva = pts["spd"] * BAL["spd_to_eva"]
        self.crit_rate, self.crit_multi, self.cnt = arch["crit"], arch["cmulti"], arch["cnt"]
        self.erode = arch.get("erode", 1)
        self.magic = arch["magic"]
        self.skills = skills if skills is not None else ([LIB[arch["skill"]]] if arch["skill"] else [])
        self.tic = rng.random() * .3
        self.tic_spd = BAL["tic_spd_base"] + math.sqrt(max(0, pts["spd"])) / BAL["tic_spd_div"]

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
    def hit(self, u, t, mult=1, label="", cdepth=0, magic=False):
        b, rng = BAL, self.rng
        apow = u.mag if magic else u.atk
        dpow = t.mdef if magic else t.def_
        s = u.hit + t.eva
        hc = 50
        if s > 0:
            r = u.hit / s
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
        dmg = max(.1, round(dmg * 10) / 10)
        stag = (1 + t.spd / 3) * (.01 + ((.085 if q >= .97 else .05) - .01) * q)
        if crit: stag += (1 + t.spd / 3) * .03
        t.tic -= stag * self.thr
        t.hp = max(0, t.hp - dmg)
        t.maxhp = max(1, t.maxhp - dmg * b["dmg_to_maxhp"] * t.erode)
        if t.hp > t.maxhp: t.hp = t.maxhp
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
        if s.kind == "mend": return (1 - t.hp / t.maxhp) * 95
        if s.kind == "heal": return (1 - t.hp / t.maxhp) * (80 + s.healp * 40)
        if s.kind in ("concuss", "stagger"): return 35 + t.spd * 4 + (t.tic / self.thr) * 25
        if s.kind in ("bolt", "spell"):
            sc = 50 + t.def_ * 2 - t.mdef + max(0, s.mult - 1.3) * 20
            if t.hp < t.maxhp * .35: sc += 20
            return sc
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
        if s.kind in ("strike", "heavy", "bolt", "spell"): self.hit(u, t, s.mult, s.name, 0, s.magic)
        elif s.kind == "reform": self.heal(u, u.maxhp * .4)
        elif s.kind == "drain":
            d = self.hit(u, t, s.mult, s.name, 0, s.magic)
            if d > 0: self.heal(u, d * (s.leech or .6))
        elif s.kind == "mend": self.heal(t, t.maxhp * .35)
        elif s.kind == "heal": self.heal(t, t.maxhp * s.healp)
        elif s.kind in ("concuss", "stagger"):
            d = self.hit(u, t, s.mult, s.name, 0, s.magic)
            if d > 0: t.tic -= self.thr * (s.stag or .45)
    def step(self):
        if self.over: return
        th = 1
        for p in self.all:
            if p.hp > 0 and p.tic_spd > th: th = p.tic_spd
        self.thr = th
        dt = min((max(0, (th - p.tic) / max(.01, p.tic_spd)) for p in self.all if p.hp > 0), default=None)
        if dt is None: self.over = True; return
        ready = []
        for p in self.all:
            if p.hp <= 0: continue
            p.tic += p.tic_spd * dt
            if p.tic >= th - 1e-4: ready.append(p)
        actor = self.rng.choice(ready)
        self.turn += 1
        plan = self.ai(actor)
        if plan is not None and actor.hp > 0 and plan[1].hp > 0:
            s, t = plan
            if s is None: self.hit(actor, t, 1, "", 0, actor.magic)
            else: actor.mp -= s.cost; self.effect(s, actor, t)
        actor.tic -= th
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
        out.append("  %-8s" % "" + "".join("%9s" % f for f in FOES) + "     mean")
        means = {}
        for c in CLASSES:
            row = []; acc = 0
            for fk in FOES:
                wr_, tn = winrate(lambda r, c=c, lv=lv: [sprite_pawn(c, lv, r)], lambda r, fk=fk, lv=lv: [foe_pawn(fk, lv, r)], n=300, seed=lv * 7 + 1)
                row.append("%5.0f/%-3.0f" % (wr_ * 100, tn)); acc += wr_
            means[c] = acc / len(FOES)
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
