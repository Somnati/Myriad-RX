//
// A STAR (2026-09-16, his verdict on the glow-sprite suns: "bunz"). one star
// on the white quad (nebula_quad, texcoords 0..1), additive. the DISC is a
// sphere: granulation (3d value noise on the sphere's surface, turning
// slowly - the star's spin), a few dark cells where a coarser noise peaks
// (spots), limb darkening (the edge cooler and dimmer, the star's own
// colour there; the middle white-hot). outside the limb the CORONA: rays
// streaked by noise on the angle (seamless round: the angle as cos / sin)
// fading with the radius, a wide faint halo, and PROMINENCES - loops of
// the hot colour just off the limb where an angular noise peaks. the
// whole star breathes on smoothed hash noise (never a sine). the seed is
// the star's: the same star on the system page and in its worlds' skies.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  u_col;     // the star's colour (its class)
uniform float u_seed;
uniform float u_time;    // seconds
uniform float u_rad;     // the disc's radius as a fraction of the quad's half-width
uniform float u_fade;    // 0..1 (the sun behind a world)
uniform float u_dither;  // 1 on an 8-bit page
uniform vec3  u_cam[3];  // view -> world rotation rows: the sphere's face and the corona's rays are the WORLD's (a billboard turned with the screen - his report 2026-09-16)

float h3(vec3 p)
{
    p = fract(p * 0.3183099 + vec3(0.10, 0.17, 0.13));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float vn3(vec3 p)
{
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n000 = h3(i);
    float n100 = h3(i + vec3(1.0, 0.0, 0.0));
    float n010 = h3(i + vec3(0.0, 1.0, 0.0));
    float n110 = h3(i + vec3(1.0, 1.0, 0.0));
    float n001 = h3(i + vec3(0.0, 0.0, 1.0));
    float n101 = h3(i + vec3(1.0, 0.0, 1.0));
    float n011 = h3(i + vec3(0.0, 1.0, 1.0));
    float n111 = h3(i + vec3(1.0, 1.0, 1.0));
    return mix(mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
               mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y), f.z);
}

float fbm(vec3 p)
{
    float a = 0.5;
    float s = 0.0;
    for (int i = 0; i < 4; i++) {
        s += a * vn3(p);
        p *= 2.13;
        a *= 0.5;
    }
    return s;
}

float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main()
{
    vec2 uv = v_vTexcoord * 2.0 - 1.0;
    float r = length(uv);
    float R = u_rad;
    float tt = u_time * 0.05 + u_seed * 3.1;
    vec3 hot = mix(u_col, vec3(1.0), 0.6);
    vec3 rgb = vec3(0.0);

    // THE DISC: a turning sphere. edge = its COVERAGE (to the limb itself, a pixel of feather) - the colour's factor and
    // the fragment's ALPHA: star_draw blends (one, inv_src_alpha), so inside the disc the star REPLACES the page (a world
    // behind a giant showed through its additive disc - "assets drawn in front of it when they are behind it", his
    // report 2026-09-17) while the corona, alpha 0, adds as before
    float edge = 1.0 - smoothstep(R * 0.985, R * 1.005, r);
    if (r < R * 1.005) {
        vec2 dd = uv / R;
        float z = sqrt(max(1.0 - dot(dd, dd), 0.0));
        // the point on the sphere in WORLD space (the camera's rows), then the star's own spin about the world's axis
        vec3 vp = vec3(dd.x, dd.y, z);
        vec3 wp = vec3(dot(u_cam[0], vp), dot(u_cam[1], vp), dot(u_cam[2], vp));
        float sa = tt * 0.35;
        vec3 sp = vec3(wp.x * cos(sa) - wp.z * sin(sa), wp.y, wp.x * sin(sa) + wp.z * cos(sa));
        float gran  = fbm(sp * 7.0 + vec3(0.0, 0.0, tt * 0.6) + u_seed);
        float cells = fbm(sp * 2.2 + vec3(5.0, 1.0, tt * 0.15) + u_seed * 0.7);
        float spot  = smoothstep(0.64, 0.72, cells);
        float limb  = 0.55 + 0.45 * z;   // (the limb no darker than the corona just outside it: the old .42 drew a dark ring round a giant - his report 2026-09-17)
        float bright = limb * (0.8 + 0.4 * gran) * (1.0 - 0.75 * spot);
        rgb += mix(u_col, hot, 0.25 + 0.75 * z) * bright * 1.25 * edge;
    }

    // THE CORONA and THE PROMINENCES, outside the limb
    // the limb's direction in WORLD space (the rays and loops turn with the world, not the screen)
    float ang = atan(uv.y, uv.x);
    vec3 lv = vec3(cos(ang), sin(ang), 0.0);
    vec3 lw = vec3(dot(u_cam[0], lv), dot(u_cam[1], lv), dot(u_cam[2], lv));
    vec2 ca = lw.xz + lw.y * 0.37;   // (a 2d key that is seamless round the limb: every limb point its own)
    float rr = max(r - R, 0.0) / R;
    float streak  = fbm(vec3(ca * 3.0, tt * 0.5) + u_seed);
    float streak2 = fbm(vec3(ca * 9.0, rr * 2.5 + tt * 0.8) + u_seed * 1.3);
    float cor  = exp(-rr * 2.4) * (0.3 + 0.7 * streak) * (0.55 + 0.7 * streak2);
    float halo = exp(-rr * 0.9) * 0.16;
    float promn = fbm(vec3(ca * 6.0, tt * 0.9 + 9.0) + u_seed * 0.5);
    float prom = smoothstep(0.0, 0.03, rr) * (1.0 - smoothstep(0.06, 0.26, rr)) * smoothstep(0.52, 0.78, promn);
    float outside = (1.0 - edge) * (1.0 - smoothstep(0.62, 0.98, r));   // (the disc's complement exactly - no dip and no seam at the limb; to nothing by the quad's edge - it showed as a square; his report)
    rgb += (u_col * (cor * 0.85 + halo) + hot * prom * 1.1) * outside;

    // the breath: the whole star's light on smoothed hash noise (a sine would be a metronome)
    float bt = u_time * 1.1 + u_seed;
    float bi = floor(bt);
    float bf = fract(bt);
    bf = bf * bf * (3.0 - 2.0 * bf);
    float breath = 1.0 + 0.05 * (mix(hash12(vec2(bi, 5.0)), hash12(vec2(bi + 1.0, 5.0)), bf) - 0.5);
    rgb *= breath * u_fade;

    // the dither on an 8-bit page (the corona's wide gradients)
    float fr = floor(u_time * 60.0);
    vec2 ip = floor(gl_FragCoord.xy) + vec2(fr * 13.0, fr * 7.0);
    float g = hash12(ip);
    float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither * (1.0 - smoothstep(0.62, 0.98, r));
    // alpha = the disc's coverage (times the fade), ZERO outside it: star_draw's blend is (one, inv_src_alpha) with the
    // page's alpha untouched (sepalpha zero / one) - the disc covers, the corona adds, and the square never lands in the
    // page's alpha (q188's faint box; his report 2026-09-17)
    gl_FragColor = vec4(max(rgb, vec3(0.0)) * v_vColour.rgb * v_vColour.a, edge * u_fade * v_vColour.a);
}
