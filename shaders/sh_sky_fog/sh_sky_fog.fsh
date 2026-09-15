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
uniform float u_edge;    // 0 galactic center .. 1 rim: at the rim the
                         // band piles up toward the core bearing and
                         // thins away from it; at the center it wraps

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
    float band = exp(-w.y * w.y * 42.0);
    vec3 q = w * 3.4;
    q.y *= 2.6;
    float n    = fbm(q + u_seed);
    float lane = fbm(w * 6.3 + u_seed * 1.7 + vec3(7.31, 2.62, 5.44));

    float dens = band * (0.30 + 0.70 * smoothstep(0.30, 0.72, n));
    dens -= band * 0.50 * smoothstep(0.54, 0.76, lane); // dark dust lane
    dens = max(dens, 0.0);

    // warm at the core bearing, cool away - agrees with the star map
    vec2 wf = w.xz;
    vec2 cf = u_core.xz;
    float dc = acos(clamp(dot(normalize(wf), normalize(cf)), -1.0, 1.0)) / 3.14159265;
    vec3 col = mix(vec3(1.0, 0.765, 0.549), vec3(0.470, 0.569, 0.922), dc);

    // rim stars see the galaxy on one side of the sky: the band gains
    // toward the core bearing and starves away from it, scaled by how
    // far out this star actually sits on the map
    float bias = mix(1.0, 0.15 + 1.7 * pow(1.0 - dc, 1.8), u_edge);

    vec3 rgb = col * dens * u_amp * (0.55 + 0.75 * (1.0 - dc)) * bias;

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

    gl_FragColor = vec4(max(rgb, vec3(0.0)), 1.0) * v_vColour;
}
