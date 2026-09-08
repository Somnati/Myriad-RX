//
// sh_mandel - the mandelbrot set.
//
// He has had one of these before and reported it as "buggy and laggy".
// Both are specific, solvable problems rather than the cost of the
// fractal, and each one is addressed here by name.
//
// ---- LAGGY ----
//
// 1. THE INTERIOR IS THE EXPENSIVE PART. A point inside the set never
//    escapes, so it runs the FULL iteration budget every frame - and
//    the interior is most of the screen at the default view. The main
//    cardioid and the period-2 bulb are the two biggest interior
//    regions and both have exact closed-form tests, so those pixels
//    cost four multiplies instead of hundreds. On its own this is
//    usually the difference between smooth and a slideshow.
// 2. PERIODICITY. Interior points outside those two regions settle
//    into a cycle. Keeping one old z and bailing when the orbit
//    returns to it catches most of the rest.
// 3. ADAPTIVE ITERATIONS. Detail only needs iterations as you zoom;
//    spending 800 at the default view buys nothing. u_iter comes from
//    the caller's zoom level.
// 4. A CONSTANT LOOP BOUND with an early break. Dynamic bounds are
//    fine in HLSL11 (windows) and NOT reliably fine in GLSL ES 1.0
//    (android) - a fractal that runs on desktop and fails to compile
//    on mobile is exactly the kind of "buggy" that surfaces late.
// 5. RESOLUTION. Drawn at ROOM size - 480x270 is ~130k pixels, a
//    fifteenth of a 1080p screen, and the room-to-window scale does
//    the rest for free. Rendering a fractal at native window
//    resolution is the most common reason one of these crawls.
//
// ---- BUGGY ----
//
// 6. BANDING. The naive colouring is by integer escape count, which
//    draws hard concentric rings that crawl as you zoom - the classic
//    "it looks broken". The fix is the SMOOTH (continuous) iteration
//    count, nu = n + 1 - log2(log|z|), which needs a generous escape
//    radius (256, not 2) to be accurate. With it the bands vanish and
//    zoom is continuous.
// 7. PRECISION. This is float32. Below roughly 1e-5 span, neighbouring
//    pixel coordinates stop being distinguishable and the image goes
//    blocky and melts. That is a hard limit of the type, not a bug to
//    fix - so the CALLER clamps the zoom there and says so, rather
//    than letting it dissolve and look broken. Deeper needs
//    double-double emulation or perturbation theory, a much larger
//    project.
// 8. 8-BIT OUTPUT. Everything downstream is 8-bit and a smooth
//    fractal gradient is exactly what re-bands on the way out. Same
//    temporal IGN dither the fog shader uses, for the same reason.
//
// ⚖️ THE SCREEN COORDINATE. Four attempts, and the history is worth
// keeping because the failures look identical and the causes do not:
//
//   1. v_vTexcoord off a stretched spr_pixel_1x1. A 1x1 sprite's UVs
//      are one texel of its atlas page, so the value is near-constant
//      across the screen. -> one flat colour.
//   2. computed in the VERTEX stage as in_Position/u_res. Vertex-stage
//      uniforms are not reliably populated by shader_set_uniform_f, so
//      u_res was zero, the divide made NaN, and every NaN comparison
//      is false. -> one flat colour.
//   3. gl_FragCoord / ROOM size. This one RENDERED - it was the
//      version he called "looks cool" - but the divisor was wrong:
//      gl_FragCoord is in RENDER TARGET pixels and application_surface
//      is sized to the WINDOW. So the picture was a stretched crop,
//      and the shader's pixel-to-complex mapping disagreed with the
//      one __at() uses in GML - which is why zoom-toward-cursor
//      pointed somewhere else no matter how correct its algebra was.
//   4. explicit texture coordinates on a hand-built primitive. Sound
//      in principle, and it went flat again: whatever GM does with an
//      immediate-mode primitive's texcoords under a custom shader, they
//      did not arrive. -> one flat colour, with the real fractal
//      flickering through during zooms.
//
// So: back to gl_FragCoord, which demonstrably renders, with the
// divisor it always should have had - the RENDER TARGET's size, handed
// in from GML. Both sides then normalise to the same 0..1 and the
// mouse maths finally agrees with the picture. The aspect ratio is
// passed separately, because it is a property of the ROOM (the shape
// the player sees) and not of whatever surface it landed on.
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_centre;   // complex-plane point at the middle of the quad
uniform float u_scale;    // half-height of the view, in complex units
uniform vec2  u_res;      // the quad's size in room pixels
uniform float u_iter;     // iteration budget, from the zoom
uniform float u_time;     // dither reseed
uniform vec4  u_pal;      // rgb = palette phase, a = overall hue shift
uniform float u_glow;     // 0..1 strength of the distance-estimate rim
// the same view again, as hi/lo pairs, used only when u_dd is on. Split
// on the GML side, where a `real` is already a 64-bit double.
uniform vec4  u_centre_dd; // (cx_hi, cx_lo, cy_hi, cy_lo)
uniform vec2  u_scale_dd;  // (hi, lo)
uniform float u_dd;        // >0.5 = take the double-double path
uniform float u_aspect;    // ROOM width/height - the shape, not the surface
uniform float u_dbg;       // >0.5 = draw the normalised coordinate instead
// ---- perturbation ----
uniform float     u_pert;    // >0.5 = iterate the delta, not the point
uniform vec2      u_dcoff;   // view centre MINUS the reference point
uniform float     u_reflen;  // usable steps in the reference orbit
uniform vec2      u_reftex;  // the reference texture's size, in texels
uniform sampler2D u_ref;     // the reference orbit, 24-bit fixed point

// ⚖️ TWO CEILINGS, because the shallow paths do not need the deep one.
// GLSL ES wants constant loop bounds; u_iter breaks out early, so these
// only set the worst case the compiler must PLAN for - and planning for
// 3000 in three separate loops would triple a shader that only one of
// them ever needs. f32 and f32x2 cover scales where the budget is a few
// hundred; perturbation is the only path that goes deep.
//
// THE DEEP END NEEDS THE ITERATIONS MORE THAN IT NEEDS THE DIGITS. At
// 1e-26 the budget formula asks for 2546 and 900 was a third of it; at
// 1e-130 it asks for 11780. A number precise enough to address a place
// you cannot resolve is not depth, it is arithmetic.
const int   MAX_I    = 12000;   // the perturbation loop
const int   MAX_SHAL = 400;     // f32 and f32x2
const float ESCAPE = 256.0;   // generous, so the smooth count is exact

// ============================================================
// DOUBLE-DOUBLE ARITHMETIC
// ============================================================
// Float32 has a 24-bit mantissa, which runs out at roughly 1e-6 of
// span - past that neighbouring pixels stop being distinguishable and
// the picture goes blocky. There is no f64 to reach for: GLSL ES 1.0
// has no double type, GM does not expose HLSL's, and consumer GPUs run
// f64 at a fraction rate anyway.
//
// So the number is carried as a PAIR of floats, hi + lo, where lo holds
// the part hi could not represent. That is ~48 bits of mantissa, about
// 1e-13 of span - roughly forty million times deeper than float32
// alone. The operations below are the error-free transformations
// (Dekker, Knuth) that keep the pair exact: each one computes the
// rounded result AND the error it just made, and carries the error.
//
// ⚖️ THE SPLIT CONSTANT IS 4097, and it is specific to float32. It is
// 2^ceil(p/2)+1 for a p-bit mantissa: float32 has p=24, so 2^12+1.
// The 134217729 seen in double-precision code is the same formula for
// p=53 and is WRONG here - it would silently lose the very precision
// this is all for.
const float DD_SPLIT = 4097.0;

// exact sum of two floats: returns (rounded sum, exact error)
vec2 dd_quick2sum(float a, float b) {
    float s = a + b;
    return vec2(s, b - (s - a));
}

vec2 dd_add(vec2 a, vec2 b) {
    float s = a.x + b.x;
    float v = s - a.x;
    float e = (a.x - (s - v)) + (b.x - v);
    return dd_quick2sum(s, e + a.y + b.y);
}

vec2 dd_neg(vec2 a) { return vec2(-a.x, -a.y); }
vec2 dd_sub(vec2 a, vec2 b) { return dd_add(a, dd_neg(b)); }

vec2 dd_mul(vec2 a, vec2 b) {
    // Dekker's two-product: split both operands into halves that
    // multiply exactly, so the rounding error of a.x*b.x is recovered
    float ac = DD_SPLIT * a.x;  float ah = ac - (ac - a.x);  float al = a.x - ah;
    float bc = DD_SPLIT * b.x;  float bh = bc - (bc - b.x);  float bl = b.x - bh;
    float p  = a.x * b.x;
    float e  = ((ah * bh - p) + ah * bl + al * bh) + al * bl;
    return dd_quick2sum(p, e + a.x * b.y + a.y * b.x);
}

// ============================================================
// THE REFERENCE ORBIT
// ============================================================
// Z(n) for the reference point, computed on the CPU at double-double
// precision and handed over as 24-BIT FIXED POINT in an RGB888 texture,
// two texels per step (x then y). Nothing exotic: a float texture would
// mean buffer_set_surface, whose byte order has burned this project
// before, and 24 bits is the most a float32 shader could DECODE anyway
// - reconstructing more needs sums past 2^24, which float32 cannot
// represent. The twin confirms 24 bits renders identically to full
// precision, so the two limits meeting costs nothing.
//
// |Z| never exceeds 2 for a reference that stays in the set, which is
// the only kind worth having, so the fixed-point range is [-2, 2].
float ref_at(float idx)
{
    float tx = mod(idx, u_reftex.x);
    float ty = floor(idx / u_reftex.x);
    vec4  t  = texture2D(u_ref, (vec2(tx, ty) + 0.5) / u_reftex);
    // each channel comes back as byte/255, so multiplying by 255 gives
    // the byte exactly; the largest sum is 16777215, just inside the
    // 2^24 that float32 can still count without skipping
    float v = t.r * 255.0 + t.g * 65280.0 + t.b * 16711680.0;
    return v / 16777215.0 * 4.0 - 2.0;
}

vec2 ref_z(float m)
{
    float i = m * 2.0;
    return vec2(ref_at(i), ref_at(i + 1.0));
}

// IQ's cosine palette: a + b*cos(2pi*(c*t + d)). Cheap, and continuous
// by construction, so it never bands the way a ramp texture does.
vec3 palette(float t)
{
    vec3 a = vec3(0.52, 0.50, 0.52);
    vec3 b = vec3(0.46, 0.46, 0.48);
    return a + b * cos(6.28318530718 * (t + u_pal.rgb));
}

void main()
{
    // ---- quad coordinate -> complex plane ----
    // Guarded defaults: a uniform that fails to arrive should leave a
    // picture that is merely WRONG - visible, reportable - rather than
    // a NaN-poisoned flat screen with nothing on it to diagnose.
    vec2 res = (u_res.y > 1.0) ? u_res : vec2(480.0, 270.0);
    vec2 sc  = (u_scale > 0.0) ? vec2(u_scale) : vec2(1.35);
    float it = (u_iter > 1.0) ? u_iter : 120.0;

    // u_res is the RENDER TARGET's size, so this is 0..1 across the
    // screen - the same 0..1 that mouse_x/room_width gives on the GML
    // side, which is the whole point.
    // ⚖️ `scr`, not `q` - the cardioid test below already owns a
    // `float q`, and declaring a vec2 of the same name in the same
    // scope is what stopped this compiling. The second error followed
    // from the first: with `q` still a vec2 at the cardioid line, its
    // `<=` has no vector form. One name, two errors, neither of them
    // where the change was.
    vec2 scr = gl_FragCoord.xy / res;

    vec2 uv = (scr - 0.5) * 2.0;
    uv.x *= (u_aspect > 0.01) ? u_aspect : (res.x / res.y);
    vec2 c = u_centre + uv * sc.x;

    // ---- exact interior tests (1): main cardioid, then period-2 bulb
    // ⚖️ SKIPPED WHEN PERTURBING, and that is not an optimisation
    // choice - it is correctness. The tests are exact in exact
    // arithmetic, but they run on `c`, which is assembled in float32
    // from a centre that only crosses the uniform to ~7 digits. At a
    // 1e-26 span that makes them the right answer for a point 1e-7
    // away - astronomically outside the view - and near the cardioid
    // edge that is a wrong answer painted across the whole screen.
    // Deep views therefore pay the full budget in the interior, which
    // is the correct price for not lying about it.
    bool inside = false;
    if (u_pert <= 0.5) {
        float xm = c.x - 0.25;
        float q  = xm * xm + c.y * c.y;
        inside = (q * (q + xm) <= 0.25 * c.y * c.y)
              || ((c.x + 1.0) * (c.x + 1.0) + c.y * c.y <= 0.0625);
    }

    float n   = 0.0;
    float mag = 0.0;
    vec2  z   = vec2(0.0);
    vec2  dz  = vec2(1.0, 0.0);   // derivative, for the distance estimate
    vec2  old = vec2(0.0);        // periodicity reference
    float per = 0.0;

    // ---- THE PERTURBATION PATH ----
    // For c = C + d, writing z(n) = Z(n) + e(n) turns the iteration
    // into  e(n+1) = 2*Z(n)*e(n) + e(n)^2 + d.  e and d are tiny at any
    // depth, so THIS loop is plain float32 no matter how far in the
    // view is - every digit of precision was spent once, on the CPU,
    // computing Z. That is the whole idea: the cost moves off the
    // per-pixel path entirely.
    if (u_pert > 0.5 && !inside) {
        vec2 dc = u_dcoff + uv * sc.x;
        vec2 e  = vec2(0.0);
        float m = 0.0;
        for (int i = 0; i < MAX_I; i++) {
            if (float(i) >= it) break;

            vec2 Z = ref_z(m);
            // e = 2*Z*e + e^2 + dc
            e = vec2(2.0 * (Z.x * e.x - Z.y * e.y) + (e.x * e.x - e.y * e.y) + dc.x,
                     2.0 * (Z.x * e.y + Z.y * e.x) + 2.0 * e.x * e.y       + dc.y);
            m += 1.0;

            vec2 zf = ref_z(m) + e;      // the actual point, reassembled
            // the derivative rides the FULL value, so the rim glow works
            // here exactly as it does on the shallow path
            dz = 2.0 * vec2(zf.x * dz.x - zf.y * dz.y,
                            zf.x * dz.y + zf.y * dz.x) + vec2(1.0, 0.0);

            mag = dot(zf, zf);
            if (mag > ESCAPE) { n = float(i); z = zf; break; }

            // ⚖️ ZHUORAN'S REBASING. When the reassembled value drops
            // BELOW the delta, the delta has stopped being small and
            // the linearisation is spent - the classic symptom is a
            // blotch of wrong colour, and the classic cure was to
            // detect it and compute a second reference. Rebasing is
            // better and shorter: restart against the head of the
            // reference, carrying the full value as the new delta. One
            // reference orbit covers the whole image, and running off
            // the end of it is handled by the same line.
            if (mag < dot(e, e) || m >= u_reflen - 1.0) {
                e = zf;
                m = 0.0;
            }
            n = float(i) + 1.0;
            z = zf;
        }
        if (mag <= ESCAPE) inside = true;
    }

    // ---- THE DEEP PATH ----
    // Double-double costs roughly eight times a float iteration, so it
    // is not paid until float32 has actually run out. The branch is on
    // a UNIFORM, so every pixel in the draw takes the same side of it
    // and there is no divergence cost - shallow views run exactly as
    // fast as they did before this existed.
    // `&& !inside` matters: the cardioid and bulb tests have already
    // answered for those pixels, and skipping that check here would run
    // the eight-times-more-expensive loop on precisely the region the
    // cheap exact test exists to eliminate.
    if (u_dd > 0.5 && !inside && u_pert <= 0.5) {
        vec2 cxd = dd_add(vec2(u_centre_dd.x, u_centre_dd.y),
                          dd_mul(u_scale_dd, vec2(uv.x, 0.0)));
        vec2 cyd = dd_add(vec2(u_centre_dd.z, u_centre_dd.w),
                          dd_mul(u_scale_dd, vec2(uv.y, 0.0)));
        vec2 zxd = vec2(0.0), zyd = vec2(0.0);
        // the derivative stays SINGLE precision on purpose: it only
        // feeds the rim glow, its magnitude is large, and carrying it
        // as a pair would cost as much again for no visible gain
        vec2 dzs = vec2(1.0, 0.0);

        for (int i = 0; i < MAX_SHAL; i++) {
            if (float(i) >= it) break;

            float zx = zxd.x, zy = zyd.x;
            dzs = 2.0 * vec2(zx * dzs.x - zy * dzs.y,
                             zx * dzs.y + zy * dzs.x) + vec2(1.0, 0.0);

            vec2 zx2 = dd_mul(zxd, zxd);
            vec2 zy2 = dd_mul(zyd, zyd);
            vec2 nzy = dd_add(dd_mul(dd_mul(zxd, zyd), vec2(2.0, 0.0)), cyd);
            zxd = dd_add(dd_sub(zx2, zy2), cxd);
            zyd = nzy;

            // the escape test only needs the hi halves: by the time
            // |z|^2 is near 256 the low words are far below the noise
            mag = zx2.x + zy2.x;
            if (mag > ESCAPE) { n = float(i); break; }
            n = float(i) + 1.0;
        }
        z  = vec2(zxd.x, zyd.x);
        dz = dzs;
        if (mag <= ESCAPE) inside = true;
    }
    else if (!inside && u_pert <= 0.5) {
        for (int i = 0; i < MAX_SHAL; i++) {
            if (float(i) >= it) break;

            // dz = 2*z*dz + 1, BEFORE z advances
            dz = 2.0 * vec2(z.x * dz.x - z.y * dz.y,
                            z.x * dz.y + z.y * dz.x) + vec2(1.0, 0.0);
            // z = z^2 + c
            z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

            mag = dot(z, z);
            if (mag > ESCAPE) { n = float(i); break; }

            // ---- periodicity (2): the orbit returned to where it was,
            // so it is trapped and will never escape. The reference
            // refreshes every 20 steps - a fixed one misses long
            // cycles, refreshing every step misses short ones.
            if (dot(z - old, z - old) < 1.0e-12) { inside = true; break; }
            per += 1.0;
            if (per > 20.0) { per = 0.0; old = z; }

            n = float(i) + 1.0;
        }
        if (mag <= ESCAPE) inside = true;
    }

    vec3 col;
    if (inside) {
        // the interior is NOT black. A black interior reads as a hole
        // with a fringe round it; a near-black carrying the palette's
        // own phase keeps it part of the same picture.
        col = palette(u_pal.a) * 0.06;
    } else {
        // ---- the smooth iteration count (6). log|z| = 0.5*log(mag),
        // and the outer log is base 2 - that pairing is what makes nu
        // continuous straight across the escape boundary.
        float nu = n + 1.0 - log2(0.5 * log(mag));
        float t  = nu / max(it, 1.0);

        // a curve on t: almost everything escapes fast, so without this
        // the outer shells eat the whole palette and the interesting
        // part near the boundary gets one colour
        t = pow(clamp(t, 0.0, 1.0), 0.42);
        col = palette(t * 2.6 + u_pal.a);

        // ---- the distance estimate. |z|*log|z| / |dz| is roughly how
        // far this pixel sits from the set, in COMPLEX units - divide
        // by the size of one pixel and the rim is the same thickness at
        // every zoom instead of thinning to nothing as you dive. Nearly
        // free, because dz was already being carried.
        if (u_glow > 0.0) {
            float lz = sqrt(mag);
            float d  = lz * log(lz) / max(length(dz), 1.0e-6);
            float px = 2.0 * sc.x / res.y;           // one pixel, in complex units
            float e  = exp(-d / max(px, 1.0e-20) * 0.30);
            col += vec3(e) * u_glow * 0.9;
        }
    }

    // ---- 8-bit dither (8), the fog shader's recipe: single-tap
    // jimenez IGN reseeded at 30hz, so the eye integrates the shimmer
    // flat rather than reading static grain.
    vec2 p = floor(gl_FragCoord.xy)
        + fract(floor(u_time * 30.0) * vec2(0.7548776, 0.5698402)) * 64.0;
    float dth = fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
    col += (dth - 0.5) * (1.0 / 255.0) * 1.6;

    // ---- THE DIAGNOSTIC VIEW ----
    // [v] paints the coordinate itself instead of the fractal - red
    // rising left to right, green rising down the screen. Every failure
    // of this coordinate has looked the same from outside (a flat
    // screen, or a picture subtly displaced), so this makes the cause
    // visible: flat means the coordinate is dead, a ramp that saturates
    // partway across means the divisor is too small, and green running
    // UPWARD means the render target counts y from the other end -
    // which the fractal can never reveal, because the set is symmetric
    // about the real axis and a vertical mirror is invisible.
    //
    // An override at the end rather than an early return in main.
    // (The early return was NOT what broke the compile - that was a
    // variable name collision, see `scr` above. This shape is kept
    // because one exit is tidier, not because the other was illegal.)
    // It computes the whole fractal and throws it away in this mode,
    // which costs nothing worth caring about: a diagnostic, not a
    // render path.
    if (u_dbg > 0.5) gl_FragColor = vec4(scr.x, scr.y, 0.25, 1.0);
    else             gl_FragColor = vec4(col, 1.0) * v_vColour;
}
