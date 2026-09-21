"""delta_twin.py - a Python replica of ALLUVIUM's sim (delta_init / delta_drop / delta_tick) with the GML's constants, to see
the delta grow and the grain flow before he does. Run: python delta_twin.py [minutes]"""
import math, random, sys, re, os
ROOT = r"C:\Users\sora0\Desktop\GM Projects\Myriad RX.yyp"
src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
def M(n): return float(re.search(r"#macro\s+%s\s+([-.\d]+)" % n, src).group(1))
W, H, SEA = int(M("DELTA_W")), int(M("DELTA_H")), M("DELTA_SEA")
LIFE, INERTIA, CAP, MINSLOPE, DEPOSIT, ERODE, GRAV, EVAP, SILT_K, GIFT, WET_DECAY = int(M("DELTA_LIFE")), M("DELTA_INERTIA"), M("DELTA_CAP"), M("DELTA_MINSLOPE"), M("DELTA_DEPOSIT"), M("DELTA_ERODE"), M("DELTA_GRAV"), M("DELTA_EVAP"), M("DELTA_SILT_K"), M("DELTA_SEA_GIFT"), M("DELTA_WET_DECAY")
FLOOD_EVERY, FLOOD_LEN = M("DELTA_FLOOD_EVERY"), M("DELTA_FLOOD_LEN")
WET_GAIN, CROP_MAXH = M("DELTA_WET_GAIN"), M("DELTA_CROP_MAXH")
SEEDS = [dict(name="reeds", y=1, silt=.06, wet=.12, ripen=40), dict(name="barley", y=3, silt=.15, wet=.18, ripen=55), dict(name="rice", y=9, silt=.28, wet=.30, ripen=70), dict(name="saffron", y=30, silt=.45, wet=.25, ripen=110)]
rng = random.Random(7)
def hash_mix(a, b):
    h = ((int(a) & 0x7fffffff) ^ (((int(b) & 0x7fffffff) * 40503) & 0x7fffffff)) & 0x7fffffff
    h = (h * 48271) % 2147483647
    h = ((h ^ (h >> 11)) * 2654435) % 2147483647
    return h
def vn(x, y, s, salt):
    cx, cy = math.floor(x / s), math.floor(y / s); fx, fy = x / s - cx, y / s - cy
    fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
    h = lambda a, b: (hash_mix(a * 73 + b * 151, salt) % 10000) / 10000
    return (h(cx, cy) * (1 - fx) + h(cx + 1, cy) * fx) * (1 - fy) + (h(cx, cy + 1) * (1 - fx) + h(cx + 1, cy + 1) * fx) * fy
class D:
    def __init__(self, seed=12345):
        n = W * H
        self.hgt = [0.0] * n; self.silt = [0.0] * n; self.wet = [0.0] * n; self.crop = [0.0] * n; self.lev = [0] * n; self.sea0 = [False] * n
        cx0 = W * .5
        for y in range(H):
            for x in range(W):
                t = y / (H - 1); base = .92 + (-.02 - .92) * t
                nz = (vn(x, y, 9, seed) - .5) * .16 + (vn(x, y, 4, seed + 7) - .5) * .06
                val = .07 * math.exp(-((x - cx0 + 6 * (vn(0, y, 12, seed + 3) - .5)) / 5) ** 2)
                hv = max(-.06, min(1, base + nz - val))
                self.hgt[x + y * W] = hv; self.sea0[x + y * W] = hv < SEA
        self.grain = 25.0; self.life = 0.0; self.rain = 1; self.springs = 1; self.rich = 1; self.seed = 0
        self.flood_t = FLOOD_EVERY; self.flood = 0; self.acc = 0; self.harvests = 0; self.silted = 0
    def springs_at(self):
        out = [(W * .5, 1.5)]
        if self.springs >= 2: out.append((W * .5 - 17, 1.5))
        if self.springs >= 3: out.append((W * .5 + 17, 1.5))
        return out
    def drop(self, sx, sy, water=1.0):
        hg = self.hgt; lv = self.lev
        px, py = sx + rng.uniform(-.6, .6), sy + rng.uniform(-.4, .4); dx = dy = 0.0; vel = 1.0; sed = 0.0
        capk = CAP * (1 + .35 * (self.rich - 1)) * (1.5 if self.flood > 0 else 1); flood = self.flood > 0
        for _ in range(LIFE):
            cx, cy = max(0, min(W - 1, math.floor(px))), max(0, min(H - 1, math.floor(py))); ci = cx + cy * W
            gx = hg[min(W - 1, cx + 1) + cy * W] - hg[max(0, cx - 1) + cy * W]
            gy = hg[cx + min(H - 1, cy + 1) * W] - hg[cx + max(0, cy - 1) * W]
            dx = dx * INERTIA - gx * (1 - INERTIA); dy = dy * INERTIA - gy * (1 - INERTIA)
            ln = math.hypot(dx, dy)
            if ln < 1e-4: a = rng.uniform(0, 2 * math.pi); dx, dy = math.cos(a), math.sin(a)
            else: dx /= ln; dy /= ln
            nx, ny = px + dx, py + dy
            if nx < 0 or nx >= W or ny < 0 or ny >= H: break
            ncx, ncy = math.floor(nx), math.floor(ny); ni = ncx + ncy * W
            hold, hnew = hg[ci], hg[ni]; dh = hnew - hold
            self.wet[ni] = min(1, self.wet[ni] + WET_GAIN)
            if flood and self.crop[ni] > 0 and lv[ni] != 1:
                guard = any(0 <= ncx + ox < W and 0 <= ncy + oy < H and lv[ncx + ox + (ncy + oy) * W] == 1 for oy in (-1, 0, 1) for ox in (-1, 0, 1))
                if not guard: self.crop[ni] = 0
            if hnew < SEA:
                amt = sed + GIFT * water
                hg[ni] = min(SEA + .02, hg[ni] + amt * .65)
                qi, qj = ncx + rng.choice((-1, 0, 1)), ncy + rng.choice((0, 1))
                if 0 <= qi < W and 0 <= qj < H and hg[qi + qj * W] < SEA: hg[qi + qj * W] = min(SEA + .01, hg[qi + qj * W] + amt * .35)
                self.silt[ni] = min(1, self.silt[ni] + amt * SILT_K); self.silted += amt
                break
            cap = max(-dh, MINSLOPE) * vel * water * capk
            if sed > cap or dh > 0:
                dep = min(dh, sed) if dh > 0 else (sed - cap) * DEPOSIT
                dep = max(0, min(dep, sed))
                hg[ci] += dep; self.silt[ci] = min(1, self.silt[ci] + dep * SILT_K); sed -= dep
            else:
                ero = min((cap - sed) * ERODE, -dh)
                if lv[ci] == 1: ero *= .1
                ero = max(0, min(ero, hg[ci] - (SEA + .005)))
                hg[ci] -= ero; sed += ero
            vel = math.sqrt(max(.05, vel * vel - dh * GRAV))
            water *= (1 - EVAP)
            if water < .06: hg[ci] += sed; self.silt[ci] = min(1, self.silt[ci] + sed * SILT_K); break
            px, py = nx, ny
    def tick(self, dt):
        if self.flood > 0: self.flood = max(0, self.flood - dt)
        else:
            self.flood_t -= dt
            if self.flood_t <= 0: self.flood = FLOOD_LEN; self.flood_t = FLOOD_EVERY * rng.uniform(.8, 1.25)
        rate = (1.6 + .8 * (self.rain - 1)) * (6 if self.flood > 0 else 1)
        self.acc += rate * dt; nd = math.floor(self.acc); self.acc -= nd
        sp = self.springs_at()
        for _ in range(nd):
            s = rng.choice(sp); self.drop(s[0], s[1], 2 if self.flood > 0 else 1)
        sd = SEEDS[self.seed]; decay = math.exp(-WET_DECAY * dt); got = 0.0
        hg = self.hgt
        for i in range(W * H):
            self.wet[i] *= decay
            if hg[i] < SEA or hg[i] > CROP_MAXH or self.lev[i] != 0: self.crop[i] = 0; continue
            wt, si = self.wet[i], self.silt[i]
            if wt >= sd["wet"] and si >= sd["silt"]:
                self.crop[i] += dt / sd["ripen"] * (.6 + si) * min(1, wt * 2.5)
                while self.crop[i] >= 1:
                    self.crop[i] -= 1
                    x, y = i % W, i // W; bysea = False
                    if hg[i] < SEA + .04:
                        if x > 0 and hg[i - 1] < SEA: bysea = True
                        if x < W - 1 and hg[i + 1] < SEA: bysea = True
                        if y > 0 and hg[i - W] < SEA: bysea = True
                        if y < H - 1 and hg[i + W] < SEA: bysea = True
                    salt = .5 if (bysea and si < .5) else 1
                    got += sd["y"] * (1 + si) * salt; self.harvests += 1
            elif wt < .05: self.crop[i] = max(0, self.crop[i] - dt * .01)
        self.grain += got; self.life += got
        return got
    def stats(self):
        land = sum(1 for i in range(W * H) if self.hgt[i] >= SEA)
        newl = sum(1 for i in range(W * H) if self.hgt[i] >= SEA and self.sea0[i])
        wet = sum(1 for i in range(W * H) if self.hgt[i] >= SEA and self.wet[i] > .12)
        fields = sum(1 for i in range(W * H) if self.crop[i] > 0)
        return land, newl, wet, fields
def cost(d, what):
    if what == "rain": return round(30 * 1.7 ** (d.rain - 1))
    if what == "springs": return -1 if d.springs >= 3 else (400 if d.springs == 1 else 6000)
    if what == "rich": return round(80 * 1.8 ** (d.rich - 1))
    if what == "seed": return -1 if d.seed >= 3 else [150, 2500, 40000][d.seed]
    return -1
def ascii(d):
    rows = []
    for y in range(H):
        r = ""
        for x in range(W):
            i = x + y * W; h = d.hgt[i]
            if h < SEA: r += "~" if not d.sea0[i] else ("." if h < SEA - .1 else ",")
            elif d.crop[i] > .5: r += "$"
            elif d.crop[i] > 0: r += "'"
            elif d.wet[i] > .3: r += "="
            elif d.silt[i] > .3: r += "#"
            elif h > .75: r += "^"
            else: r += " "
        rows.append(r)
    return "\n".join(rows)
if __name__ == "__main__":
    mins = float(sys.argv[1]) if len(sys.argv) > 1 else 20
    d = D(); auto = "--auto" in sys.argv
    t = 0; step = 1.0
    print("start: land %d newland %d" % d.stats()[:2])
    while t < mins * 60:
        d.tick(step); t += step
        if auto:   # the greedy player: buy the cheapest thing affordable, rain first
            for what in ("seed", "rain", "rich", "springs"):
                c = cost(d, what)
                if c > 0 and d.grain >= c * 1.2:
                    d.grain -= c
                    if what == "rain": d.rain += 1
                    elif what == "rich": d.rich += 1
                    elif what == "springs": d.springs += 1
                    elif what == "seed": d.seed += 1
                    break
        if int(t) % 120 == 0:
            land, newl, wet, fields = d.stats()
            print("t %4dm  grain %8.0f  life %9.0f  land %4d  newland %3d  wet %3d  fields %3d  rain %d rich %d springs %d seed %d  flood %s" % (t / 60, d.grain, d.life, land, newl, wet, fields, d.rain, d.rich, d.springs, d.seed, "YES" if d.flood > 0 else "in %ds" % d.flood_t))
    print(ascii(d))
