//
// A WORLD'S PORTRAIT (the expedition bench, 2026-09-12): a raycast
// sphere on a square quad, one ray per room-pixel cell (sh_blob's
// recipe - quantise the quad coordinate, one exact sample per cell),
// with a value-noise terrain on its surface: three octaves of
// integer-hash noise sampled ON the sphere, so the world is the same
// every frame and turns under the light (u_time spins the sample
// point about y). Three colours: the sea (u_col1), the land (u_col2),
// the caps (u_col3); u_sea is the level. Lambert + a soft rim, and a
// thin atmosphere ring outside the limb in the land colour.
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;    // x, y, w, h in room px (square)
uniform float u_cells;   // cells across the quad - one per room px
uniform vec3  u_col1;    // the sea
uniform vec3  u_col2;    // the land
uniform vec3  u_col3;    // the caps
uniform float u_sea;     // the sea level, 0..1 of the noise
uniform float u_seed;    // the world's seed, as a noise offset
uniform float u_time;    // the spin
uniform vec3  u_light;   // the light's direction

float hash3(vec3 p)
{
    p = fract(p * vec3(0.1031, 0.1030, 0.0973) + u_seed * 0.001);
    p += dot(p, p.yxz + 33.33);
    return fract((p.x + p.y) * p.z);
}

float vnoise(vec3 p)
{
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n000 = hash3(i + vec3(0.0, 0.0, 0.0));
    float n100 = hash3(i + vec3(1.0, 0.0, 0.0));
    float n010 = hash3(i + vec3(0.0, 1.0, 0.0));
    float n110 = hash3(i + vec3(1.0, 1.0, 0.0));
    float n001 = hash3(i + vec3(0.0, 0.0, 1.0));
    float n101 = hash3(i + vec3(1.0, 0.0, 1.0));
    float n011 = hash3(i + vec3(0.0, 1.0, 1.0));
    float n111 = hash3(i + vec3(1.0, 1.0, 1.0));
    float nx00 = mix(n000, n100, f.x);
    float nx10 = mix(n010, n110, f.x);
    float nx01 = mix(n001, n101, f.x);
    float nx11 = mix(n011, n111, f.x);
    float nxy0 = mix(nx00, nx10, f.y);
    float nxy1 = mix(nx01, nx11, f.y);
    return mix(nxy0, nxy1, f.z);
}

void main()
{
    // gm_BaseTexture stays sampler 0 (sh_blob's lesson): one read
    float keep = max(texture2D(gm_BaseTexture, v_uv).a, 1.0);

    vec2 uv = (v_pos - u_quad.xy) / u_quad.zw;
    vec2 cell = (floor(uv * u_cells) + 0.5) / u_cells;
    vec2 p = cell * 2.0 - 1.0;
    float r2 = dot(p, p);

    vec3 col = vec3(0.0);
    float a  = 0.0;
    if (r2 <= 1.0) {
        vec3 n = vec3(p.x, -p.y, sqrt(1.0 - r2));
        // the sample point turns about y with time
        float ct = cos(u_time), st = sin(u_time);
        vec3 sp = vec3(n.x * ct + n.z * st, n.y, -n.x * st + n.z * ct);
        float h = vnoise(sp * 2.5) * 0.55 + vnoise(sp * 5.0) * 0.3 + vnoise(sp * 10.0) * 0.15;
        float land = step(u_sea, h);
        float cap  = step(0.78, abs(n.y) + (h - 0.5) * 0.3);
        vec3 base = mix(u_col1, u_col2, land);
        base = mix(base, base * (0.75 + 0.5 * h), land);   // the land's relief
        base = mix(base, u_col3, cap);
        float lam = clamp(dot(n, normalize(u_light)), 0.0, 1.0);
        float rim = pow(1.0 - n.z, 3.0);
        col = base * (0.18 + 0.82 * lam) + u_col2 * rim * 0.25;
        a = 1.0;
    } else if (r2 <= 1.25) {
        // the atmosphere: a thin ring fading out from the limb
        float t = 1.0 - (sqrt(r2) - 1.0) / 0.118;
        col = u_col2 * 0.9;
        a = clamp(t, 0.0, 1.0) * 0.45;
    }
    gl_FragColor = vec4(clamp(col, 0.0, 1.0), a * keep);
}
