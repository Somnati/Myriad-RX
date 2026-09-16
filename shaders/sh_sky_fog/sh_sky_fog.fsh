//
// milky way fog, raycast per pixel like the planet: every fragment is
// a view ray, rotated into world space by the orbit camera, and the
// band is a continuous fbm density around the galactic plane - real
// haze with wisps and a dark dust lane, no splat blobs to splotch.
// warm toward the galactic core bearing, cool away, matching the map.
// temporal dither (same jimenez IGN as sh_fog_dither) keeps the 8-bit
// pipeline from banding the smooth gradients.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  u_cam[3];  // view -> world rotation rows (the orbit cam)
uniform vec3  u_core;    // direction to the galactic core, world space
uniform vec2  u_geom;    // room size, px
uniform vec2  u_ctr;     // projection center (matches the star draws)
uniform float u_seed;    // per-system noise domain offset
uniform float u_time;    // dither slide
uniform float u_dither;  // 1 = dither here (an 8-bit page), 0 = the page is float and dithers once at its blit (2026-09-15)
uniform float u_amp;     // overall brightness
uniform float u_cell;    // pixelation: screen px per ray cell (0 = off)
uniform float u_corein;  // 0 .. 1 how deep in the core's bulge this star sits: the band thickens to a glow all round (2026-09-16)
uniform float u_edge;    // 0 galactic center .. 1 rim: at the rim the
                         // band piles up toward the core bearing and
                         // thins away from it; at the center it wraps
// THE NEBULAE (2026-09-16, things of the galaxy - galaxy_nebulae): the brightest EIGHT in reach (four cut a disc
// star's sky to a third of them - his question), painted here PER
// PIXEL IN DIRECTION SPACE (a flat billboard swung round the camera when a big one was near - his report): each
// cloud has a bearing on the sky, a tangent frame about it, and the view ray's offsets in that frame over the
// sine of its apparent radius are the same -1..1 disc sh_nebula paints on the map - the same seed, the same
// bent body, now fixed to the sphere
uniform float u_nebn;      // how many of the eight are live
uniform vec3  u_nebd[8];   // their bearings (unit, world)
uniform vec4  u_nebp[8];   // sin(apparent radius), cos(apparent radius), brightness, seed
uniform vec3  u_nebc[8];   // colour
uniform vec3  u_nebc2[8];  // the second colour
uniform float u_nebk[8];   // the kind (neb_body)

// hash -> 3d value noise -> fbm. sampled on world DIRECTIONS, so the
// fog is seamless over the whole sphere: no 2d wrap, no poles
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

// white noise, no lattice (Hoskins' hash12): the grain that reads as film
// grain, not the diagonal checkerboard interleaved-gradient noise makes
// on pixel cells (his report, 2026-09-15)
float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// 2d value noise for the clouds' bodies (sh_nebula's, verbatim: the same seed must paint the same cloud)
float vn2(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm2(vec2 p)
{
    float s = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        s += a * vn2(p);
        p = p * 2.03 + vec2(17.3, 9.1);
        a *= 0.5;
    }
    return s;
}

// THE BODY OF A CLOUD BY ITS KIND (2026-09-16): uv -1..1 across its disc, the cloud's seed, its kind -> (density, mottle, filaments).
// 0 DIFFUSE: the soft disc, bent, mottled, shot with filaments. 1 SHELL (a remnant): a hollow ring, thin and bright at the
// rim, near nothing inside. 2 PILLARS: stretched along an axis the seed turns, torn into streaks. 3 VEIL: huge and faint,
// the wisps alone. the same function paints the map, the sky's far patches and the star's own cloud - one cloud everywhere.
vec3 neb_body(vec2 uv0, float seed, float kind)
{
    float ra = seed * 2.7;
    vec2 uv = vec2(uv0.x * cos(ra) - uv0.y * sin(ra), uv0.x * sin(ra) + uv0.y * cos(ra));
    vec2 p = uv * 1.8 + vec2(seed, seed * 1.7);
    vec2 q = vec2(fbm2(p), fbm2(p + vec2(3.1, 7.3)));
    vec2 wv = uv + (q - 0.5) * 1.1;
    float d = length(wv);
    float n = fbm2(p * 2.3 + q * 2.5 + vec2(1.7, 9.2));
    float f = 1.0 - abs(2.0 * fbm2(p * 3.7 + q * 1.5 + vec2(5.0, 2.0)) - 1.0);
    float body;
    if (kind < 0.5) {
        body = 1.0 - smoothstep(0.1, 1.0, d);
        body = body * body;
    } else if (kind < 1.5) {
        float ring = 1.0 - smoothstep(0.0, 0.2, abs(d - 0.7));
        float inner = (1.0 - smoothstep(0.0, 0.7, d)) * 0.15;
        body = (ring * (0.55 + 0.7 * f) + inner) * (1.0 - smoothstep(0.85, 1.0, d));
    } else if (kind < 2.5) {
        vec2 sv = vec2(wv.x * 2.3, wv.y * 0.7);
        float streak = 0.5 + 0.5 * fbm2(vec2(wv.x * 9.0, wv.y * 1.6) + seed);
        body = (1.0 - smoothstep(0.1, 1.0, length(sv))) * (0.35 + 0.9 * streak);
        body = body * body;
    } else {
        body = (1.0 - smoothstep(0.3, 1.0, d)) * f * f * 0.9;
    }
    return vec3(body, n, f);
}

void main()
{
    // the same projection the star draws use: sx = cx + vx * 230 / -vz,
    // so a pixel at offset (ox, oy) looks along (ox, oy, -230).
    // quantizing the RAY coordinate pixelates natively (planet-style):
    // every cell is one exact ray, never an average
    vec2 rp = v_vTexcoord * u_geom;
    if (u_cell > 0.5) rp = (floor(rp / u_cell) + 0.5) * u_cell;
    vec2 px = rp - u_ctr;
    vec3 d  = normalize(vec3(px, -230.0));
    vec3 w  = vec3(dot(u_cam[0], d), dot(u_cam[1], d), dot(u_cam[2], d));

    // gaussian falloff off the galactic plane; fbm SQUASHED vertically
    // so the structure streaks along the band instead of clumping
    float band = exp(-w.y * w.y * mix(42.0, 7.0, u_corein));   // (a fat band from inside the bulge)
    vec3 q = w * 3.4;
    q.y *= 2.6;
    float n    = fbm(q + u_seed);
    float lane = fbm(w * 6.3 + u_seed * 1.7 + vec3(7.31, 2.62, 5.44));

    float dens = band * (0.30 + 0.70 * smoothstep(0.30, 0.72, n));
    dens -= band * 0.50 * smoothstep(0.54, 0.76, lane); // dark dust lane
    dens = max(dens, 0.0);

    // THE CORE BULGE (2026-09-16): where the band meets the core's bearing it swells - taller
    // and brighter, the centre of the galaxy on the sky; stronger the further out this star sits
    vec2 wf0 = normalize(w.xz + vec2(1.0e-5, 0.0));   // (a ray straight up has no plane direction - NaN otherwise, and a NaN spreads; 2026-09-16)
    vec2 cf0 = normalize(u_core.xz);
    float toward = max(dot(wf0, cf0), 0.0);
    float bulge = pow(toward, 9.0) * exp(-w.y * w.y * 14.0);
    dens += bulge * (0.35 + 0.65 * smoothstep(0.25, 0.7, n)) * (0.5 + 0.8 * u_edge);
    // INSIDE THE BULGE (2026-09-16): no one bearing is the core any more - the glow is all round, thickest on the plane
    dens += u_corein * (0.9 + 1.1 * smoothstep(0.25, 0.7, n)) * exp(-w.y * w.y * mix(14.0, 1.5, u_corein));   // (doubled 2026-09-16: "not as bright as i expected")

    // warm at the core bearing, cool away - agrees with the star map
    vec2 wf = w.xz;
    vec2 cf = u_core.xz;
    float dc = acos(clamp(dot(normalize(wf + vec2(1.0e-5, 0.0)), normalize(cf + vec2(1.0e-5, 0.0))), -1.0, 1.0)) / 3.14159265;
    vec3 col = mix(vec3(1.0, 0.765, 0.549), vec3(0.470, 0.569, 0.922), dc);
    col = mix(col, vec3(1.0, 0.82, 0.62), u_corein);   // (warm every way from inside)

    // rim stars see the galaxy on one side of the sky: the band gains
    // toward the core bearing and starves away from it, scaled by how
    // far out this star actually sits on the map
    float bias = mix(1.0, 0.15 + 1.7 * pow(1.0 - dc, 1.8), u_edge);

    vec3 rgb = col * dens * u_amp * (0.55 + 0.75 * (1.0 - dc)) * bias;
    float darkT = 1.0;   // what the DARK clouds let through (2026-09-16): the band, and everything drawn before this pass, dims by it

    // THE NEBULAE on the sphere (see the uniforms): the ray's offsets in each cloud's tangent frame
    for (int ni = 0; ni < 8; ni++) {
        if (float(ni) >= u_nebn) break;
        vec3 nd = u_nebd[ni];
        vec4 np = u_nebp[ni];
        float cw = dot(w, nd);
        if (cw < np.y - 0.35) continue;   // (well outside the cone - the bend reaches past the radius, hence the margin)
        vec3 t1 = normalize(cross(nd, vec3(0.0, 1.0, 0.0)));   // (a cloud sits on the band, never straight up)
        vec3 t2 = cross(nd, t1);
        vec2 nuv = vec2(dot(w, t1), dot(w, t2)) / max(np.x, 0.02);
        if (dot(nuv, nuv) > 3.2) continue;
        vec3 nbd = neb_body(nuv, np.w, u_nebk[ni]);
        float nbody = nbd.x;
        if (nbody <= 0.0) continue;
        float nn = nbd.y;
        float nf = nbd.z;
        float na = nbody * (0.25 + 0.9 * nn) * (0.5 + 0.7 * nf * nf);
        vec3 ncol = mix(u_nebc[ni], u_nebc2[ni], smoothstep(0.25, 0.75, nn)) + vec3(0.25) * nf * nf * nbody;
        if (np.z < 0.0) darkT *= 1.0 - clamp(na * -np.z, 0.0, 1.0);   // (a dark cloud: brightness below zero is its extinction)
        else rgb += ncol * na * np.z;
    }

    // REMASTERED temporal dither, grain as chunky as the cells:
    // 30hz re-seed (half the shimmer) + LUMINANCE-GATED amplitude -
    // zero on the black sky, sub-LSB on the band's dim edges, capped
    // at ~1.4 levels in the body. single IGN tap (two averaged taps
    // interfere into visible blotches)
    vec2 ip = (u_cell > 0.5) ? floor(v_vTexcoord * u_geom / u_cell)
                             : floor(v_vTexcoord * u_geom);
    float sfr = floor(u_time * 60.0);
    ip += vec2(sfr * 13.0, sfr * 7.0);
    float g = hash12(ip);   // (white grain, not the lattice)
    float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither;

    // (one, src_alpha): dest = rgb + dest x darkT - the dark clouds take the sky behind them away
    gl_FragColor = vec4(max(rgb, vec3(0.0)) * darkT, darkT) * v_vColour;
}
