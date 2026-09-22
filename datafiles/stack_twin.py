"""stack_twin.py - a Python replica of THE STACK (stk_config / stk_tick / stk_cap / stk_thr / stk_bonus) with the GML's
macros, greedy-played, to see the pace before he does: the first cap buy, aether's opening, quintessence's, the first
turn. Prints HOLDS when the pace lands (cap under 2 min, aether 2-10 min, quint 10-50 min, a turn within 2 h) and the
DIMINISHING LAW holds (spark's growth stays sub-exponential: each hour's spark under 4x the last).
Run: python stack_twin.py [hours] [--trace]"""
import math, re, os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
def M(n): return float(re.search(r"#macro\s+%s\s+([-.\d]+)" % n, src).group(1))
THR_BASE, THR_MULT, BPOW, CPOW = M("STK_THR_BASE"), M("STK_THR_MULT"), M("STK_BONUS_POW"), M("STK_CAP_POW")
CAP_BASE, CAP_STEP, CAP_COST, CAP_MULT = M("STK_CAP_BASE"), M("STK_CAP_STEP"), M("STK_CAP_COST"), M("STK_CAP_MULT")
SPD_AE, SPD_QU, F_ON, F_OFF, CIN_SPD, CIN_SPK = M("STK_SPEED_AE"), M("STK_SPEED_QU"), M("STK_FOCUS_ON"), M("STK_FOCUS_OFF"), M("STK_CINDER_SPD"), M("STK_CINDER_SPK")
cfg_src = open(os.path.join(ROOT, "scripts", "stk_config", "stk_config.gml"), encoding="utf-8").read()
CFG = []
for layer in re.findall(r"\[\s*//\s*[A-Z]+\n(.*?)\n\t\t\]", cfg_src, re.S):
    rows = []
    for m in re.finditer(r'key : "(\w+)".*?per : (\d+),\s*kind : "(\w+)"[^}]*?(?:thk : (\d+))?\s*\}', layer):
        rows.append(dict(key=m.group(1), per=float(m.group(2)), kind=m.group(3), thk=float(m.group(4) or 1)))
    CFG.append(rows)
assert len(CFG) == 3 and all(len(r) == 6 for r in CFG), CFG
MS = [10, 25, 50, 100, 200]
class S:
    def __init__(self):
        self.layers = [[dict(alloc=0, prog=0.0, level=0) for _ in rows] for rows in CFG]
        self.focus = [-1, -1, -1]; self.spark = 0.0; self.life = 0.0; self.cap_lv = 0; self.cinders = 0; self.turns = 0
    def per(self, l, i):
        p = CFG[l][i]["per"]; lv = self.layers[l][i]["level"]
        for m in MS:
            if lv >= m: p *= 1.5
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
            for i in range(6):
                if CFG[l][i]["kind"] == kind: m *= self.bonus(l, i)
        return m
    def capof(self, l, i):
        lv = self.layers[l][i]["level"]
        return 0 if lv <= 0 else math.floor(CFG[l][i]["per"] / 100 * lv ** CPOW)
    def cap(self, l):
        kind = ["cap_en", "cap_ae", "cap_qu"][l]; kflat = kind + "_flat"
        base = CAP_BASE + self.cap_lv * CAP_STEP if l == 0 else 0
        return base + sum(self.capof(k, i) for k in range(3) for i in range(6) if CFG[k][i]["kind"] in (kind, kflat))
    def speed(self, l):
        base = [1, SPD_AE, SPD_QU][l]; kind = ["speed_en", "speed_ae", "speed_qu"][l]
        return base * self.mult(kind) * self.mult("speed_all") * (1 + CIN_SPD * self.cinders)
    def thr(self, l, i, lv):
        return THR_BASE * CFG[l][i]["thk"] * THR_MULT ** lv / self.mult(["thr_en", "thr_ae", "thr_qu"][l])
    def spark_rate(self):
        g = sum(self.per(l, i) / 100 * self.layers[l][i]["level"] ** BPOW for l in range(3) for i in range(6) if CFG[l][i]["kind"] == "gen" and self.layers[l][i]["level"] > 0)
        return g * self.mult("spark") * (1 + CIN_SPK * self.cinders)
    def cap_cost(self): return math.ceil(CAP_COST * CAP_MULT ** self.cap_lv / self.mult("capcost"))
    def cinders_now(self):
        return math.floor(math.sqrt(sum(self.layers[l][i]["level"] * [1, 3, 5][l] for l in range(3) for i in range(6))) / 4)
    def tick(self, dt):
        got = self.spark_rate() * dt; self.spark += got; self.life += got
        for l in range(3):
            spd = self.speed(l)
            for i, k in enumerate(self.layers[l]):
                if k["alloc"] <= 0: continue
                f = 1 if self.focus[l] < 0 else (F_ON if self.focus[l] == i else F_OFF)
                k["prog"] += k["alloc"] * spd * f * dt
                thr = self.thr(l, i, k["level"])
                while k["prog"] >= thr:
                    k["prog"] -= thr; k["level"] += 1; thr = self.thr(l, i, k["level"])
        return got
def spread(L, cap, w):
    """the cap dealt a unit at a time to the sink furthest under its weight (a small cap still lands where it matters)"""
    for k in L: k["alloc"] = 0
    for _ in range(int(cap)):
        i = max(range(len(w)), key=lambda j: w[j] / (L[j]["alloc"] + 1))
        if w[i] <= 0: break
        L[i]["alloc"] += 1
def greedy(s):
    """the player who reads the room: energy - the generator first until spark flows, then the well to open aether, the
    rest spread; aether - resonator / amplifier / deep well; quintessence - keystone / tempo. buys cap whenever it can."""
    L = s.layers[0]; cap = s.cap(0)
    if L[0]["level"] < 3: spread(L, cap, [1, 0, 0, 0, 0, 0])
    elif s.cap(1) < 1: spread(L, cap, [3, 1, 0, 4, 1, 0])
    else: spread(L, cap, [3, 1, 1, 2, 2, 1])
    s.focus[0] = 3 if (L[0]["level"] >= 3 and s.cap(1) < 1) else -1
    spread(s.layers[1], s.cap(1), [3, 2, 3, 1, 1, 1])
    spread(s.layers[2], s.cap(2), [3, 3, 1, 2, 1, 1])
    while s.spark >= s.cap_cost():
        s.spark -= s.cap_cost(); s.cap_lv += 1
def run(s, seconds, trace=False, marks=None, t0=0):
    t = 0; hourly = []; last_life = s.life; dt = 1.0
    while t < seconds:
        greedy(s); s.tick(dt); t += dt
        if marks is not None:
            if "cap" not in marks and s.cap_lv >= 1: marks["cap"] = t
            if "aether" not in marks and s.cap(1) >= 1: marks["aether"] = t
            if "quint" not in marks and s.cap(2) >= 1: marks["quint"] = t
            if "turn" not in marks and s.cinders_now() >= 1 and s.cap(2) >= 1: marks["turn"] = t
        if trace and int(t) % 300 == 0:
            print("t %5.1fm spark %9.0f (+%.2f/s) cap %3d/%3d/%3d buys %2d cinders-now %d lv %s" % (t / 60, s.spark, s.spark_rate(), s.cap(0), s.cap(1), s.cap(2), s.cap_lv, s.cinders_now(), [[k["level"] for k in L] for L in s.layers]))
        if int(t) % 3600 == 0: hourly.append(s.life - last_life); last_life = s.life
    return hourly
if __name__ == "__main__":
    hours = float(sys.argv[1]) if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else 3
    trace = "--trace" in sys.argv
    s = S(); marks = {}
    hourly = run(s, hours * 3600, trace, marks)
    print("marks (min):", {k: round(v / 60, 1) for k, v in marks.items()})
    print("hourly spark:", [round(h) for h in hourly])
    print("levels:", [[k["level"] for k in L] for L in s.layers], "cap buys", s.cap_lv, "caps", s.cap(0), s.cap(1), s.cap(2), "cinders on offer", s.cinders_now())
    s2 = S(); s2.cinders = max(1, s.cinders_now()); s2.turns = 1; m2 = {}
    run(s2, 3600, False, m2)
    print("after a turn (%d cinders):" % s2.cinders, {k: round(v / 60, 1) for k, v in m2.items()})
    ok = "cap" in marks and marks["cap"] <= 120 and "aether" in marks and 120 <= marks["aether"] <= 600 and "quint" in marks and 600 <= marks["quint"] <= 3000 and "turn" in marks and marks["turn"] <= 7200
    ratios = [hourly[i + 1] / max(1, hourly[i]) for i in range(len(hourly) - 1)]
    ok = ok and all(r < 4 for r in ratios[1:])
    print("hour ratios:", [round(r, 2) for r in ratios])
    print("HOLDS" if ok else "FAILS")
