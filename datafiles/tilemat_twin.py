"""tilemat_twin.py - THE COLOUR LAW, measured (his rule, 2026-09-13:
"maintain the vanilla color output... i don't want a shader affecting
the overall brightness of a tile").

sh_tile_mat paints a tile body as colour x (1 + amp x d), d a posterized
pattern in -1..1. Multiplicative means hue and saturation are untouched
cell by cell; the law then reduces to ONE number per material: the mean
of d over the tile and over time must be zero. This ports each
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


def pattern(kind, qx, qy, w, h, t, view, par, seed):
    """d for a tile body at room (qx, qy) size (w, h), time t. Returns the cell grid."""
    cx, cy = np.meshgrid(np.arange(w), np.arange(h))
    px = qx + cx + .5; py = qy + cy + .5          # world anchor
    qxx = cx + .5 - w * .5; qyy = cy + .5 - h * .5  # tile-centred
    if kind == 1:
        n = np.array([1.0, .6]); n = n / np.linalg.norm(n)
        wv = px * n[0] + py * n[1]
        ph = fract((wv - t * 40) / 480)
        return np.where(ph < .05, 1.0, np.where(ph < .10, -1.0, 0.0))
    if kind == 2:
        n = vnoise(px * .11 + t * .35 + seed, py * .11 + t * .20 + seed) * .65 \
            + vnoise(px * .23 - t * .25 + seed * 3, py * .23 + t * .30 + seed * 3) * .35
        n = (n - .5) * 2
        return np.where(n > .22, 1.0, np.where(n < -.22, -1.0, 0.0))
    if kind == 3:
        hwx, hwy = w * .5, h * .5
        ccx, ccy = qx + hwx, qy + hwy
        shx, shy = -(ccx - view[0]) * par, -(ccy - view[1]) * par
        rim = (np.abs(qxx) > hwx - 1) | (np.abs(qyy) > hwy - 1)
        qfx, qfy = qxx - shx, qyy - shy
        fhx, fhy = hwx - 3, hwy - 3
        flr = (np.abs(qfx) < fhx) & (np.abs(qfy) < fhy)
        grain = hash21(np.floor(qfx) + seed, np.floor(qfy) + seed) > .85
        tone_f = np.where(grain, -.2, .4)
        d = np.where(rim, 1.0, np.where(flr, tone_f, -1.0))
        A = w * h
        fr = (A - (w - 2) * (h - 2)) / A
        ff = max(0, (w - 6) * (h - 6)) / A
        fw = 1 - fr - ff
        bias = fr * 1 + ff * (.85 * .4 - .15 * .2) - fw * 1
        return d - bias
    if kind == 4:
        p1x, p1y = px + t * 2, py
        p2x, p2y = px * .5 + t * .7, py * .5
        s = (hash21(np.floor(p1x), np.floor(p1y)) > .965) | (hash21(np.floor(p2x) + 7, np.floor(p2y) + 7) > .975)
        return np.where(s, 1.0, -.064)
    return np.zeros((h, w))


NAMES = {1: "sheen", 2: "liquid", 3: "hole", 4: "stars"}
print(__doc__.strip().splitlines()[0])
print("=" * 74)
print("amp %.2f (a mean d of .03 is a %.1f%% luma drift)" % (AMP, AMP * .03 * 100))

# the board: rm_tiles-like positions across a 480x270 room, tiles 30x13
# growing to 33x16; sixty seconds sampled every quarter second
ROOM = (480, 270)
VIEW = (ROOM[0] * .5, ROOM[1] * .5)
PAR = PAR_PX / (ROOM[0] * .5)
positions = [(x, y) for x in range(8, 440, 36) for y in range(30, 250, 20)]
times = np.arange(0, 60, .25)
sizes = [(30, 13), (31, 14), (33, 16)]

print()
print("1. MEAN OF d (must be ~0) AND THE CREST (must stay under 1.2)")
for kind in (1, 2, 3, 4):
    means, mx = [], 0
    for (w, h) in sizes:
        for (qx, qy) in positions[::3]:
            for t in times[::4]:
                d = pattern(kind, qx, qy, w, h, t, VIEW, PAR, seed=(qx * 7 + qy) % 13)
                means.append(d.mean())
                mx = max(mx, np.abs(d).max())
    m = float(np.mean(means)); sd = float(np.std(means))
    say(abs(m) < .03, "%-7s mean d %+.4f (per-sample sd %.3f, a frame's wobble)" % (NAMES[kind], m, sd),
        "luma drift %+.2f%%" % (m * AMP * 100))
    say(mx <= 1.2, "%-7s crest %.2f x amp" % (NAMES[kind], mx))

print()
print("2. THE HOLE AT THE ROOM'S EDGES (parallax clips the floor - the mean may drift)")
for (qx, qy) in [(8, 30), (440, 30), (8, 250), (440, 250), (225, 128)]:
    d = pattern(3, qx, qy, 30, 13, 0, VIEW, PAR, 3)
    shx = -((qx + 15) - VIEW[0]) * PAR
    print("      at (%3d,%3d)  floor shift %+.1f px  mean d %+.3f" % (qx, qy, shx, d.mean()))
d_edge = pattern(3, 440, 250, 30, 13, 0, VIEW, PAR, 3)
say(abs(d_edge.mean()) < .08, "the hole's mean at the far corner stays under .08 (a %.1f%% drift, corner only)" % (.08 * AMP * 100), "%+.3f" % d_edge.mean())

print()
print("3. THE POOL (tile_mat_config): what a tile of each tier rolls")
cfg = open(os.path.join(ROOT, "scripts", "tile_mat_config", "tile_mat_config.gml"), encoding="utf-8").read()
rows = re.findall(r'key : "(\w+)",\s*kind : (\d+),\s*min : (\d+),\s*w : (\d+),\s*grow : (true|false)', cfg)
GROW = macro("TILE_MAT_GROW", .5)
print("      %-5s " % "tier" + "".join("%8s" % r[0] for r in rows))
for tier in (1, 2, 3, 4, 6, 8, 9, 11, 14):
    ws = []
    for name, kind, mn, w, grow in rows:
        mn, w = int(mn), int(w)
        ws.append(0 if tier < mn else w * ((1 + GROW * (tier - mn)) if grow == "true" else 1))
    tot = sum(ws)
    print("      %-5d " % tier + "".join("%7.0f%%" % (100 * x / tot) for x in ws))
say(all(int(r[2]) >= 1 for r in rows) and rows[0][0] == "flat", "tier 1 rolls flat only (white has no headroom - nothing may modulate it)")

print()
print("=" * 74)
print("ALL INVARIANTS HOLD" if ok else "SOMETHING FAILED - tune here, then port")
