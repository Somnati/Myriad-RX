//
// A NEBULA (2026-09-16): one cloud on a white quad (nebula_quad, texcoords
// 0..1), additive. his report: the sky's nebulae were round patches - so
// the disc's edge here is BENT by two noise fields (the same point of the
// quad lands at a different distance from the centre every direction), the
// body is mottled by a third, and ridged noise lays filaments through it
// that whiten where they run. two colours, mixed by the mottle. the seed
// is the cloud's own: the same cloud on the map and in every sky.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_seed;
uniform vec3  u_col;
uniform vec3  u_col2;
uniform float u_kind;    // 0 diffuse, 1 shell, 2 pillars, 3 veil (neb_body)

float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p)
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

float fbm(vec2 p)
{
    float s = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        s += a * vnoise(p);
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
    vec2 q = vec2(fbm(p), fbm(p + vec2(3.1, 7.3)));
    vec2 wv = uv + (q - 0.5) * 1.1;
    float d = length(wv);
    float n = fbm(p * 2.3 + q * 2.5 + vec2(1.7, 9.2));
    float f = 1.0 - abs(2.0 * fbm(p * 3.7 + q * 1.5 + vec2(5.0, 2.0)) - 1.0);
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
        float streak = 0.5 + 0.5 * fbm(vec2(wv.x * 9.0, wv.y * 1.6) + seed);
        body = (1.0 - smoothstep(0.1, 1.0, length(sv))) * (0.35 + 0.9 * streak);
        body = body * body;
    } else {
        body = (1.0 - smoothstep(0.3, 1.0, d)) * f * f * 0.9;
    }
    return vec3(body, n, f);
}

void main()
{
    vec2 uv = v_vTexcoord * 2.0 - 1.0;                       // -1..1 across the quad
    vec3 bd = neb_body(uv, u_seed, u_kind);
    float body = bd.x;
    float n = bd.y;
    float f = bd.z;
    float a = body * (0.25 + 0.9 * n) * (0.5 + 0.7 * f * f);
    vec3 col = mix(u_col, u_col2, smoothstep(0.25, 0.75, n));
    col += vec3(0.25) * f * f * body;
    gl_FragColor = vec4(col, clamp(a, 0.0, 1.0)) * v_vColour;
}
