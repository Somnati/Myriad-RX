"""vis_twin.py - the visualiser's OVERDRAW AGREEMENT invariant.

The house twin discipline, applied to a rendering law instead of an
economy one. It models RX's actual colour path (vis_tier_color ->
obj_bignum5's saturation-doubling callback -> BignumVisRenderer's field
colours) and the LOD layer stack, and asserts the one property the
renderer has to have and did not:

  THE INVARIANT. Every screen rectangle is painted by more than one
  field - that IS the telescoping design, 100 squares of one field being
  geometrically one square of the next. So every field that paints a
  rectangle must paint it THE SAME COLOUR. If two disagree, what you see
  is decided by their LOD alphas, and LOD alpha is a pure function of the
  camera: the same number renders in different colours at different zoom
  levels. That was the bug (his three screenshots at 102M: orange, gold,
  peach - one completed square, one value, three zooms).

Run:  python datafiles/vis_twin.py
"""

# ---- GM colour semantics ---------------------------------------------
def hsv_to_rgb(h, s, v):                       # make_colour_hsv, 0..255
    h = (h / 255.0) * 360.0; s = s / 255.0; v = v / 255.0
    c = v * s; hp = (h % 360) / 60.0
    x = c * (1 - abs(hp % 2 - 1)); m = v - c
    r, g, b = [(c,x,0),(x,c,0),(0,c,x),(0,x,c),(x,0,c),(c,0,x)][int(hp) % 6]
    return tuple(int(round((q + m) * 255)) for q in (r, g, b))

def get_hue(c):
    r, g, b = [q / 255.0 for q in c]
    mx, mn = max(r, g, b), min(r, g, b); d = mx - mn
    if d == 0: return 0
    if mx == r: h = ((g - b) / d) % 6
    elif mx == g: h = (b - r) / d + 2
    else:        h = (r - g) / d + 4
    return int(round(h * 60 / 360 * 255))

def get_sat(c):
    mx = max(c)
    return 0 if mx == 0 else int(round((mx - min(c)) / mx * 255))

def merge(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))

# vis_tier_color, term for term (2026-09-12: the table here had drifted
# from the script - uncommon/legendary/elite/divine were the old rarity
# macros, and there was no rung past 8; the script hands 9+ a golden-
# angle hue). The invariant is palette-agnostic, but the printed
# disagreements should name the colours the game paints.
_PAL = {2: (60,255,69), 3: (65,122,255), 4: (160,32,255), 5: (255,167,10),
        6: (253,14,53), 7: (248,131,121), 8: (185,242,255)}

def vis_tier_color(t):
    if t <= 1: return (255,255,255)
    if t in _PAL: return _PAL[t]
    h = ((t - 9) * 137.508 + 30) % 360
    odd = (t % 2) == 1
    return hsv_to_rgb(int(round(h / 360 * 255)), 235 if odd else 200, 255 if odd else 215)

def tier(oom):                     # obj_bignum5's callback, sat doubled
    c = vis_tier_color(max((oom // 2) + 1, 0))
    return hsv_to_rgb(get_hue(c), min(get_sat(c) * 2, 255), max(c))

# ---- the renderer's field colours ------------------------------------
def raw3(v, off):
    """The 3-digit square count of the field at `off`, exactly as
    draw_window reads it: floor(v / 10^(off+2)) mod 1000. Integer math,
    so no boundary rounds the wrong way (the first draft used floats and
    reported 9.95e5 as clamped at a field where it is not)."""
    return (v // 10 ** (off + 2)) % 1000 if off + 2 >= 0 else 0

def fill_colour(v, mag, off, law):
    """The colour that field paints its full squares.
       law 'ramp'  - the old three-count blend toward the tier above
       law 'above' - the first fix: the field immediately above
       law 'top'   - shipped: the top square, whatever the depth"""
    n = raw3(v, off)
    if n < 100:
        return tier(off + 2)              # a real field: its own squares
    if law == "ramp":
        t = min((n - 100) / 3.0, 1.0)
        return merge(tier(off + 2), tier(off + 4), t)
    if law == "above":
        return tier(off + 4)
    return tier(2 * (max(mag, 0) // 2))

# ---- the invariant ----------------------------------------------------
def check(law, label):
    """A clamped field spans unit_for(off) x 100 px, which is exactly the
    square size of the field above - so its whole block lands on that
    field's FIRST square and paints over it. Demand the two agree."""
    bad = total = 0
    first = []
    for exp in range(4, 40):
        for m3 in range(100, 1000):                 # mantissa 1.00..9.99
            v = m3 * 10 ** (exp - 2)                # exact integer value
            for off in range(0, 32, 2):
                if raw3(v, off) < 100:              # not clamped, not redundant
                    continue
                total += 1
                got  = fill_colour(v, exp, off,     law)
                want = fill_colour(v, exp, off + 2, law)
                if got != want:
                    bad += 1
                    if len(first) < 4:
                        first.append((m3 / 100.0, exp, off, got, want))
    print("  %-40s %6d stacked pairs, %6d disagree" % (label, total, bad))
    for mant, exp, off, g, w in first:
        print("        %.2fe%-2d  field %2d paints %-15s over %s"
              % (mant, exp, off, g, w))
    return bad

print(__doc__.strip().splitlines()[0])
print()
print("INVARIANT  a rectangle painted by two fields is painted ONE colour")
a = check("ramp",  "the ramp (what shipped, his 3 screenshots)")
b = check("above", "flat clamp to the field above")
c = check("top",   "flat clamp to the TOP SQUARE  <- shipped")
print()
print("HOLDS" if c == 0 else "FAILS")
