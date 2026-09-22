"""stack_twin.py - a Python replica of THE STACK (stk_config / stk_tick / stk_cap / stk_thr / stk_bonus + q317's tide,
burn, veins, the seventh and the cinder tree) with the GML's macros, greedy-played, to see the pace before he does:
the first cap buy, aether's opening, quintessence's, the first turn, and the runs AFTER a turn with the tree bought.
Prints HOLDS when the pace lands (cap under 2 min, aether 1.5-10 min [the tide may flood energy first], quint 10-50 min, a turn within 2 h) and the
DIMINISHING LAW holds (spark's growth stays sub-exponential: each hour's spark under 4x the last).
Run: python stack_twin.py [hours] [--trace]"""
import math, re, os, sys, random
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
def M(n): return float(re.search(r"#macro\s+%s\s+([-.\d]+)" % n, src).group(1))
THR_BASE, THR_MULT, BPOW, CPOW = M("STK_THR_BASE"), M("STK_THR_MULT"), M("STK_BONUS_POW"), M("STK_CAP_POW")
CAP_BASE, CAP_STEP, CAP_COST, CAP_MULT = M("STK_CAP_BASE"), M("STK_CAP_STEP"), M("STK_CAP_COST"), M("STK_CAP_MULT")
SPD_AE, SPD_QU, F_ON, F_OFF, CIN_SPD, CIN_SPK = M("STK_SPEED_AE"), M("STK_SPEED_QU"), M("STK_FOCUS_ON"), M("STK_FOCUS_OFF"), M("STK_CINDER_SPD"), M("STK_CINDER_SPK")
TIDE_LEN, TIDE_MULT, BURN_PRICE, BURN_PCT, BURN_LEN, VEIN_MULT, SIPHON = M("STK_TIDE_LEN"), M("STK_TIDE_MULT"), M("STK_BURN_PRICE"), M("STK_BURN_PCT"), M("STK_BURN_LEN"), M("STK_VEIN_MULT"), M("STK_SIPHON")
cfg_src = open(os.path.join(ROOT, "scripts", "stk_config", "stk_config.gml"), encoding="utf-8").read()
CFG = []
for layer in re.findall(r"\[\s*//\s*[A-Z]+\n(.*?)\n\t\t\]", cfg_src, re.S):
    rows = []
    for m in re.finditer(r'key : "(\w+)".*?per : (\d+),\s*kind : "(\w+)"[^}]*?(?:thk : (\d+))?\s*\}', layer):
        rows.append(dict(key=m.group(1), per=float(m.group(2)), kind=m.group(3), thk=float(m.group(4) or 1)))
    CFG.append(rows)
assert len(CFG) == 3 and all(len(r) == 7 for r in CFG), [len(r) for r in CFG]
perk_src = open(os.path.join(ROOT, "scripts", "stk_perks", "stk_perks.gml"), encoding="utf-8").read()
PERKS = {m.group(1): dict(base=int(m.group(2)), step=int(m.group(3)), max=int(m.group(4))) for m in re.finditer(r'key : "(\w+)".*?base : (\d+), step : (\d+), max : (\d+)', perk_src)}
assert len(PERKS) == 9, PERKS
MS = [10, 25, 50, 100, 200]
class S:
    def __init__(self):
        self.layers = [[dict(alloc=0, prog=0.0, level=0) for _ in rows] for rows in CFG]
        self.focus = [-1, -1, -1]; self.vein = [-1, -1, -1]; self.vein2 = [-1, -1, -1]; self.burn_t = [0, 0, 0]; self.burn_add = [0, 0, 0]
        self.spark = 0.0; self.life = 0.0; self.cap_lv = 0; self.cinders = 0; self.spent = 0; self.perks = {}; self.turns = 0; self.tide = 0
        self.roll_veins()
    def perk(self, k): return self.perks.get(k, 0)
    def perk_cost(self, k):
        d = PERKS[k]; r = self.perk(k)
        return -1 if r >= d["max"] else d["base"] + d["step"] * r
    def perk_buy(self, k):
        c = self.perk_cost(k)
        if c < 0 or self.cinders < c: return False
        self.cinders -= c; self.spent += c; self.perks[k] = self.perk(k) + 1
        if k == "headstart": self.layers[0][3]["level"] = max(self.layers[0][3]["level"], 3 * self.perk("headstart"))
        return True
    def n(self, l): return 7 if self.perk("seventh") > 0 else 6
    def roll_veins(self):
        rng = random.Random(74123 ^ (self.turns * 2654435761))
        for l in range(3):
            self.vein[l] = rng.randrange(6); self.vein2[l] = (self.vein[l] + 1 + rng.randrange(5)) % 6
    def per(self, l, i):
        p = CFG[l][i]["per"]; lv = self.layers[l][i]["level"]
        for m in MS:
            if lv >= m: p *= 1.5
        if self.vein[l] == i or (self.vein2[l] == i and self.perk("veins") > 0): p *= VEIN_MULT
        if CFG[l][i]["kind"] != "per_all":
            ks = self.layers[2][0]["level"]
            if ks > 0: p *= 1 + CFG[2][0]["per"] / 100 * ks ** BPOW
        return p
    def bonus(self, l, i):
        lv = self.layers[l][i]["level"]
        return 1 if lv <= 0 else 1 + self.per(l, i) / 100 * lv ** BPOW
    def mult(self, kind):
        m = 1
        for l in range(3):
            for i in range(self.n(l)):
                if CFG[l][i]["kind"] == kind: m *= self.bonus(l, i)
        f = self.focus[1]
        if self.n(1) >= 7 and f >= 0 and f != 6 and self.layers[1][6]["level"] > 0 and CFG[1][f]["kind"] == kind: m *= self.bonus(1, 6)
        return m
    def capof(self, l, i):
        lv = self.layers[l][i]["level"]
        return 0 if lv <= 0 else math.floor(CFG[l][i]["per"] / 100 * lv ** CPOW)
    def cap(self, l):
        kind = ["cap_en", "cap_ae", "cap_qu"][l]; kflat = kind + "_flat"
        base = CAP_BASE + self.cap_lv * CAP_STEP if l == 0 else 0
        c = base + sum(self.capof(k, i) for k in range(3) for i in range(self.n(k)) if CFG[k][i]["kind"] in (kind, kflat))
        if c > 0 and self.burn_t[l] > 0: c += self.burn_add[l]
        return c
    def focus_on(self): return F_ON + .25 * self.perk("focus")
    def tide_mult(self): return TIDE_MULT + .5 * self.perk("tidewatch")
    def speed(self, l):
        base = [1, SPD_AE, SPD_QU][l]; kind = ["speed_en", "speed_ae", "speed_qu"][l]
        v = base * self.mult(kind) * self.mult("speed_all") * (1 + CIN_SPD * self.cinders)
        if self.tide == l: v *= self.tide_mult()
        return v
    def thr(self, l, i, lv):
        return THR_BASE * CFG[l][i]["thk"] * THR_MULT ** lv / self.mult(["thr_en", "thr_ae", "thr_qu"][l])
    def spark_rate(self):
        g = sum(self.per(l, i) / 100 * self.layers[l][i]["level"] ** BPOW for l in range(3) for i in range(self.n(l)) if CFG[l][i]["kind"] == "gen" and self.layers[l][i]["level"] > 0)
        return g * self.mult("spark") * (1 + CIN_SPK * self.cinders)
    def cap_cost(self): return math.ceil(CAP_COST * CAP_MULT ** self.cap_lv / self.mult("capcost"))
    def burn_cost(self): return math.ceil(self.cap_cost() * BURN_PRICE)
    def burn(self, l):
        if self.burn_t[l] > 0: return False
        base = self.cap(l)
        if base < 1 or self.spark < self.burn_cost(): return False
        self.spark -= self.burn_cost(); self.burn_add[l] = max(1, math.floor(base * BURN_PCT)); self.burn_t[l] = BURN_LEN * (1 + .5 * self.perk("burn"))
        return True
    def cinders_now(self):
        c = math.sqrt(sum(self.layers[l][i]["level"] * [1, 3, 5][l] for l in range(3) for i in range(self.n(l)))) / 4
        if self.n(2) >= 7: c *= self.bonus(2, 6)
        return math.floor(c)
    def clamp(self):
        for l in range(3):
            cap = self.cap(l); tot = sum(k["alloc"] for k in self.layers[l])
            for k in reversed(self.layers[l]):
                if tot <= cap: break
                cut = min(k["alloc"], tot - cap); k["alloc"] -= cut; tot -= cut
    def tick(self, dt, at):
        self.tide = int(math.floor((at + dt * .5) / TIDE_LEN)) % 3
        got = self.spark_rate() * dt; self.spark += got; self.life += got
        feed = 0
        if self.n(0) >= 7 and self.layers[0][6]["alloc"] > 0:
            nw = sum(1 for i in range(self.n(1)) if self.layers[1][i]["alloc"] > 0)
            if nw > 0: feed = self.layers[0][6]["alloc"] * self.speed(0) * SIPHON * self.bonus(0, 6) * dt / nw
        clamp = False
        for l in range(3):
            spd = self.speed(l)
            for i in range(self.n(l)):
                k = self.layers[l][i]
                if k["alloc"] <= 0: continue
                f = 1 if self.focus[l] < 0 else (self.focus_on() if self.focus[l] == i else F_OFF)
                k["prog"] += k["alloc"] * spd * f * dt + (feed if l == 1 else 0)
                thr = self.thr(l, i, k["level"])
                while k["prog"] >= thr:
                    k["prog"] -= thr; k["level"] += 1; thr = self.thr(l, i, k["level"])
            if self.burn_t[l] > 0:
                self.burn_t[l] -= dt
                if self.burn_t[l] <= 0: self.burn_t[l] = 0; self.burn_add[l] = 0; clamp = True
        if clamp: self.clamp()
        return got
    def turn(self):
        c = self.cinders_now()
        if c < 1 or self.cap(2) < 1: return False
        cin, t, life, spent, perks, old = self.cinders + c, self.turns + 1, self.life, self.spent, self.perks, self.layers
        self.__init__(); self.cinders = cin; self.turns = t; self.life = life; self.spent = spent; self.perks = perks
        keep = .1 * self.perk("keep")
        if keep > 0:
            for l in range(3):
                for i in range(7): self.layers[l][i]["level"] = math.floor(old[l][i]["level"] * keep)
        hs = self.perk("headstart")
        if hs > 0: self.layers[0][3]["level"] = max(self.layers[0][3]["level"], 3 * hs)
        self.roll_veins()
        return True
def spread(L, cap, w):
    """the cap dealt a unit at a time to the sink furthest under its weight (a small cap still lands where it matters)"""
    for k in L: k["alloc"] = 0
    for _ in range(int(cap)):
        i = max(range(len(w)), key=lambda j: w[j] / (L[j]["alloc"] + 1))
        if w[i] <= 0: break
        L[i]["alloc"] += 1
def greedy(s):
    """the player who reads the room: energy - the generator first until spark flows, then the well to open aether, the
    rest spread; aether - resonator / amplifier / deep well; quintessence - keystone / tempo. buys cap whenever it can,
    burns the flooded layer when a cap buy is out of reach; focuses the well, then aether's resonator (the mirror's meat)."""
    L = s.layers[0]; cap = s.cap(0); n7 = s.n(0) >= 7
    if L[0]["level"] < 3: spread(L, cap, [1, 0, 0, 0, 0, 0, 0])
    elif s.cap(1) < 1: spread(L, cap, [3, 1, 0, 4, 1, 0, 0])
    else: spread(L, cap, [3, 1, 1, 2, 2, 1, 2 if n7 else 0])
    s.focus[0] = 3 if (L[0]["level"] >= 3 and s.cap(1) < 1) else -1
    spread(s.layers[1], s.cap(1), [3, 2, 3, 1, 1, 1, 1 if n7 else 0])
    s.focus[1] = 0 if s.cap(1) >= 4 else -1
    spread(s.layers[2], s.cap(2), [3, 3, 1, 2, 1, 1, 2 if n7 else 0])
    while s.spark >= s.cap_cost():
        s.spark -= s.cap_cost(); s.cap_lv += 1
    if s.spark >= s.burn_cost() and s.spark < s.cap_cost() * .8 and s.cap(s.tide) > 0: s.burn(s.tide)
def run(s, seconds, trace=False, marks=None, t0=0):
    t = 0; hourly = []; last_life = s.life; dt = 1.0
    while t < seconds:
        greedy(s); s.tick(dt, t0 + t); t += dt
        if marks is not None:
            if "cap" not in marks and s.cap_lv >= 1: marks["cap"] = t
            if "aether" not in marks and s.cap(1) >= 1: marks["aether"] = t
            if "quint" not in marks and s.cap(2) >= 1: marks["quint"] = t
            if "turn" not in marks and s.cinders_now() >= 1 and s.cap(2) >= 1: marks["turn"] = t
        if trace and int(t) % 300 == 0:
            print("t %5.1fm spark %9.0f (+%.2f/s) cap %3d/%3d/%3d buys %2d tide %d burn %s cinders-now %d lv %s" % (t / 60, s.spark, s.spark_rate(), s.cap(0), s.cap(1), s.cap(2), s.cap_lv, s.tide, [round(b) for b in s.burn_t], s.cinders_now(), [[k["level"] for k in L[:s.n(0)]] for L in s.layers]))
        if int(t) % 3600 == 0: hourly.append(s.life - last_life); last_life = s.life
    return hourly
if __name__ == "__main__":
    hours = float(sys.argv[1]) if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else 3
    trace = "--trace" in sys.argv
    s = S(); marks = {}
    hourly = run(s, hours * 3600, trace, marks)
    print("marks (min):", {k: round(v / 60, 1) for k, v in marks.items()})
    print("hourly spark:", [round(h) for h in hourly])
    print("levels:", [[k["level"] for k in L[:6]] for L in s.layers], "cap buys", s.cap_lv, "caps", s.cap(0), s.cap(1), s.cap(2), "cinders on offer", s.cinders_now(), "veins", s.vein)
    # the turns: a run an hour, the tree bought greedily (headstart, then the seventh, the keep, sharper focus...)
    s2 = S(); s2.cinders = max(1, s.cinders_now()); s2.turns = 1; s2.roll_veins()
    for r in range(4):
        for k in ("headstart", "seventh", "keep", "focus", "veins", "tidewatch", "burn", "reach", "hand"):
            while s2.perk_cost(k) >= 0 and s2.cinders >= s2.perk_cost(k) + 2: s2.perk_buy(k)
        m2 = {}; run(s2, 3600, False, m2, t0=(r + 1) * 3600)
        print("run %d (turn %d): held %d spent %d perks %s  aether %.1fm quint %s  caps %d/%d/%d  offer +%d" % (r + 2, s2.turns, s2.cinders, s2.spent, {k: v for k, v in s2.perks.items()}, m2.get("aether", 0) / 60, ("%.1fm" % (m2["quint"] / 60)) if "quint" in m2 else "-", s2.cap(0), s2.cap(1), s2.cap(2), s2.cinders_now()))
        if not s2.turn(): print("  (no turn possible)")
    ok = "cap" in marks and marks["cap"] <= 120 and "aether" in marks and 90 <= marks["aether"] <= 600 and "quint" in marks and 600 <= marks["quint"] <= 3000 and "turn" in marks and marks["turn"] <= 7200
    ratios = [hourly[i + 1] / max(1, hourly[i]) for i in range(len(hourly) - 1)]
    ok = ok and all(r < 4 for r in ratios[1:])
    print("hour ratios:", [round(r, 2) for r in ratios])
    print("HOLDS" if ok else "FAILS")
