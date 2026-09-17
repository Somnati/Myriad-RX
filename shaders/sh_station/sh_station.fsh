//
// A SPACE STATION (2026-09-16; 2026-09-17, his call: "simple shapes like
// pyramids, cubes, spheres"): ONE plain solid - a cube, a sphere, a
// pyramid, an octahedron, a cylinder, a ring, a cone - raymarched per pixel
// on a quad, orthographic rays (the dice's recipe: quad coords from u_quad,
// one exact ray a cell). u_or maps VIEW space onto the station's OBJECT
// space (its lean, its spin and the camera), the light comes in view
// space. the hull is panelled by a hash on the hit point, the windows are
// a sparser hash - lit on the night side.
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;   // quad x, y, w, h in room px
uniform vec3  u_or[3];  // object-from-view rotation rows
uniform vec3  u_light;  // direction TO the light, view space
uniform vec3  u_col;    // the hull
uniform vec3  u_glow;   // the windows
uniform float u_pad;    // quad half-extent in station units (the station fits a unit sphere)
uniform float u_style;  // 0 cube, 1 sphere, 2 pyramid, 3 octahedron, 4 cylinder, 5 ring, 6 cone
uniform vec4  u_prm;    // the shape's seeded proportions (x, y = its stretch)
uniform float u_seed;

float sd_box(vec3 p, vec3 b)
{
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
float sd_torus(vec3 p, float R, float r)
{
    vec2 q = vec2(length(p.xz) - R, p.y);
    return length(q) - r;
}
float sd_cap(vec3 p, float h, float r)
{
    p.y -= clamp(p.y, -h, h);
    return length(p) - r;
}
float sd_oct(vec3 p, float s)
{
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}
vec3 rot_y(vec3 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec3(p.x * c - p.z * s, p.y, p.x * s + p.z * c);
}
float hash13(vec3 p)
{
    p = fract(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return fract((p.x + p.y) * p.z);
}

float sd_cyl(vec3 p, float h, float r)
{
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}
// a square pyramid, base 1 x 1 at y = 0, apex at y = h (iq's)
float sd_pyr(vec3 p, float h)
{
    float m2 = h * h + 0.25;
    p.xz = abs(p.xz);
    p.xz = (p.z > p.x) ? p.zx : p.xz;
    p.xz -= 0.5;
    vec3 q = vec3(p.z, h * p.y - 0.5 * p.x, h * p.x + 0.5 * p.y);
    float s = max(-q.x, 0.0);
    float t = clamp((q.y - 0.5 * p.z) / (m2 + 0.25), 0.0, 1.0);
    float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
    float b = m2 * (q.x + 0.5 * t) * (q.x + 0.5 * t) + (q.y - m2 * t) * (q.y - m2 * t);
    float d2 = min(q.y, -q.x * m2 - q.y * 0.5) > 0.0 ? 0.0 : min(a, b);
    return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
}
// a cone, tip at the origin, base at y = -h (iq's)
float sd_cone(vec3 p, vec2 c, float h)
{
    vec2 q = h * vec2(c.x / c.y, -1.0);
    vec2 w = vec2(length(p.xz), p.y);
    vec2 a = w - q * clamp(dot(w, q) / dot(q, q), 0.0, 1.0);
    vec2 b = w - q * vec2(clamp(w.x / q.x, 0.0, 1.0), 1.0);
    float k = sign(q.y);
    float d = min(dot(a, a), dot(b, b));
    float s = max(k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
    return sqrt(d) * sign(s);
}

float sd_station(vec3 p)
{
    // THE PLAIN SOLIDS (2026-09-17): one shape, its stretch off u_prm
    if (u_style < 0.5)      return sd_box(p, vec3(0.58 * u_prm.x, 0.58 * u_prm.y, 0.58 * u_prm.x));
    else if (u_style < 1.5) return length(p) - 0.78;
    else if (u_style < 2.5) return sd_pyr((p + vec3(0.0, 0.55, 0.0)) / 1.55, 0.75 * u_prm.y) * 1.55;
    else if (u_style < 3.5) return sd_oct(p, 0.9);
    else if (u_style < 4.5) return sd_cyl(p, 0.62 * u_prm.y, 0.5 * u_prm.x);
    else if (u_style < 5.5) return sd_torus(p, 0.6, 0.24 * u_prm.y);
    return sd_cone(p - vec3(0.0, 0.72, 0.0), vec2(0.45, 0.89), 1.45);
}

void main()
{
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    q = (floor(q * u_quad.zw) + 0.5) / u_quad.zw;   // one ray a room pixel
    vec2 s = (q * 2.0 - 1.0) * u_pad;
    float keep = max(texture2D(gm_BaseTexture, v_uv).a, 1.0);   // (the base texture stays sampler 0 - the dice's lesson)

    vec3 rov = vec3(s, 3.2);
    vec3 rdv = vec3(0.0, 0.0, -1.0);
    vec3 ro = vec3(dot(u_or[0], rov), dot(u_or[1], rov), dot(u_or[2], rov));
    vec3 rd = vec3(dot(u_or[0], rdv), dot(u_or[1], rdv), dot(u_or[2], rdv));

    float t = 1.6;
    float d = 1.0;
    for (int i = 0; i < 60; i++) {
        d = sd_station(ro + rd * t);
        if (d < 0.004 || t > 5.4) break;
        t += d * 0.9;
    }
    if (d >= 0.004) discard;
    vec3 p = ro + rd * t;
    vec2 e = vec2(0.006, 0.0);
    vec3 n = normalize(vec3(sd_station(p + e.xyy) - sd_station(p - e.xyy), sd_station(p + e.yxy) - sd_station(p - e.yxy), sd_station(p + e.yyx) - sd_station(p - e.yyx)));
    vec3 lo = normalize(vec3(dot(u_or[0], u_light), dot(u_or[1], u_light), dot(u_or[2], u_light)));
    float diff = max(dot(n, lo), 0.0);
    // the panels: a coarse hash on the hit point; the windows: a finer, sparse one, brightest where the sun is not
    float pan = hash13(floor(p * 7.0 + 3.0));
    float win = step(0.9, hash13(floor(p * 13.0 + 11.0))) * (1.0 - smoothstep(0.85, 1.0, abs(n.y)));
    vec3 vd = vec3(dot(u_or[0], vec3(0.0, 0.0, 1.0)), dot(u_or[1], vec3(0.0, 0.0, 1.0)), dot(u_or[2], vec3(0.0, 0.0, 1.0)));
    float rim = pow(1.0 - max(dot(n, vd), 0.0), 3.0) * 0.25;
    vec3 col = u_col * (0.16 + 0.84 * diff) * (0.82 + 0.36 * pan) + vec3(rim);
    col += u_glow * win * (0.35 + 0.65 * (1.0 - diff));
    // the terminator quantised a little: the pixel look, not a smooth sphere
    col = floor(col * 14.0 + 0.5) / 14.0;
    gl_FragColor = vec4(col, keep);
}
