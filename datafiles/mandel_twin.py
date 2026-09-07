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

print("\n" + "=" * 60)
print("ALL CHECKS PASSED" if OK else "SOMETHING IS WRONG - do not build on this")
print("=" * 60)
