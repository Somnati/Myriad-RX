//
// A SPACE STATION (2026-09-16, his ask: "shape based space stations like
// no man's sky's"): a few signed-distance shapes - a ring, a spindle, a
// hub, pylons; or stacked blocks; or a cluster of pods; or a diamond with
// a band - raymarched per pixel on a quad, orthographic rays (the dice's
// recipe: quad coords from u_quad, one exact ray a cell). u_or maps VIEW
// space onto the station's OBJECT space (its spin and the camera), the
// light comes in view space. the hull is panelled by a hash on the hit
// point, the windows are a sparser hash - lit on the night side.
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;   // quad x, y, w, h in room px
uniform vec3  u_or[3];  // object-from-view rotation rows
uniform vec3  u_light;  // direction TO the light, view space
uniform vec3  u_col;    // the hull
uniform vec3  u_glow;   // the windows
uniform float u_pad;    // quad half-extent in station units (the station fits a unit sphere)
uniform float u_style;  // 0 ring and spindle, 1 block stack, 2 pod cluster, 3 diamond
uniform vec4  u_prm;    // the style's seeded proportions
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

float sd_station(vec3 p)
{
    float d = 1.0e9;
    if (u_style < 0.5) {
        // RING AND SPINDLE: the ring, the spindle through it, a hub, four pylons
        d = sd_torus(p, u_prm.x, u_prm.y);
        d = min(d, sd_cap(p, u_prm.z, u_prm.w));
        d = min(d, sd_box(p, vec3(0.3, 0.22, 0.3)));
        for (int i = 0; i < 4; i++) {
            vec3 q = rot_y(p, float(i) * 1.5708 + u_seed);
            q.x -= u_prm.x * 0.5;
            d = min(d, sd_box(q, vec3(u_prm.x * 0.5, 0.045, 0.045)));
        }
    } else if (u_style < 1.5) {
        // BLOCK STACK: a broad deck, a tower above, a keel below, a spine, an arm
        d = sd_box(p, vec3(0.55 * u_prm.x, 0.22, 0.55 * u_prm.y));
        d = min(d, sd_box(p - vec3(0.0, 0.46, 0.0), vec3(0.3, 0.24, 0.3)));
        d = min(d, sd_box(p + vec3(0.0, 0.46, 0.0), vec3(0.38, 0.2, 0.2)));
        d = min(d, sd_cap(p, 0.95, 0.08));
        d = min(d, sd_box(rot_y(p, u_seed) - vec3(0.62, 0.0, 0.0), vec3(0.32, 0.06, 0.06)));
    } else if (u_style < 2.5) {
        // POD CLUSTER: a core and five pods on struts, staggered up and down
        d = length(p) - 0.42;
        for (int i = 0; i < 5; i++) {
            vec3 q = rot_y(p, float(i) * 1.2566 + u_seed);
            q.x -= 0.62;
            q.y -= (mod(float(i), 2.0) - 0.5) * 0.28 * u_prm.x;
            d = min(d, length(q) - 0.26 * u_prm.y);
            d = min(d, sd_box(q + vec3(0.31, 0.0, 0.0), vec3(0.22, 0.04, 0.04)));
        }
    } else {
        // DIAMOND: an octahedron, a band about its waist, a spine through it
        d = sd_oct(p, 0.95 * u_prm.x);
        d = min(d, sd_torus(p, 0.72 * u_prm.y, 0.07));
        d = min(d, sd_cap(p, 1.05, 0.06));
    }
    return d;
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
