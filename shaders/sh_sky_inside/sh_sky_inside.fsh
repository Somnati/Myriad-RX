//
// THE NEAR CLOUD, ON THE SPHERE (2026-09-16, take three - his verdict on
// the march: "a vertical foggy volumetric fog shadow thing"; what he liked
// was the first wash, and the far nebulae's look). so: the cloud's REACH
// along a view ray is the smooth path out of its bounds (the unit
// cylinder about its middle, the slab |y| < u_t) - long along the plane
// toward its heart, short out the thin axis, nothing past its wall - and
// everything painted on it lives in DIRECTION space: the mottle and the
// filaments are 3d noise on the ray itself, patches on the sky sphere
// like the far nebulae's bodies, never columns. the whole is scaled by
// the map body's density where the star sits (sampled once: a star in a
// torn skirt or a hole gets little). glow = the two colours by the
// mottle, whitened on the filaments; what lies beyond dims by the same
// reach. ONE pass: rgb = the glow, alpha = the transmittance, blended
// (one, src_alpha): dest = glow + dest x transmittance.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  u_cam[3];  // view -> world rotation rows (the orbit cam)
uniform vec2  u_geom;    // room size, px
uniform vec2  u_ctr;     // projection center (matches the star draws)
uniform float u_cell;    // pixelation: screen px per ray cell (0 = off)
uniform vec3  u_s;       // the star in the cloud's frame, radii (x east, y down the sky, z the map's south)
uniform float u_t;       // the slab's half-thickness, radii
uniform vec3  u_col;
uniform vec3  u_col2;
uniform float u_seed;
uniform float u_amp;     // the glow's strength
uniform float u_ext;     // the extinction per unit of gathered density
uniform float u_time;    // the dither's slide, the walk's jitter
uniform float u_dither;  // 1 on an 8-bit page
uniform float u_dmode;   // 0 grain (white, re-seeded at 30 hz), 1 ordered (a fixed interleaved gradient), 2 SMOOTH (no jitter, no grain of its own)
uniform vec3  u_sun;     // the system's star's bearing (world): it is near us, the cloud does not dim it
uniform float u_sunon;   // 1 when the sun is on this sky (the orbit view), 0 on the system page

float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

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

// 3d value noise (sh_sky_fog's): the cloud's structure along the height, so a ray climbing out of it sees
// something other than the star's own patch stretched into a curtain (his report, 2026-09-16)
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

float fbm3(vec3 p)
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


// the interleaved gradient (jimenez): an ordered pattern that reads as a smooth tone at a glance
float ign(vec2 p)
{
    return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

void main()
{
    vec2 rp = v_vTexcoord * u_geom;
    if (u_cell > 0.5) rp = (floor(rp / u_cell) + 0.5) * u_cell;
    vec2 px = rp - u_ctr;
    vec3 d  = normalize(vec3(px, -230.0));
    vec3 w  = vec3(dot(u_cam[0], d), dot(u_cam[1], d), dot(u_cam[2], d));

    // THE REACH: the ray against the cloud's bounds (the unit cylinder about the axis, the slab across it)
    vec2 sxz = u_s.xz;
    vec2 wxz = w.xz;
    float a = dot(wxz, wxz);
    float b = 2.0 * dot(sxz, wxz);
    float c = dot(sxz, sxz) - 1.0;
    float t0 = -1.0e6;
    float t1 =  1.0e6;
    bool hit = true;
    if (a > 1.0e-5) {
        float disc = b * b - 4.0 * a * c;
        if (disc < 0.0) hit = false;
        else { float sq = sqrt(disc); t0 = (-b - sq) / (2.0 * a); t1 = (-b + sq) / (2.0 * a); }
    } else if (c > 0.0) hit = false;
    float ty0 = -1.0e6;
    float ty1 =  1.0e6;
    if (abs(w.y) > 1.0e-4) {
        float ta = (-u_t - u_s.y) / w.y;
        float tb = ( u_t - u_s.y) / w.y;
        ty0 = min(ta, tb); ty1 = max(ta, tb);
    } else if (abs(u_s.y) > u_t) hit = false;
    float tin  = max(max(t0, ty0), 0.0);
    float tout = min(t1, ty1);
    if (!hit || tout <= tin) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    float reach = tout - tin;

    // WHERE THE STAR SITS: the map body's density there (sh_nebula's function, the same seed), once
    vec2 uv0 = vec2(u_s.x, -u_s.z);
    vec2 pp0 = uv0 * 1.8 + vec2(u_seed, u_seed * 1.7);
    vec2 q0 = vec2(fbm2(pp0), fbm2(pp0 + vec2(3.1, 7.3)));
    float body0 = 1.0 - smoothstep(0.1, 1.0, length(uv0 + (q0 - 0.5) * 1.1));
    float n0 = fbm2(pp0 * 2.3 + q0 * 2.5 + vec2(1.7, 9.2));
    float here = clamp(body0 * body0 * (0.25 + 0.9 * n0) * 1.4, 0.12, 1.0);

    // THE BODY ON THE SPHERE: mottle and filaments as 3d noise on the direction - patches, never columns
    float mot = fbm3(w * 2.8 + u_seed);
    float fil = 1.0 - abs(2.0 * fbm3(w * 5.5 + u_seed * 1.3 + vec3(2.0, 5.0, 1.0)) - 1.0);
    float dens = here * reach * (0.35 + 1.0 * mot) * (0.6 + 0.6 * fil * fil);
    float trans = exp(-dens * u_ext);
    // the sun's patch clears: it sits near us, the cloud lies beyond it, not in front
    float sunw = u_sunon * smoothstep(0.970, 0.9986, dot(w, u_sun));
    trans = mix(trans, 1.0, sunw);
    float glow = 1.0 - trans;
    vec3 col = mix(u_col, u_col2, smoothstep(0.3, 0.7, mot)) + vec3(0.25) * fil * fil;
    vec3 rgb = col * glow * u_amp;
    // the shader's own dither only when asked (u_dmode 0 / 1; 2 = smooth, the page's blit dithers)
    if (u_dmode < 1.5) {
        vec2 ip = (u_cell > 0.5) ? floor(v_vTexcoord * u_geom / u_cell) : floor(v_vTexcoord * u_geom);
        float sfr = floor(u_time * 60.0);
        float g = (u_dmode > 0.5) ? ign(ip) : hash12(ip + vec2(sfr * 13.0, sfr * 7.0));
        float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
        rgb += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither;
    }
    gl_FragColor = vec4(max(rgb, vec3(0.0)), trans);
}
