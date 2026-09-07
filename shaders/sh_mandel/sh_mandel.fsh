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
// ⚖️ THE QUAD COORDINATE IS HANDED IN, on the vertex stream. Three
// ways to get it were tried and all three were wrong, each for its own
// reason - worth listing, because the failures look identical on screen
// and the causes are not:
//
//   1. v_vTexcoord from a stretched spr_pixel_1x1. A 1x1 sprite's UVs
//      are a single texel of its atlas page, so the value is very
//      nearly constant across the whole screen. -> one flat colour.
//   2. a coordinate computed in the VERTEX stage as in_Position/u_res.
//      A uniform read in the vertex stage is not reliably populated by
//      shader_set_uniform_f, so u_res was zero, the divide made NaN,
//      and every NaN comparison is false - every pixel took the same
//      branch. -> one flat colour, again.
//   3. gl_FragCoord / room_size. gl_FragCoord is in RENDER TARGET
//      pixels, and application_surface is sized to the WINDOW, not to
//      the room. So the divisor was wrong by the window/room ratio:
//      the picture was a stretched crop (which still looks like a
//      mandelbrot, so it passed a glance) and - the real damage - the
//      shader's pixel-to-complex mapping no longer agreed with the
//      one __at() uses in GML. Zoom-toward-cursor computes the anchor
//      in GML and the shader draws somewhere else, so it zooms at the
//      wrong point no matter how correct the anchor maths is.
//
// The cure for all three is to stop DERIVING the coordinate from
// something that happens to be lying around. The draw call supplies it
// on the vertex stream as explicit texture coordinates 0..1 (see
// syst_mandel's Draw), which cannot disagree with anything: not with
// the atlas, not with the surface size, not with the render target's
// y-orientation, and therefore not with __at().
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

// the hard ceiling. GLSL ES wants a constant bound; u_iter breaks out
// early, so this only sets the worst case the compiler must plan for.
const int   MAX_I  = 512;
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

    // v_vTexcoord is EXACTLY 0..1 across the quad - the draw call put
    // it there. u_res is now used only for the aspect ratio, never as
    // a divisor for a screen position, so the window size cannot get
    // into this maths at all.
    vec2 uv = (v_vTexcoord - 0.5) * 2.0;
    uv.x *= res.x / res.y;
    vec2 c = u_centre + uv * sc.x;

    // ---- exact interior tests (1): main cardioid, then period-2 bulb
    float xm = c.x - 0.25;
    float q  = xm * xm + c.y * c.y;
    bool inside = (q * (q + xm) <= 0.25 * c.y * c.y)
               || ((c.x + 1.0) * (c.x + 1.0) + c.y * c.y <= 0.0625);

    float n   = 0.0;
    float mag = 0.0;
    vec2  z   = vec2(0.0);
    vec2  dz  = vec2(1.0, 0.0);   // derivative, for the distance estimate
    vec2  old = vec2(0.0);        // periodicity reference
    float per = 0.0;

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
    if (u_dd > 0.5 && !inside) {
        vec2 cxd = dd_add(vec2(u_centre_dd.x, u_centre_dd.y),
                          dd_mul(u_scale_dd, vec2(uv.x, 0.0)));
        vec2 cyd = dd_add(vec2(u_centre_dd.z, u_centre_dd.w),
                          dd_mul(u_scale_dd, vec2(uv.y, 0.0)));
        vec2 zxd = vec2(0.0), zyd = vec2(0.0);
        // the derivative stays SINGLE precision on purpose: it only
        // feeds the rim glow, its magnitude is large, and carrying it
        // as a pair would cost as much again for no visible gain
        vec2 dzs = vec2(1.0, 0.0);

        for (int i = 0; i < MAX_I; i++) {
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
    else if (!inside) {
        for (int i = 0; i < MAX_I; i++) {
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

    gl_FragColor = vec4(col, 1.0) * v_vColour;
}
