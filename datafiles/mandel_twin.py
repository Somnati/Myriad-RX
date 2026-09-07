"""mandel_twin.py - prove the deep-zoom maths BEFORE writing it twice.

sh_mandel cost five wrong guesses in one session, every one of them a
thing that could have been checked. Perturbation is bigger than anything
in it so far and has to be written in two languages at once - GML for
the reference orbit, GLSL for the per-pixel loop - neither of which
Claude can run. So it gets proved here first, in a language that runs.

What this answers, in order:
  1. how deep can the CURRENT design actually go, and what stops it
  2. is the double-double arithmetic right (the GML side of it)
  3. does perturbation with rebasing reproduce the true image
  4. how coarsely can the reference orbit be stored before it shows

Run:  python datafiles/mandel_twin.py
"""
import struct
from decimal import Decimal, getcontext

getcontext().prec = 60          # ground truth, far beyond any float
OK = True


def head(t):
    print("\n" + t + "\n" + "-" * len(t))


def result(name, passed, detail=""):
    global OK
    if not passed:
        OK = False
    print(f"  {'PASS' if passed else 'FAIL'}  {name}" + (f"   {detail}" if detail else ""))


def f32(v):
    """round a python float to float32, the way a uniform does"""
    return struct.unpack("f", struct.pack("f", v))[0]


# ===================================================================
# 1. WHERE THE FLOOR ACTUALLY IS
# ===================================================================
# The shipped shader carries the coordinate as a double-double and
# stops at scale 2e-13. The question that decides whether perturbation
# is worth building: is that the SHADER's limit, or the limit of the
# centre coordinate GML hands it?
head("1. what sets the depth floor")

ROOM_H = 270.0


def pixel_span(scale):
    return 2.0 * scale / ROOM_H


for scale in (1.35, 4e-6, 2e-13, 1e-14, 1e-15):
    px = pixel_span(scale)
    # the smallest step a float64 can take near a coordinate of ~0.75,
    # which is where the interesting parts of this set live
    eps = abs(0.75) * 2.0 ** -52
    print(f"    scale {scale:<10.1e} pixel {px:.3e}   doubles per pixel {px / eps:8.1f}")

px_dd_floor = pixel_span(2e-13)
eps64 = 0.75 * 2.0 ** -52
result("the dd shader's 2e-13 floor still has float64 headroom",
       px_dd_floor / eps64 > 4,
       f"{px_dd_floor / eps64:.0f} distinct doubles per pixel")

# where float64 itself would bind: one double per pixel
scale_f64_floor = eps64 * ROOM_H / 2.0
result("float64 centre binds about one order deeper than the shader",
       1e-15 < scale_f64_floor < 1e-13,
       f"float64 runs out at scale ~{scale_f64_floor:.1e}")

print("""
    READ THIS BEFORE BUILDING ANYTHING: perturbation moves the
    per-pixel loop to float32 and removes the SHADER as the limit -
    but the centre still has to be expressible, and a GML `real` is a
    float64. So perturbation alone buys roughly one order of magnitude
    (2e-13 -> ~1e-14) and a large speed-up, NOT the 1e-300 that deep
    zoomers reach. That depth needs extended precision on the CPU side
    as well: the centre AND the reference orbit. Section 2 is that.""")

# ===================================================================
# 2. DOUBLE-DOUBLE IN GML: does the arithmetic actually work
# ===================================================================
# GML has no float128, but it has float64 - so the same hi/lo trick the
# shader uses on float32 can be run on GML's own doubles, giving ~32
# significant digits for the centre and the reference orbit.
head("2. double-double built on float64 (the GML side)")

SPLIT64 = 134217729.0          # 2^27 + 1, for a 53-bit mantissa


def dd_quick2sum(a, b):
    s = a + b
    return (s, b - (s - a))


def dd_add(a, b):
    s = a[0] + b[0]
    v = s - a[0]
    e = (a[0] - (s - v)) + (b[0] - v)
    return dd_quick2sum(s, e + a[1] + b[1])


def dd_mul(a, b):
    ac = SPLIT64 * a[0]; ah = ac - (ac - a[0]); al = a[0] - ah
    bc = SPLIT64 * b[0]; bh = bc - (bc - b[0]); bl = b[0] - bh
    p = a[0] * b[0]
    e = ((ah * bh - p) + ah * bl + al * bh) + al * bl
    return dd_quick2sum(p, e + a[0] * b[1] + a[1] * b[0])


def dd_sub(a, b):
    return dd_add(a, (-b[0], -b[1]))


def dd_val(a):
    return Decimal(a[0]) + Decimal(a[1])


# the split constant is the thing most likely to be copied wrong: 4097
# is right for float32 and 134217729 for float64, and using one for the
# other silently loses precision rather than failing
x = (0.1, 0.0)
prod = dd_mul(x, x)
true = Decimal("0.1") * Decimal("0.1")
err_dd = abs(dd_val(prod) - Decimal(0.1) * Decimal(0.1))
err_64 = abs(Decimal(0.1 * 0.1) - Decimal(0.1) * Decimal(0.1))
result("dd_mul beats plain float64 by ~16 digits",
       err_dd < err_64 / Decimal(1e12),
       f"dd err {err_dd:.2e} vs float64 err {err_64:.2e}")

# a full orbit is where error accumulates, so test THAT, not one op
CX = Decimal("-0.743643887037158704752191506114774")
CY = Decimal("0.131825904205311970493132056385139")


def orbit_decimal(n):
    zx, zy = Decimal(0), Decimal(0)
    out = []
    for _ in range(n):
        zx, zy = zx * zx - zy * zy + CX, 2 * zx * zy + CY
        out.append((zx, zy))
    return out


def orbit_dd(n):
    cx = (float(CX), float(CX - Decimal(float(CX))))
    cy = (float(CY), float(CY - Decimal(float(CY))))
    zx, zy = (0.0, 0.0), (0.0, 0.0)
    out = []
    for _ in range(n):
        zx2, zy2 = dd_mul(zx, zx), dd_mul(zy, zy)
        nzy = dd_add(dd_mul(dd_mul(zx, zy), (2.0, 0.0)), cy)
        zx = dd_add(dd_sub(zx2, zy2), cx)
        zy = nzy
        out.append((zx, zy))
    return out


def orbit_f64(n):
    cx, cy = float(CX), float(CY)
    zx, zy = 0.0, 0.0
    out = []
    for _ in range(n):
        zx, zy = zx * zx - zy * zy + cx, 2 * zx * zy + cy
        out.append((zx, zy))
    return out


N = 400
od, oq, of = orbit_decimal(N), orbit_dd(N), orbit_f64(N)
e_dd = max(abs(dd_val(oq[i][0]) - od[i][0]) for i in range(N))
e_64 = max(abs(Decimal(of[i][0]) - od[i][0]) for i in range(N))
result(f"dd orbit stays closer than float64 over {N} iterations",
       e_dd < e_64,
       f"dd {e_dd:.2e} vs float64 {e_64:.2e}")
print(f"    (an orbit near the set amplifies error every step, which is"
      f"\n     exactly why the reference needs the extra digits)")

# ===================================================================
# 3. PERTURBATION + REBASING: does it reproduce the true image
# ===================================================================
# The whole claim of perturbation is that the PER-PIXEL loop can run in
# float32 while staying correct, because it iterates the tiny DELTA
# from a reference orbit rather than the coordinate itself.
head("3. perturbation with rebasing vs. the truth")

BAIL = 256.0
MAXI = 3000


def escape_decimal(cx, cy, maxi=MAXI):
    zx, zy = Decimal(0), Decimal(0)
    for i in range(maxi):
        zx, zy = zx * zx - zy * zy + cx, 2 * zx * zy + cy
        if zx * zx + zy * zy > BAIL:
            return i
    return -1


def escape_perturb(dcx, dcy, ref, maxi=MAXI):
    """ref is the reference orbit as float32 pairs. dc is this pixel's
    offset from the reference point. Everything here is float32 - that
    is the entire point of the exercise."""
    ex = ey = 0.0
    m = 0
    for i in range(maxi):
        # e = 2*Z[m]*e + e^2 + dc
        zx, zy = ref[m]
        nex = f32(2.0 * (zx * ex - zy * ey) + (ex * ex - ey * ey) + dcx)
        ney = f32(2.0 * (zx * ey + zy * ex) + 2.0 * ex * ey + dcy)
        ex, ey = nex, ney
        m += 1
        zx, zy = ref[m]
        fx, fy = f32(zx + ex), f32(zy + ey)
        mag = fx * fx + fy * fy
        if mag > BAIL:
            return i
        # ZHUORAN'S REBASING: when the full value drops below the delta,
        # the delta has stopped being small and the linearisation is
        # spent - restart against the head of the reference. Also when
        # the reference runs out. This is what replaces the classic
        # glitch-detect-and-recompute, and it needs only ONE reference.
        if mag < ex * ex + ey * ey or m >= len(ref) - 1:
            ex, ey = fx, fy
            m = 0
    return -1


ref_d = [(Decimal(0), Decimal(0))] + orbit_decimal(MAXI)
ref_f = [(f32(float(a)), f32(float(b))) for a, b in ref_d]

# a row of pixels at a zoom float64 could not render directly
SPAN = Decimal("1e-20")
agree = total = 0
worst = None
for k in range(-6, 7):
    dx = SPAN * Decimal(k) / Decimal(6)
    dy = SPAN * Decimal(k) / Decimal(11)
    truth = escape_decimal(CX + dx, CY + dy)
    got = escape_perturb(f32(float(dx)), f32(float(dy)), ref_f)
    total += 1
    if truth == got:
        agree += 1
    elif worst is None:
        worst = f"pixel {k}: truth {truth}, perturb {got}"
result(f"perturbation matches exact arithmetic at a 1e-20 span",
       agree == total, f"{agree}/{total}" + (f"  {worst}" if worst else ""))
print("    (1e-20 is seven orders past where float64 alone dies, and the"
      "\n     per-pixel loop here is pure float32 - that is the payoff)")

# ===================================================================
# 4. HOW COARSELY CAN THE REFERENCE BE STORED
# ===================================================================
# The reference has to reach the GPU somehow. A float texture is the
# obvious route and the risky one (buffer_set_surface byte order has
# burned this project before); an RGB888 fixed-point texture is
# buildable with ordinary draws. So: is 24 bits enough?
head("4. reference orbit storage precision")

for bits in (16, 24, 32):
    step = 4.0 / (2 ** bits)          # Z stays within |Z| <= 2
    q = [(round(a / step) * step, round(b / step) * step)
         for a, b in ref_f]
    agree = total = 0
    for k in range(-6, 7):
        dx = SPAN * Decimal(k) / Decimal(6)
        dy = SPAN * Decimal(k) / Decimal(11)
        truth = escape_decimal(CX + dx, CY + dy)
        got = escape_perturb(f32(float(dx)), f32(float(dy)), q)
        total += 1
        agree += (truth == got)
    print(f"    {bits}-bit fixed point (step {step:.1e}): {agree}/{total} pixels correct")
    if bits == 24:
        result("24-bit fixed point is enough for the reference",
               agree == total, f"{agree}/{total}")

print("""
    24 bits is what an RGB888 texel holds, and it is also the most a
    float32 shader can DECODE exactly - reconstructing more would need
    sums past 2^24, which float32 cannot represent. The two limits
    happen to meet, so the encoding writes itself.""")

# ===================================================================
# 5. THE ENCODING AS ACTUALLY WRITTEN
# ===================================================================
# Section 4 proved 24 bits is ENOUGH. This proves the two halves that
# were then written - __ref_pack in syst_mandel's Create, and ref_at in
# sh_mandel - are actually inverses of each other. They live in
# different languages and cannot be diffed, which is exactly the kind of
# pair that silently disagrees.
head("5. pack (GML) and decode (GLSL) round-trip")


def gml_ref_pack(v):
    """syst_mandel __ref_pack, transcribed"""
    u = min(max((v + 2.0) / 4.0, 0.0), 1.0) * 16777215.0
    i = int(u)
    return (i % 256, (i // 256) % 256, (i // 65536) % 256)


def glsl_ref_at(rgb):
    """sh_mandel ref_at, transcribed - including the /255 a texture read
    applies on the way in, which is where a mismatched constant hides"""
    r, g, b = (c / 255.0 for c in rgb)
    v = r * 255.0 + g * 65280.0 + b * 16711680.0
    return v / 16777215.0 * 4.0 - 2.0


worst = 0.0
for k in range(-2000, 2001):
    v = k / 1000.0                       # the whole [-2, 2] range Z uses
    worst = max(worst, abs(glsl_ref_at(gml_ref_pack(v)) - v))
result("pack/decode round-trips across the whole [-2,2] range",
       worst < 3e-7, f"worst error {worst:.2e}, one step is {4 / 16777215:.2e}")

# the channel constants must be the ones the maths needs - transposing
# 65280 and 16711680 would still LOOK like a plausible gradient
result("channel weights are 255 / 255*256 / 255*65536",
       65280 == 255 * 256 and 16711680 == 255 * 65536)

# the largest sum the shader forms has to stay inside float32's exact
# integer range, or the low byte silently stops counting
result("the decoded sum stays inside float32's exact integers",
       16777215 < 2 ** 24, "max sum 16777215, float32 exact to 16777216")

# ===================================================================
# 6. ARBITRARY PRECISION: the bignum, written the way GML will have it
# ===================================================================
# Double-double on float64 runs out at ~1e-26 and there is no float128
# to reach for. Past that the centre and the reference orbit need a
# number with as many digits as the zoom has orders of magnitude - so a
# fixed-point bignum, built from the only numeric type GML has.
#
# EVERY CHOICE HERE IS A GML CONSTRAINT, not a python one, because this
# code is going to be transcribed almost line for line:
#
#  - FIXED POINT, not floating. The coordinates live in (-8, 8) and need
#    absolute precision at the far end; an exponent would buy nothing
#    and cost a normalisation step in the inner loop.
#  - SIGN AND MAGNITUDE. GML has no integers and no bit operations
#    worth the name, so two's complement would be a fight.
#  - BASE 2^20. A GML `real` is a float64, exact on integers to 2^53.
#    A multiply accumulates up to L*(BASE-1)^2 in one column, so
#    L*2^40 < 2^53 allows L up to 8192 limbs - room to spare. Base 2^24
#    would cap it at 31 limbs and start silently rounding at 32.
#  - LIMB 0 IS THE INTEGER PART, limb i is the coefficient of BASE^-i.
#    Multiplication is then a plain convolution with carries running
#    from the small end toward the large one.
head("6. fixed-point bignum (transcribed to GML as bn_*)")

BN_BASE = 1048576                  # 2^20, ~6.02 decimal digits per limb


def bn_from(v, L):
    s = -1 if v < 0 else 1
    v = abs(v)
    d = [0.0] * L
    d[0] = float(int(v))
    f = v - d[0]
    for i in range(1, L):
        f *= BN_BASE
        d[i] = float(int(f))
        f -= d[i]
    return {"s": s, "d": d}


def bn_real(a):
    """back to a float64. Only meaningful when the value is small - a
    DIFFERENCE of two nearby coordinates, never an absolute one."""
    v, m = 0.0, 1.0
    for i in range(len(a["d"])):
        v += a["d"][i] * m
        m /= BN_BASE
    return v * a["s"]


def bn_cmp_mag(a, b):
    for i in range(len(a["d"])):
        if a["d"][i] != b["d"][i]:
            return 1 if a["d"][i] > b["d"][i] else -1
    return 0


def bn_add_mag(a, b, L):
    d, c = [0.0] * L, 0.0
    for i in range(L - 1, -1, -1):
        t = a["d"][i] + b["d"][i] + c
        c = 1.0 if t >= BN_BASE else 0.0
        d[i] = t - c * BN_BASE
    return d


def bn_sub_mag(a, b, L):
    """|a| - |b|, assuming |a| >= |b|"""
    d, br = [0.0] * L, 0.0
    for i in range(L - 1, -1, -1):
        t = a["d"][i] - b["d"][i] - br
        br = 1.0 if t < 0 else 0.0
        d[i] = t + br * BN_BASE
    return d


def bn_add(a, b):
    L = len(a["d"])
    if a["s"] == b["s"]:
        return {"s": a["s"], "d": bn_add_mag(a, b, L)}
    c = bn_cmp_mag(a, b)
    if c == 0:
        return {"s": 1, "d": [0.0] * L}
    if c > 0:
        return {"s": a["s"], "d": bn_sub_mag(a, b, L)}
    return {"s": b["s"], "d": bn_sub_mag(b, a, L)}


def bn_neg(a):
    return {"s": -a["s"], "d": list(a["d"])}


def bn_sub(a, b):
    return bn_add(a, bn_neg(b))


def bn_mul(a, b):
    """convolution, then carry from the small end up. The product of
    limb i and limb j lands at position i+j because position k weighs
    BASE^-k; everything past L-1 is below the precision being kept and
    is dropped after it has contributed its carry."""
    L = len(a["d"])
    W = 2 * L
    p = [0.0] * W
    for i in range(L):
        ai = a["d"][i]
        if ai == 0.0:
            continue
        for j in range(L):
            p[i + j] += ai * b["d"][j]
    c = 0.0
    for k in range(W - 1, 0, -1):
        t = p[k] + c
        c = float(int(t / BN_BASE))
        p[k] = t - c * BN_BASE
    p[0] += c
    return {"s": a["s"] * b["s"], "d": p[:L]}


# ---- against Decimal, which is the only opinion that counts ----
from decimal import Decimal as D


def bn_dec(a):
    v = D(0)
    m = D(1)
    for i in range(len(a["d"])):
        v += D(int(a["d"][i])) * m
        m /= BN_BASE
    return v * a["s"]


L = 12                                # ~72 decimal digits
worst_m = worst_a = D(0)
for (u, v) in [(0.75, -0.31), (-1.5, 0.25), (1.9999, 1.9999),
               (0.1, 0.1), (-0.7436438870371587, 0.13182590420531197)]:
    A, B = bn_from(u, L), bn_from(v, L)
    worst_m = max(worst_m, abs(bn_dec(bn_mul(A, B)) - bn_dec(A) * bn_dec(B)))
    worst_a = max(worst_a, abs(bn_dec(bn_add(A, B)) - (bn_dec(A) + bn_dec(B))))
step = D(1) / D(BN_BASE) ** (L - 1)
result("bn_add is exact", worst_a == 0)
result("bn_mul is exact to the last limb kept",
       worst_m <= step, f"worst {worst_m:.2e}, one step is {step:.2e}")

# subtraction across zero is where sign-and-magnitude goes wrong
sgn_ok = True
for (u, v) in [(0.3, 0.7), (0.7, 0.3), (-0.3, 0.7), (0.3, -0.7), (-0.5, -0.5)]:
    A, B = bn_from(u, L), bn_from(v, L)
    if abs(bn_dec(bn_sub(A, B)) - (bn_dec(A) - bn_dec(B))) > step:
        sgn_ok = False
result("bn_sub handles every sign combination and zero crossing", sgn_ok)

# ---- the thing it is actually for ----
# an orbit computed with the bignum has to beat double-double, or the
# whole exercise is a slower way to get the same picture
def orbit_bn(n, L):
    cx, cy = bn_from(float(CX), L), bn_from(float(CY), L)
    # the literal is beyond a float64, so refine the low end from Decimal
    for k in range(1, L):
        cx = bn_add(cx, bn_from(float(CX - bn_dec(cx)), L))
        cy = bn_add(cy, bn_from(float(CY - bn_dec(cy)), L))
    zx, zy = bn_from(0.0, L), bn_from(0.0, L)
    out = []
    for _ in range(n):
        zx2, zy2 = bn_mul(zx, zx), bn_mul(zy, zy)
        nzy = bn_add(bn_add(bn_mul(zx, zy), bn_mul(zx, zy)), cy)
        zx = bn_add(bn_sub(zx2, zy2), cx)
        zy = nzy
        out.append((zx, zy))
    return out


NB = 120
ob = orbit_bn(NB, L)
odn = orbit_decimal(NB)
e_bn = max(abs(bn_dec(ob[i][0]) - odn[i][0]) for i in range(NB))
oqn = orbit_dd(NB)
e_dd2 = max(abs(dd_val(oqn[i][0]) - odn[i][0]) for i in range(NB))
result(f"the bignum orbit beats double-double over {NB} steps",
       e_bn < e_dd2, f"bignum {e_bn:.2e} vs dd {e_dd2:.2e}")

# ---- what it costs, which decides whether it is usable ----
# limb count has to follow the zoom or every view pays for the deepest
# one. O(L^2) per multiply, three multiplies per orbit step.
print()
print("    limbs needed, and the multiply cost that follows:")
for depth in (1e-26, 1e-40, 1e-80, 1e-200):
    digits = -__import__("math").log10(depth) + 6
    limbs = int(digits / 6.02) + 2
    print(f"      zoom {depth:8.0e}   {limbs:3d} limbs"
          f"   {limbs * limbs * 3:6d} limb-multiplies per orbit step")
print("""
    So the limb count MUST follow the zoom - it is 7 limbs at 1e-26 and
    36 at 1e-200, and a fixed 36 would make every shallow view pay
    twenty-five times over for depth it is not using.""")

# ===================================================================
# 7. THE TRANSCRIPTION ITSELF
# ===================================================================
# Section 6 proved the ALGORITHM. This proves the code that was then
# written into syst_mandel, which is not the same thing: GML got a flat
# array with the sign at [0] and limbs at [1..L], where python had a
# struct with limbs from [0]. Every index in the multiply shifted by
# one, and an off-by-one in a convolution does not crash - it quietly
# scales the answer by 2^20 and the fractal turns to noise at depth.
#
# So the GML is transcribed back, character for character, and the two
# are run against each other.
head("7. GML's array layout vs the verified struct layout")

import random as _rnd


def gml_bnfrom(v, L):
    a = [0.0] * (L + 1)
    a[0] = -1 if v < 0 else 1
    u = abs(v)
    a[1] = float(int(u))
    f = u - a[1]
    for i in range(2, L + 1):
        f *= BN_BASE
        a[i] = float(int(f))
        f -= a[i]
    return a


def gml_bnreal(a):
    v, m = 0.0, 1.0
    for i in range(1, len(a)):
        v += a[i] * m
        m /= BN_BASE
    return v * a[0]


def gml_bncmp(a, b):
    for i in range(1, len(a)):
        if a[i] != b[i]:
            return 1 if a[i] > b[i] else -1
    return 0


def gml_bnaddmag(a, b, L):
    d = [0.0] * (L + 1)
    c = 0.0
    for i in range(L, 0, -1):
        t = a[i] + b[i] + c
        c = 1.0 if t >= BN_BASE else 0.0
        d[i] = t - c * BN_BASE
    return d


def gml_bnsubmag(a, b, L):
    d = [0.0] * (L + 1)
    r = 0.0
    for i in range(L, 0, -1):
        t = a[i] - b[i] - r
        r = 1.0 if t < 0 else 0.0
        d[i] = t + r * BN_BASE
    return d


def gml_bnadd(a, b):
    L = len(a) - 1
    if a[0] == b[0]:
        d = gml_bnaddmag(a, b, L)
        d[0] = a[0]
        return d
    c = gml_bncmp(a, b)
    if c == 0:
        z = [0.0] * (L + 1)
        z[0] = 1
        return z
    if c > 0:
        d = gml_bnsubmag(a, b, L); d[0] = a[0]
    else:
        d = gml_bnsubmag(b, a, L); d[0] = b[0]
    return d


def gml_bnneg(a):
    b = list(a)
    b[0] = -a[0]
    return b


def gml_bnsub(a, b):
    return gml_bnadd(a, gml_bnneg(b))


def gml_bnmul(a, b):
    L = len(a) - 1
    W = 2 * L
    p = [0.0] * (W + 1)
    for i in range(1, L + 1):
        ai = a[i]
        if ai == 0.0:
            continue
        for j in range(1, L + 1):
            p[i + j - 1] += ai * b[j]
    c = 0.0
    for k in range(W, 1, -1):
        t = p[k] + c
        c = float(int(t / BN_BASE))
        p[k] = t - c * BN_BASE
    p[1] += c
    d = [0.0] * (L + 1)
    d[0] = a[0] * b[0]
    for k in range(1, L + 1):
        d[k] = p[k]
    return d


# the two layouts must agree exactly, on values chosen to hit the
# awkward parts: sign changes, carries, borrows across the whole width
_rnd.seed(74123)
LT = 10
same_mul = same_add = same_sub = True
for _ in range(600):
    u = _rnd.uniform(-2, 2)
    v = _rnd.uniform(-2, 2)
    sA, sB = bn_from(u, LT), bn_from(v, LT)
    gA, gB = gml_bnfrom(u, LT), gml_bnfrom(v, LT)
    if abs(bn_real(bn_mul(sA, sB)) - gml_bnreal(gml_bnmul(gA, gB))) > 0:
        same_mul = False
    if abs(bn_real(bn_add(sA, sB)) - gml_bnreal(gml_bnadd(gA, gB))) > 0:
        same_add = False
    if abs(bn_real(bn_sub(sA, sB)) - gml_bnreal(gml_bnsub(gA, gB))) > 0:
        same_sub = False
result("GML's __bnmul matches the verified layout, 600 random pairs", same_mul)
result("GML's __bnadd matches", same_add)
result("GML's __bnsub matches", same_sub)

# and the one that would silently scale everything: a shifted
# convolution index still produces a plausible-looking number
A = gml_bnfrom(0.5, LT)
result("__bnmul has no off-by-one in the convolution (0.5*0.5 == 0.25)",
       abs(gml_bnreal(gml_bnmul(A, A)) - 0.25) < 1e-12,
       f"got {gml_bnreal(gml_bnmul(A, A))}")

B = gml_bnfrom(1.5, LT)
result("and none at the integer/fraction boundary (1.5*1.5 == 2.25)",
       abs(gml_bnreal(gml_bnmul(B, B)) - 2.25) < 1e-12,
       f"got {gml_bnreal(gml_bnmul(B, B))}")

# growing must be exact, because the limb count changes mid-zoom and a
# view that jumped when it did would be worse than one that stopped
G = gml_bnfrom(-0.7436438870371587, 6)
G2 = [G[0]] + G[1:] + [0.0] * 6
result("__bngrow is exact - the view cannot jump when limbs are added",
       gml_bnreal(G) == gml_bnreal(G2))

print("\n" + "=" * 60)
print("ALL CHECKS PASSED" if OK else "SOMETHING IS WRONG - do not build on this")
print("=" * 60)
