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

void main()
{
    vec2 uv = v_vTexcoord * 2.0 - 1.0;                       // -1..1 across the quad
    vec2 p = uv * 1.8 + vec2(u_seed, u_seed * 1.7);
    // the bend: two fields push every point of the disc somewhere else
    vec2 q = vec2(fbm(p), fbm(p + vec2(3.1, 7.3)));
    vec2 w = uv + (q - 0.5) * 1.1;
    float d = length(w);
    float body = 1.0 - smoothstep(0.1, 1.0, d);
    // the mottle, and the filaments (ridged noise: bright where it folds)
    float n = fbm(p * 2.3 + q * 2.5 + vec2(1.7, 9.2));
    float f = 1.0 - abs(2.0 * fbm(p * 3.7 + q * 1.5 + vec2(5.0, 2.0)) - 1.0);
    float a = body * body * (0.25 + 0.9 * n) * (0.5 + 0.7 * f * f);
    vec3 col = mix(u_col, u_col2, smoothstep(0.25, 0.75, n));
    col += vec3(0.25) * f * f * body;
    gl_FragColor = vec4(col, clamp(a, 0.0, 1.0)) * v_vColour;
}
