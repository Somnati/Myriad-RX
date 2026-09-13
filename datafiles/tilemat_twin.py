"""tilemat_twin.py - THE COLOUR LAW, measured (his rule, 2026-09-13:
"maintain the vanilla color output... i don't want a shader affecting
the overall brightness of a tile").

sh_tile_mat paints a tile body as colour x (1 + amp x d), d a posterized
pattern in -1..1. Multiplicative means hue and saturation are untouched
cell by cell; the law then reduces to ONE number per material: the mean
of d over the tile and over time must be zero. This ports every
material's math (same hash, same noise, same thresholds - the shader is
the source; keep them in step) and measures it at the tile's real size
on the real grid, across the board's positions and a minute of time.

Bars: |mean d| under .03 per material (at amp .35 that is a 1% luma
drift - the invisible line), and every cell within amp x 1.2 of the
body so a crest never reads as the next rung.

Run:  python datafiles/tilemat_twin.py
"""
import math
import os
import re
import sys

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def macro(name, default):
    src = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()
    m = re.search(r"^#macro\s+%s\s+([-+.\d]+)" % name, src, re.M)
    return float(m.group(1)) if m else default


AMP = macro("TILE_MAT_AMP", .35)
PAR_PX = macro("TILE_MAT_PAR", 4)

ok = True


def say(passed, label, detail=""):
    global ok
    ok = ok and passed
    print(("  HOLDS  " if passed else "  FAILS  ") + label + (("   " + detail) if detail else ""))


# ---- the shader's math, term for term ----
def fract(x): return x - np.floor(x)


def gmod(x, y): return x - y * np.floor(x / y)   # GLSL mod


def hash21(px, py):
    x = fract(px * .1031); y = fract(py * .1031); z = fract(px * .1031)
    d = x * (y + 33.33) + y * (z + 33.33) + z * (x + 33.33)
    x = x + d; y = y + d; z = z + d
    return fract((x + y) * z)


def vnoise(px, py):
    ix, iy = np.floor(px), np.floor(py)
    fx, fy = px - ix, py - iy
    fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
    a = hash21(ix, iy); b = hash21(ix + 1, iy); c = hash21(ix, iy + 1); d = hash21(ix + 1, iy + 1)
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def tones(n, th): return np.where(n > th, 1.0, np.where(n < -th, -1.0, 0.0))


def sd_rr(px, py, bx, by, r):
    dx = np.abs(px) - (bx - r); dy = np.abs(py) - (by - r)
    return np.sqrt(np.maximum(dx, 0) ** 2 + np.maximum(dy, 0) ** 2) - r + np.minimum(np.maximum(dx, dy), 0)


def pattern(kind, qx, qy, w, h, t, view, par, seed):
    """d for a tile body at room (qx, qy) size (w, h), time t. The cell grid."""
    cx, cy = np.meshgrid(np.arange(w), np.arange(h))
    px = qx + cx + .5; py = qy + cy + .5            # world anchor
    hwx, hwy = w * .5, h * .5
    qxx = cx + .5 - hwx; qyy = cy + .5 - hwy         # tile-centred
    if kind == 1:
        n = np.array([1.0, .6]); n = n / np.linalg.norm(n)
        ph = fract((px * n[0] + py * n[1] - t * 40) / 480)
        return np.where(ph < .05, 1.0, np.where(ph < .10, -1.0, 0.0))
    if kind == 2:
        n = vnoise(px * .11 + t * .35 + seed, py * .11 + t * .20 + seed) * .65 \
            + vnoise(px * .23 - t * .25 + seed * 3, py * .23 + t * .30 + seed * 3) * .35
        return tones((n - .5) * 2, .22)
    if kind == 3:
        ccx, ccy = qx + hwx, qy + hwy
        shx = -(ccx - view[0]) * par - 1.5; shy = -(ccy - view[1]) * par - 1.5
        so = sd_rr(qxx, qyy, hwx, hwy, 4.0)
        sm = so + 2.0
        sf = sd_rr(qxx - shx, qyy - shy, hwx - 3, hwy - 3, 1.0)
        lamp = np.clip(.5 - (qxx / hwx + qyy / hwy) * .5, 0, 1)
        lip = .3 + .6 * lamp
        grain = np.where(hash21(np.floor(qxx - shx) + seed, np.floor(qyy - shy) + seed) > .82, -.55, -1.0)
        wd = np.clip(-sm / 4.0, 0, 1)
        wall = .25 + (-.85 - .25) * wd
        d = np.where(sm >= 0, lip, np.where(sf < 0, grain, wall))
        mhx, mhy = hwx - 2, hwy - 2
        fhx, fhy = hwx - 3, hwy - 3
        Ao = 4 * hwx * hwy - (4 - 3.14159) * 16
        Am = 4 * mhx * mhy - (4 - 3.14159) * 4
        ow = max(0, min(shx + fhx, mhx) - max(shx - fhx, -mhx))
        oh = max(0, min(shy + fhy, mhy) - max(shy - fhy, -mhy))
        Af = max(0, ow * oh - (4 - 3.14159))
        Aw = max(0, Am - Af)
        d = d - ((Ao - Am) * .6 + Aw * -.1 + Af * -.92) / Ao
        return np.where(so < 0, d, np.nan)   # the sprite masks the corners: they are not cells
    if kind == 4:
        s = (hash21(np.floor(px + t * 2), np.floor(py)) > .965) | (hash21(np.floor(px * .5 + t * .7) + 7, np.floor(py * .5) + 7) > .975)
        return np.where(s, 1.0, -.064)
    if kind == 5:
        m = gmod(np.floor(py - t * 4), 4)
        return np.where(m < .5, .8, np.where((m > 1.5) & (m < 2.5), -.8, 0.0))
    if kind == 6:
        s = np.floor((px + py - t * 20) / 4)
        return np.where(gmod(s, 2) < .5, .5, -.5)
    if kind == 7:
        a = gmod(px + py - t * 6, 8); b = gmod(px - py + t * 6, 8)
        return np.where((a < 1) | (b < 1), 1.0, -.31)
    if kind == 8:
        r = np.sqrt(qxx ** 2 + (qyy * (hwx / hwy)) ** 2)
        ph = fract(r / 6 - t * .6 + seed)
        return np.where(ph < .25, 1.0, np.where(ph < .5, -1.0, 0.0))
    if kind == 9:
        n = vnoise(px * .2 + t * .4 + seed, py * .2 + t * 1.3 + seed) * .6 \
            + vnoise(px * .45 - t * .5 + seed * 3, py * .45 + t * 1.9 + seed * 3) * .4
        return tones((n - .5) * 2, .18)
    if kind == 10:
        a = t * 2.2 + seed
        rrx, rry = hwx - 3, hwy - 3
        m1x, m1y = math.cos(a) * rrx, math.sin(a) * rry
        d1 = (np.abs(qxx - m1x) < 1) & (np.abs(qyy - m1y) < 1)
        d2 = (np.abs(qxx + m1x) < 1) & (np.abs(qyy + m1y) < 1)
        return np.where(d1, 1.0, np.where(d2, -1.0, 0.0))
    if kind == 11:
        return np.full((h, w), float(tones(np.array(math.sin(t * 2 + seed)), .45)) * .6)
    if kind == 12:
        hh = hash21(cx + np.floor(t * 12) * 13.7 + seed, cy + np.floor(t * 12) * 13.7 + seed)
        return np.where(hh > .86, 1.0, np.where(hh < .14, -1.0, 0.0))
    if kind == 13:
        n = vnoise(px * .08 + t * .30 + seed, py * .02 + t * .15 + seed) * .7 \
            + vnoise(px * .17 - t * .22 + seed * 3, py * .04 + seed * 3) * .3
        return tones((n - .5) * 2, .2)
    if kind == 14:
        gx = np.floor((px - t * 3) / 2); gy = np.floor((py - t * 3) / 2)
        return np.where(gmod(gx + gy, 2) < .5, .45, -.45)
    if kind == 15:
        ang = np.arctan2(qyy * (hwx / hwy), qxx)
        r = np.sqrt(qxx ** 2 + (qyy * (hwx / hwy)) ** 2)
        return tones(np.sin(ang * 3 + r * .7 - t * 3), .5)
    if kind == 16:
        colh = hash21(np.floor(px), np.full_like(px, 3.0))
        ph = fract(py / 28 + t * (1.2 + colh * .8) + colh * 7)
        return np.where(ph < .12, 1.0, np.where(ph < .24, -1.0, 0.0))
    if kind == 17:
        ry = gmod(np.floor(py - t * 3), 6); cxx = gmod(np.floor(px + t * 2), 8)
        a = np.where(ry < .5, 1.0, np.where((ry > 2.5) & (ry < 3.5), -1.0, 0.0))
        b = np.where(cxx < .5, 1.0, np.where((cxx > 3.5) & (cxx < 4.5), -1.0, 0.0))
        return np.clip(a + b, -1, 1) * .7
    if kind == 18:
        n = vnoise(px * .07 + t * .05 + seed, py * .07 - t * .03 + seed)
        return tones(np.sin(px * .35 + py * .2 + n * 9 + t * .4), .55)
    if kind == 19:
        return tones(np.sin(px * .7 + np.sin(py * .45 + t * 2.5) * 2 + t * 1.5), .4)
    return np.zeros((h, w))


NAMES = {1: "sheen", 2: "liquid", 3: "hole", 4: "stars", 5: "bands", 6: "stripes", 7: "lattice",
         8: "ripple", 9: "ember", 10: "orbit", 11: "pulse", 12: "static", 13: "aurora",
         14: "checker", 15: "spiral", 16: "rain", 17: "plaid", 18: "marble", 19: "shimmer"}
print(__doc__.strip().splitlines()[0])
print("=" * 74)
print("amp %.2f (a mean d of .03 is a %.1f%% luma drift)" % (AMP, AMP * .03 * 100))

# the board: positions across a 480x270 room, the tile 30x13 (DE's slab);
# a minute of time, sampled every quarter second
ROOM = (480, 270)
VIEW = (ROOM[0] * .5, ROOM[1] * .5)
PAR = PAR_PX / (ROOM[0] * .5)
positions = [(x, y) for x in range(8, 440, 36) for y in range(30, 250, 20)]
times = np.arange(0, 60, .25)
W, H = 30, 13

print()
print("1. MEAN OF d (must be ~0) AND THE CREST (must stay under 1.2)")
for kind in sorted(NAMES):
    means, mx = [], 0
    for (qx, qy) in positions[::3]:
        for t in times[::2]:
            d = pattern(kind, qx, qy, W, H, t, VIEW, PAR, seed=(qx * 7 + qy) % 13)
            means.append(float(np.nanmean(d)))
            mx = max(mx, float(np.nanmax(np.abs(d))))
    m = float(np.mean(means)); sd = float(np.std(means))
    say(abs(m) < .03, "%-8s mean d %+.4f (per-frame sd %.3f)" % (NAMES[kind], m, sd),
        "luma drift %+.2f%%, crest %.2f x amp" % (m * AMP * 100, mx))
    say(mx <= 1.2, "%-8s crest under 1.2" % NAMES[kind]) if mx > 1.2 else None

print()
print("2. THE HOLE AT THE ROOM'S EDGES (parallax clips the floor - the mean may drift)")
for (qx, qy) in [(8, 30), (440, 30), (8, 250), (440, 250), (225, 128)]:
    d = pattern(3, qx, qy, W, H, 0, VIEW, PAR, 3)
    shx = -((qx + 15) - VIEW[0]) * PAR - 1.5
    print("      at (%3d,%3d)  floor shift %+.1f px  mean d %+.3f" % (qx, qy, shx, np.nanmean(d)))
d_edge = pattern(3, 440, 250, W, H, 0, VIEW, PAR, 3)
say(abs(np.nanmean(d_edge)) < .1, "the hole's mean at the far corner stays under .1 (a %.1f%% drift, corner only)" % (.1 * AMP * 100), "%+.3f" % np.nanmean(d_edge))

print()
print("3. THE LADDER (tile_mat_config): one surface a tier, the top six cycling past the end")
cfg = open(os.path.join(ROOT, "scripts", "tile_mat_config", "tile_mat_config.gml"), encoding="utf-8").read()
rows = re.findall(r'tier : (\d+),\s*key : "(\w+)",\s*kind : (\d+)', cfg)
lad = [(int(a), b, int(c)) for a, b, c in rows]
print("      " + "  ".join("%d:%s" % (tr, nm) for tr, nm, _k in lad))
n = len(lad)
cyc = [lad[n - 6 + ((tr - n - 1) % 6)][1] for tr in range(n + 1, n + 9)]
print("      then " + "  ".join("%d:%s" % (n + 1 + i, nm) for i, nm in enumerate(cyc)))
say(lad[0][1] == "flat" and lad[0][2] == 0, "tier 1 is flat")
say(all(lad[i][0] == i + 1 for i in range(n)), "the ladder's tiers run 1..%d without a gap" % n)
say(len(set(k for _t, _n, k in lad[1:])) == n - 1, "no two tiers share a surface")
say(set(k for _t, _n, k in lad[1:]) == set(NAMES), "every material in the shader is on the ladder, and nothing else")

print()
print("=" * 74)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
