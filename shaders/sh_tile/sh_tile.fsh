//
// THE TILE: a per-pixel raymarched SLAB on a quad, orthographic rays,
// top-down - obj_dice's construction with the cube replaced by a thin
// extrusion of one of six 2D footprints (his ask: the tiles as fake 3D
// like the dice and the puck, in coloured materials).
//
// ⚖️ WHY A SOLID WHEN NOTHING ROTATES. I argued against this once on the
// grounds that raymarching buys rotation and tiles do not turn. That
// was wrong, or at least badly overstated: a resting die still reads as
// an object, and what makes it read is not the tumble, it is LIGHT
// FALLING ACROSS A BEVEL. The rim curves away from the lamp, the top
// face carries a specular with an actual shape, and metal-versus-matte
// is legible from the FORM of the highlight. A flat draw has no surface
// for light to fall across, so its "highlight" is a pip - and a pip on
// a 13px tile reads as a smudge. This shader exists because the 2D
// version was tried and looked like exactly that.
//
// It also rescues iridescence honestly. The film is a hue swept by the
// facing term, which on a flat tile is a constant - but a bevelled slab
// has edges that face AWAY, so the film lives where it should, on the
// rim, and the top face stays the body colour. The number sits on top
// of that and stays readable, which is the constraint every decision
// here answers to.
//
// FOOTPRINTS. Six 2D distance fields, extruded and rounded. The shape
// is a real part of the geometry rather than a stencil, so the bevel
// follows a diamond's points and a hexagon's corners rather than
// squaring off inside them. Selected by u_shape; the aspect comes in
// separately so a tile that changes size keeps its proportions.
//
// quad coords quantize to u_cells - one exact ray per cell, razor-sharp
// blocks, never averaged (the house pixelation rule).
//
varying vec2 v_pos;

uniform vec4  u_quad;   // quad x, y, w, h in room px
uniform float u_pad;    // quad half-extent in tile HALF-WIDTHS
uniform float u_aspect; // footprint half-height / half-width
uniform float u_shape;  // 0 rect 1 rounded 2 diamond 3 ellipse 4 hex 5 octagon
uniform vec3  u_light;  // direction TO the light, view space
uniform vec3  u_col;    // body colour 0..1 - the rarity ladder's
uniform float u_metal;  // finish: 0 matte .. 1 metallic
uniform float u_iri;    // iridescence 0..1
uniform float u_cells;  // pixel cells across the quad. 0 = off

const float HH = 0.22;  // slab half-thickness, in half-widths. Thin:
                        // this is a tile, not a die, and a thick one
                        // reads as a block of cheese
const float RD = 0.10;  // edge rounding - the bevel the light needs

// ---- the footprints, in a space where the half-width is 1 ----
float sd_box2(vec2 p, vec2 b)
{
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float ndot(vec2 a, vec2 b) { return a.x * b.x - a.y * b.y; }

float sd_rhombus2(vec2 p, vec2 b)
{
    p = abs(p);
    float h = clamp(ndot(b - 2.0 * p, b) / dot(b, b), -1.0, 1.0);
    float d = length(p - 0.5 * b * vec2(1.0 - h, 1.0 + h));
    return d * sign(p.x * b.y + p.y * b.x - b.x * b.y);
}

float sd_foot(vec2 p)
{
    vec2 b = vec2(1.0, u_aspect);
    float s = u_shape;
    if (s < 0.5) return sd_box2(p, b);                          // rect
    if (s < 1.5) return sd_box2(p, b - 0.18) - 0.18;             // rounded
    if (s < 2.5) return sd_rhombus2(p, b);                       // diamond
    if (s < 3.5) return (length(p / b) - 1.0) * min(b.x, b.y);   // ellipse
    if (s < 4.5) {                                               // hexagon
        // a box with its two ends chamfered: the rhombus through the
        // box's mid-ends and twice its height only touches the corners
        return max(sd_box2(p, b), sd_rhombus2(p, vec2(b.x, b.y * 2.0)));
    }
    // octagon: the box under an L1 cut on all four corners
    float l1 = (abs(p.x) / b.x + abs(p.y) / b.y - 1.55) * min(b.x, b.y) * 0.5;
    return max(sd_box2(p, b), l1);
}

// extrude the footprint to a slab, then round every edge of it
float sd_tile(vec3 p)
{
    vec2 w = vec2(sd_foot(p.xy) + RD, abs(p.z) - (HH - RD));
    return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - RD;
}

vec3 iri_hue(float t)
{
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

void main()
{
    // quantize the QUAD COORDINATE, not the output: every cell casts one
    // ray, so the pixelation is native rather than a filter over it
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) {
        // cells are square in ROOM pixels, so the count differs per axis
        vec2 cells = vec2(u_cells, u_cells * u_quad.w / u_quad.z);
        q = (floor(q * cells) + 0.5) / cells;
    }
    // the quad is padded equally in room px; map it back to footprint
    // space, where the half-width is 1 and the half-height is u_aspect
    vec2 s = (q * 2.0 - 1.0) * u_pad;
    s.y *= u_quad.w / u_quad.z;

    // orthographic ray, straight down. No rotation, so object space IS
    // view space - the whole saving a static solid gets over a die.
    vec3 ro = vec3(s, 2.0);
    vec3 rd = vec3(0.0, 0.0, -1.0);

    float t = 1.0;
    float d = 1.0;
    for (int i = 0; i < 36; i++) {
        d = sd_tile(ro + rd * t);
        if (d < 0.003 || t > 4.0) break;
        t += d;
    }
    if (d >= 0.003) discard;

    vec3 p = ro + rd * t;
    vec2 e = vec2(0.002, 0.0);
    vec3 n = normalize(vec3(
        sd_tile(p + e.xyy) - sd_tile(p - e.xyy),
        sd_tile(p + e.yxy) - sd_tile(p - e.yxy),
        sd_tile(p + e.yyx) - sd_tile(p - e.yyx)));

    // ---- lighting: the die's model ----
    // matte <-> metallic: metal drops the diffuse floor, tightens and
    // boosts the glint, and TINTS the reflection with the body colour
    float df  = clamp(dot(n, u_light), 0.0, 1.0);
    float dfw = mix(0.38 + 0.70 * df, 0.18 + 0.50 * df, u_metal);
    vec3 col = u_col * dfw;

    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), n);
    float sp = pow(clamp(dot(rf, u_light), 0.0, 1.0), mix(8.0, 34.0, u_metal));
    vec3 spc = mix(vec3(1.0), clamp(u_col * 1.2 + vec3(0.12), 0.0, 1.0), u_metal);
    float fr = pow(1.0 - clamp(n.z, 0.0, 1.0), 3.0);

    // the film lives on the BEVEL, where the surface actually turns
    // away - the top face keeps the body colour so the number on it
    // stays a number
    if (u_iri > 0.0) {
        vec3 ih = iri_hue(fr * 0.9 + df * 0.3);
        spc = mix(spc, ih, u_iri);
        col = mix(col, mix(col, ih * (0.5 + 0.5 * dfw), 0.55), u_iri * fr);
    }

    col += spc * sp * mix(0.20, 0.85, u_metal);
    col += spc * fr * mix(0.10, 0.30, max(u_metal, u_iri));

    gl_FragColor = vec4(col, 1.0);
}
