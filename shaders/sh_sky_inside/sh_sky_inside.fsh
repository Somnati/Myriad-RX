//
// THE NEAR CLOUD, MARCHED (2026-09-16, his report: a star just outside a
// cloud's drawn body but inside its circle took the whole colour, and
// evenly). the cloud is the map's body (sh_nebula's function, the same
// seed: the bent disc, the mottle, the filaments) standing on the plane
// with a soft thickness; the star sits at u_s in that frame (radii). every
// fragment is a view ray (sh_sky_fog's projection): it is clipped to the
// cloud's bounds (the unit cylinder, the slab |y| < u_t), then walked in
// N steps, the body's density read at every step - so a ray toward the
// thick of the cloud gathers much, a ray through its torn skirt little,
// a ray past it nothing; a star in a hole of the body sees the body
// glow around it and its own sky stay clear. the walk yields the optical
// depth (extinction: what lies beyond dims by it) and the glow gathered
// front to back (the cloud's two colours, the filaments whitening). ONE
// pass: rgb = the glow, alpha = the transmittance, blended (one,
// src_alpha): dest = glow + dest x transmittance.
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

    // the ray against the cloud's bounds: the unit cylinder about the axis, the slab across it
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

    // THE WALK: the body read at every step (the map's function - the same cloud), front to back
    // (the steps' offset per pixel: the settings' pattern - white grain danced as noise, his report 2026-09-16; ordered holds still)
    float sfr = floor(u_time * 60.0);
    vec2 pix = floor(v_vTexcoord * u_geom);
    // (u_dmode 2 = SMOOTH, his call 2026-09-16: no jitter, no grain of its own - twenty even steps, the page's blit dithers)
    float jit = (u_dmode > 1.5) ? 0.5 : ((u_dmode > 0.5) ? ign(pix) : hash12(pix + vec2(sfr * 3.0, sfr * 11.0)));
    float st = (tout - tin) / 20.0;
    float od = 0.0;
    vec3 glow = vec3(0.0);
    for (int i = 0; i < 20; i++) {
        float t = tin + (float(i) + jit) * st;
        vec3 p = u_s + w * t;
        vec2 uv = vec2(p.x, -p.z);                          // (the map's frame: y down the map is the sky's -z)
        vec2 pp = uv * 1.8 + vec2(u_seed, u_seed * 1.7);
        vec2 q = vec2(fbm2(pp), fbm2(pp + vec2(3.1, 7.3)));
        vec2 wv = uv + (q - 0.5) * 1.1;
        float body = 1.0 - smoothstep(0.1, 1.0, length(wv));
        if (body <= 0.0) continue;
        float n = fbm2(pp * 2.3 + q * 2.5 + vec2(1.7, 9.2));
        float f = 1.0 - abs(2.0 * fbm2(pp * 3.7 + q * 1.5 + vec2(5.0, 2.0)) - 1.0);
        float dens = body * body * (0.25 + 0.9 * n) * (0.5 + 0.7 * f * f);
        dens *= exp(-(p.y * p.y) / (u_t * u_t) * 2.4);      // the slab's profile, brisk: the top of the sky clears
        dens *= 0.45 + 1.1 * fbm3(vec3(p.x * 2.6, p.y * 5.0, p.z * 2.6) + u_seed * 2.3);   // the third axis: structure with height
        vec3 col = mix(u_col, u_col2, smoothstep(0.25, 0.75, n)) + vec3(0.25) * f * f * body;
        float ds = dens * st;
        glow += col * ds * exp(-od * u_ext);
        od += ds;
    }
    float trans = exp(-od * u_ext);
    // the sun's patch clears: it sits near us, the cloud lies beyond it, not in front
    float sunw = u_sunon * smoothstep(0.970, 0.9986, dot(w, u_sun));
    trans = mix(trans, 1.0, sunw);
    vec3 rgb = glow * u_amp;
    // the dither (sh_sky_fog's law) on an 8-bit page: a wide smooth wash bands without it
    vec2 ip = (u_cell > 0.5) ? floor(v_vTexcoord * u_geom / u_cell) : floor(v_vTexcoord * u_geom);
    float g = (u_dmode > 0.5) ? ign(ip) : hash12(ip + vec2(sfr * 13.0, sfr * 7.0));
    float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither * ((u_dmode > 1.5) ? 0.0 : 1.0);
    gl_FragColor = vec4(max(rgb, vec3(0.0)), trans);
}
