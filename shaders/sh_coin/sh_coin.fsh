//
// THE COIN (2026-09-13): a per-pixel raymarched ROUNDED CYLINDER on a
// quad, orthographic rays, the sh_dice recipe with a different SDF and
// one real difference: the engraving is RELIEF, not paint. The tech
// demo's coin darkened a mask on the face (dots, rings) and read as
// dirt; this bends the NORMAL by the gradient of a height field - a
// raised rim ridge, a raised eight-spoke sun on heads, a raised ring
// and diamond on tails, a reeded edge - so every ridge has a lit side
// and a shadowed side and turns with the light as the coin tumbles.
// Metal lighting is the die's (u_metal 1: low diffuse floor, tight
// tinted glint, grazing sheen) with the room's light on the faces.
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;  // quad x, y, w, h in room px
uniform vec3  u_or[3]; // object-from-view rotation rows
uniform vec3  u_light; // direction TO the light, view space
uniform vec3  u_col;   // metal tint 0..1
uniform float u_metal; // finish: 0 matte .. 1 metal (a coin is 1)
uniform float u_pad;   // quad half-extent in coin radii
uniform float u_cells; // pixel cells across the quad. 0 = off
uniform sampler2D u_scene;    // the room's light: tight (reflection)
uniform sampler2D u_scene2;   // ...and wide (ambient wash)
uniform vec2  u_scene_uv;
uniform float u_scene_amt;

const float CT  = 0.18;  // half thickness (coin radius = 1) - obj_coin's ct
const float RDC = 0.10;  // edge rounding - obj_coin's rrc
const float REL = 0.055; // the relief's height, in radii

float sd_coin(vec3 p)
{
    vec2 q = vec2(length(p.xy) - (1.0 - RDC), abs(p.z) - (CT - RDC));
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - RDC;
}

// the height field on a face, 0..1: the rim ridge on both, then heads'
// sun (a boss and eight spokes) or tails' ring and diamond
float relief(vec2 f, float heads)
{
    float rl  = length(f);
    float ang = atan(f.y, f.x);
    float ridge = smoothstep(0.72, 0.79, rl) * (1.0 - smoothstep(0.87, 0.94, rl));
    float h = ridge;
    if (heads > 0.5) {
        float spokes = smoothstep(0.1, 0.7, cos(ang * 8.0))
                     * smoothstep(0.13, 0.20, rl) * (1.0 - smoothstep(0.50, 0.58, rl));
        float boss = 1.0 - smoothstep(0.08, 0.15, rl);
        h += max(spokes, boss);
    } else {
        float ring = smoothstep(0.40, 0.47, rl) * (1.0 - smoothstep(0.53, 0.60, rl));
        float dia  = 1.0 - smoothstep(0.17, 0.24, abs(f.x) + abs(f.y));
        h += max(ring, dia);
    }
    return h;
}

void main()
{
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 s = (q * 2.0 - 1.0) * u_pad;

    // (gm_BaseTexture stays sampler 0 - the die's lesson, 2026-09-11)
    float keep = max(texture2D(gm_BaseTexture, v_uv).a, 1.0);

    // the room's light, read up here (no texture reads in divergent flow)
    vec2 spos = u_quad.xy + q * u_quad.zw;
    vec3 sw0 = texture2D(u_scene2, clamp( spos                     * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 swx = texture2D(u_scene2, clamp((spos + vec2( 18.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene2, clamp((spos + vec2(-18.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 swy = texture2D(u_scene2, clamp((spos + vec2(0.0,  18.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene2, clamp((spos + vec2(0.0, -18.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 st0 = texture2D(u_scene,  clamp( spos                     * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 stx = texture2D(u_scene,  clamp((spos + vec2( 7.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene,  clamp((spos + vec2(-7.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 sty = texture2D(u_scene,  clamp((spos + vec2(0.0,  7.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene,  clamp((spos + vec2(0.0, -7.0)) * u_scene_uv, 0.0, 1.0)).rgb;

    // orthographic ray, view -> object
    vec3 rov = vec3(s, 3.2);
    vec3 rdv = vec3(0.0, 0.0, -1.0);
    vec3 ro = vec3(dot(u_or[0], rov), dot(u_or[1], rov), dot(u_or[2], rov));
    vec3 rd = vec3(dot(u_or[0], rdv), dot(u_or[1], rdv), dot(u_or[2], rdv));

    float t = 1.6;
    float d = 1.0;
    for (int i = 0; i < 48; i++) {
        d = sd_coin(ro + rd * t);
        if (d < 0.003 || t > 6.0) break;
        t += d;
    }
    if (d > 0.02) { gl_FragColor = vec4(0.0); return; }

    vec3 p = ro + rd * t;
    vec2 e = vec2(0.004, -0.004);
    vec3 n = normalize(
          vec3(e.x, e.y, e.y) * sd_coin(p + vec3(e.x, e.y, e.y))
        + vec3(e.y, e.y, e.x) * sd_coin(p + vec3(e.y, e.y, e.x))
        + vec3(e.y, e.x, e.y) * sd_coin(p + vec3(e.y, e.x, e.y))
        + vec3(e.x, e.x, e.x) * sd_coin(p + vec3(e.x, e.x, e.x)));

    // ---- THE RELIEF: on the flats, bend the normal by the height
    // field's gradient (central differences in the face plane); on the
    // edge, reeds - a sine round the rim pushed along the tangent ----
    float facew = smoothstep(0.62, 0.82, abs(n.z));
    float rimw  = 1.0 - smoothstep(0.45, 0.65, abs(n.z));
    float heads = (n.z > 0.0) ? 1.0 : 0.0;
    vec2  f  = p.xy;
    float h  = relief(f, heads);
    float lift = 0.0;
    if (facew > 0.0) {
        float de = 0.03;
        float hx = relief(f + vec2(de, 0.0), heads) - relief(f - vec2(de, 0.0), heads);
        float hy = relief(f + vec2(0.0, de), heads) - relief(f - vec2(0.0, de), heads);
        float k  = REL / (2.0 * de);
        vec3 nb = normalize(vec3(-hx * k, -hy * k, sign(n.z)));
        n = normalize(mix(n, nb, facew));
        lift = h * facew;
    }
    if (rimw > 0.0) {
        float rl  = max(length(f), 0.001);
        float ang = atan(f.y, f.x);
        vec3 tng = vec3(-f.y, f.x, 0.0) / rl;
        n = normalize(n + tng * sin(ang * 48.0) * 0.45 * rimw);
    }

    // ---- the die's metal lighting ----
    vec3 nv = u_or[0] * n.x + u_or[1] * n.y + u_or[2] * n.z;
    float df = clamp(dot(nv, u_light), 0.0, 1.0);
    float dfw = mix(0.35 + 0.72 * df, 0.18 + 0.56 * df, u_metal);
    vec3 col = u_col * dfw;
    // the raised metal catches a touch more light than the field
    col *= 1.0 + 0.10 * lift;

    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), nv);
    float sp = pow(clamp(dot(rf, u_light), 0.0, 1.0), mix(9.0, 30.0, u_metal));
    vec3 spc = mix(vec3(1.0), clamp(u_col * 1.2 + vec3(0.12), 0.0, 1.0), u_metal);
    float fr = pow(1.0 - clamp(nv.z, 0.0, 1.0), 3.0);
    col += spc * sp * mix(0.22, 0.95, u_metal);
    col += spc * fr * 0.22 * u_metal;

    vec3 amb  = max(sw0 + swx * 0.5 * nv.x + swy * 0.5 * nv.y, 0.0);
    vec3 refl = max(st0 + stx * 0.5 * nv.x + sty * 0.5 * nv.y, 0.0);
    col += u_col * amb * u_scene_amt * 1.1;
    col += spc * refl * u_scene_amt * (0.5 * u_metal + 0.35 * fr);

    gl_FragColor = vec4(col, keep);
}
