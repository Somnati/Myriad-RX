"""collider_twin.py - a Python replica of THE COLLIDER (cas_tick's closed form, cas_cost, coll_collide, coll_cost) with
the GML's macros, greedy-played, to see the race before he does: hours to the horizon (e308 energy) on the first run
and on a run after crunches. Prints HOLDS when the first run lands in 1.5-6 h (the framework's bench took 3-4 h),
a crunched run is faster, and the collide-vs-grow tension is real (colliding every second loses to colliding
sparingly). Run: python collider_twin.py [--trace]"""
import math, re, os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
def M(n): return float(re.search(r"#macro\s+%s\s+([-.\d]+)" % n, src).group(1))
N, LZ, WALL, FMULT, FCOST, MCOST, MMULT, PAIR_E, CLEAN, RESIDUE = int(M("COLL_N")), M("COLL_LZ"), M("COLL_WALL"), M("COLL_FIELD_MULT"), M("COLL_FIELD_COST"), M("COLL_MAGNET_COST"), M("COLL_MAGNET_MULT"), M("COLL_PAIR_E"), M("COLL_CLEAN"), M("COLL_RESIDUE")
BASE = [1, 2, 4, 6, 9, 13, 18, 24]; STEP = [.255, .34, .425, .51, .68, .85, 1.02, 1.275]
AUTO = [0, 60, 30, 15]; AUTO_COST = [3, 5, 8]
L2 = math.log10(2)
def ladd(a, b):
    if a < b: a, b = b, a
    if a - b > 15: return a
    return a + math.log10(1 + 10 ** (b - a))
def lsub(a, b):
    r = 10 ** (b - a)
    return LZ if r >= 1 else a + math.log10(1 - r)
class Cas:
    def __init__(self): self.count = [LZ] * N; self.bought = [0] * N; self.stock = 1.0
    def rates(self, lf): return [(b // 10) * L2 + lf for b in self.bought]
    def tick(self, t, lf):
        if t <= 0: return
        la = self.rates(lf); lt = math.log10(t); new = [0.0] * N
        for i in range(N):
            s = self.count[i]; term = 0.0
            for j in range(i + 1, N):
                term += la[j] + lt - math.log10(j - i); s = ladd(s, self.count[j] + term)
            new[i] = s
        ft = la[0] + lt; fg = self.count[0] + ft
        for j in range(1, N):
            ft += la[j] + lt - math.log10(j + 1); fg = ladd(fg, self.count[j] + ft)
        self.count = new; self.stock = ladd(self.stock, fg)
    def cost(self, i, stepk=1.0): return BASE[i] + self.bought[i] * STEP[i] * stepk
    def buy(self, i, payer, q=1, stepk=1.0):
        if i > 0 and self.bought[i - 1] <= 0: return 0
        did = 0
        for _ in range(100000 if q == "max" else q):
            c = self.cost(i, stepk)
            if payer.stock < c: break
            payer.stock = lsub(payer.stock, c); self.bought[i] += 1; self.count[i] = ladd(self.count[i], 0); did += 1
        return did
class Coll:
    def __init__(self, crunches=0):
        self.m = Cas(); self.a = Cas(); self.energy = LZ; self.field = 0; self.auto_lv = 0; self.magnet_lv = 0; self.pct = 50
        self.inf = False; self.crunches = crunches; self.t = 0.0; self.collisions = 0
    def lfield(self): return self.field * math.log10(FMULT)
    def stepk(self): return RESIDUE ** min(self.crunches, 30)
    def window(self): return L2 * MMULT ** self.magnet_lv
    def clean(self):
        if self.m.stock < LZ / 2 or self.a.stock < LZ / 2: return 1
        return 1 + (CLEAN - 1) * max(0, 1 - abs(self.m.stock - self.a.stock) / self.window())
    def collide(self, pct=None):
        if self.inf: return LZ
        pct = self.pct if pct is None else pct
        mn = min(self.m.stock, self.a.stock)
        if mn < LZ / 2 or mn < 0: return LZ
        lp = mn + math.log10(pct / 100); cl = self.clean()
        if lp < 0: return LZ
        self.m.stock = lsub(self.m.stock, lp); self.a.stock = lsub(self.a.stock, lp)
        le = lp + math.log10(PAIR_E) + math.log10(cl)
        self.energy = ladd(self.energy, le); self.collisions += 1
        if self.energy >= WALL: self.energy = WALL; self.inf = True
        return le
    def cost(self, what):
        if what == "field": return FCOST + self.field
        if what == "auto": return -1 if self.auto_lv >= 3 else AUTO_COST[self.auto_lv]
        return -1 if self.magnet_lv >= 4 else MCOST + 2 * self.magnet_lv
    def buy(self, what):
        c = self.cost(what)
        if c < 0 or self.energy < c: return False
        self.energy = lsub(self.energy, c)
        if what == "field": self.field += 1
        elif what == "auto": self.auto_lv += 1
        else: self.magnet_lv += 1
        return True
    def tick(self, dt):
        if self.inf: return
        lf = self.lfield(); self.m.tick(dt, lf); self.a.tick(dt, lf); self.t += dt
def greedy(c, collide_every, buy_every=1):
    """the player: every second, the highest affordable tier on each side (max), field before yield before auto;
    a collision every `collide_every` seconds at 50%"""
    for side, payer in ((c.m, c.a), (c.a, c.m)):
        for i in range(N - 1, -1, -1):
            if i > 0 and side.bought[i - 1] <= 0: continue
            side.buy(i, payer, "max", c.stepk())
    for what in ("field", "magnet", "auto"):
        while c.cost(what) >= 0 and c.energy >= c.cost(what): c.buy(what)
    if int(c.t) % collide_every == 0: c.collide()
def race(crunches=0, collide_every=30, hours=12, trace=False):
    c = Coll(crunches); dt = 1.0
    while not c.inf and c.t < hours * 3600:
        greedy(c, collide_every); c.tick(dt)
        if trace and int(c.t) % 600 == 0:
            print("t %5.1fm energy 1e%6.1f  m 1e%6.1f a 1e%6.1f  field %d magnet %d auto %d  bought %s | %s" % (c.t / 60, c.energy, c.m.stock, c.a.stock, c.field, c.magnet_lv, c.auto_lv, c.m.bought, c.a.bought))
    return c
if __name__ == "__main__":
    trace = "--trace" in sys.argv
    first = race(0, 30, trace=trace)
    print("first run: %s in %.2f h (field %d, magnet %d, collisions %d)" % ("HORIZON" if first.inf else "no horizon", first.t / 3600, first.field, first.magnet_lv, first.collisions))
    third = race(2, 30); sixth = race(5, 30)
    print("third run (2 crunches): %s in %.2f h   sixth (5): %.2f h" % ("HORIZON" if third.inf else "no horizon", third.t / 3600, sixth.t / 3600))
    fast = race(0, 5, hours=first.t / 3600 + .5)
    slow = race(0, 300, hours=first.t / 3600 + .5)
    print("collide every 5 s: %s %.2f h   every 300 s: %s %.2f h" % ("HORIZON" if fast.inf else "no horizon", fast.t / 3600, "HORIZON" if slow.inf else "no horizon", slow.t / 3600))
    ok = first.inf and 1.5 <= first.t / 3600 <= 6 and third.inf and third.t < first.t and sixth.t < third.t and (not fast.inf or fast.t > first.t)
    print("HOLDS" if ok else "FAILS")
