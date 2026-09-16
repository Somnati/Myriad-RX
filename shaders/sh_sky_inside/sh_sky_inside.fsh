//
// INSIDE A NEBULA (his ask, 2026-09-16: "say the nebulas have a certain
// thickness and any stars that have depth that sits inside its thickness
// will be inside the nebula and much of the sky takes on this look").
// the cloud is a slab of a cylinder: radius 1 (everything here is in
// radii), half-thickness u_t about its middle; the star sits at u_s inside
// it. every fragment is a view ray (sh_sky_fog's projection); the ray's
// PATH OUT of the cloud - to the cylinder's wall or the slab's face,
// whichever comes first - is the cloud's depth that way: long along the
// plane, short out the thin axis. mottled by 3d noise on the direction,
// that depth is an optical depth. two passes over the same rays:
//   u_mode 0 - TRANSMITTANCE, multiplied onto the sky (what lies beyond
//              the cloud dims: the band, the stars, the other clouds)
//   u_mode 1 - THE GLOW, added: the cloud's own two colours by the depth
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
uniform float u_ext;     // the extinction per radius of path
uniform float u_mode;    // 0 transmittance, 1 glow
uniform float u_time;    // the dither's slide (glow pass)
uniform float u_dither;  // 1 on an 8-bit page

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
    vec2 rp = v_vTexcoord * u_geom;
    if (u_cell > 0.5) rp = (floor(rp / u_cell) + 0.5) * u_cell;
    vec2 px = rp - u_ctr;
    vec3 d  = normalize(vec3(px, -230.0));
    vec3 w  = vec3(dot(u_cam[0], d), dot(u_cam[1], d), dot(u_cam[2], d));

    // the path out: the slab's face this way, and the cylinder's wall
    float ty = 1.0e6;
    if (abs(w.y) > 1.0e-4) ty = (((w.y > 0.0) ? u_t : -u_t) - u_s.y) / w.y;
    vec2 sxz = u_s.xz;
    vec2 wxz = w.xz;
    float a = dot(wxz, wxz);
    float b = 2.0 * dot(sxz, wxz);
    float c = dot(sxz, sxz) - 1.0;
    float tr = 1.0e6;
    if (a > 1.0e-5) {
        float disc = max(b * b - 4.0 * a * c, 0.0);
        tr = (-b + sqrt(disc)) / (2.0 * a);
    }
    float path = max(min(ty, tr), 0.0);

    // the cloud's own mottle on the direction: some ways are thicker than others
    float m = 0.5 + 1.0 * fbm(w * 2.6 + u_seed);
    float od = path * m * u_ext;
    float trans = exp(-od);

    if (u_mode < 0.5) {
        gl_FragColor = vec4(vec3(trans), 1.0);
        return;
    }
    float glow = 1.0 - trans;
    float hue = smoothstep(0.3, 0.7, fbm(w * 4.1 + u_seed * 1.3 + vec3(2.0, 5.0, 1.0)));
    vec3 rgb = mix(u_col, u_col2, hue) * glow * u_amp;
    // the dither (sh_sky_fog's law) on an 8-bit page: a wide smooth wash bands without it
    vec2 ip = (u_cell > 0.5) ? floor(v_vTexcoord * u_geom / u_cell) : floor(v_vTexcoord * u_geom);
    float sfr = floor(u_time * 60.0);
    ip += vec2(sfr * 13.0, sfr * 7.0);
    float g = hash12(ip);
    float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither;
    gl_FragColor = vec4(max(rgb, vec3(0.0)), 1.0) * v_vColour;
}
