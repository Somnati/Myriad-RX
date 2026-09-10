//
// THE POINTER, RAYCAST - take two (his correction, 2026-09-10: the first
// pass sampled the sprite for its silhouette and squashed the QUAD, so
// it looked exactly like the sprite method, which was the point of
// leaving the sprite method). This is the dice's construction properly:
// one orthographic ray per ROOM-PIXEL CELL, cast into a solid that is
// deformed in OBJECT SPACE, so the squash re-rasterises the arrow cell
// by cell - the pixelation is native, the way a squashed die's is - and
// the bevel that catches the light is the deformed solid's bevel.
//
// THE SOLID. An extruded arrow with a quarter-round bevel: its plan is
// the sprite's own signed distance field, BAKED (spr_cursor_sdf, 8
// samples per sprite px, exact euclidean distance to the pixel edges,
// packed over -4..+4 px). Baked rather than a polygon because a
// polygon fitted to hand-placed pixels matches them at most corners
// and misses one or two, and this arrow has to be the sprite's arrow
// to the pixel at rest. At rest every cell centre lands on a sprite
// pixel centre, where the field reads <= -0.5 inside and >= +0.5 out,
// so `d < 0` IS the sprite's coverage; the ring is the sprite's own
// black pixels, baked into the field's second channel, so it is the
// sprite's ring by construction. Squashed, the same two reads run on
// the deformed field and the shape simply re-rasterises.
//
// THE RAY is solved, not marched: top-down orthographic into a shape
// with no overhangs hits the height field over its own cell, z =
// profile(depth inside the edge). The normal is the profile's slope
// along the field's gradient (four extra samples), scaled by u_flat -
// a press flattens the solid, and a flatter bevel tilts less, so the
// highlight softens as the arrow squashes. Same light, same diffuse /
// specular / rim model as the puck.
//
varying vec2 v_pos;

uniform vec4  u_quad;   // quad x, y, w, h in room px
uniform vec2  u_tip;    // the hotspot, room px (whole pixels)
uniform vec4  u_uv;     // the sdf sprite's texel rect on its page
uniform vec2  u_axis;   // the arrow's axis, tip to tail, unit (screen)
uniform vec2  u_sq;     // the squash: scale along the axis, scale across
uniform float u_flat;   // height scale, 1 at rest, lower pressed
uniform vec3  u_light;  // direction TO the light, view space
uniform float u_cells;  // cells across the quad (one per room px)
uniform float u_lit;    // 0 = flat white + ink (the sprite's look), 1 = lit
// MOTION BLUR (his ask, 2026-09-10 - the puck's law): the sweep from
// the tip's last drawn seat to this one over a fixed 1/60 shutter, in
// room px, and the number of instants along it each cell is cast at.
// The quad covers the whole sweep. Alpha out is hits / K, so a cell the
// arrow covered all shutter long is solid and one it flicked through
// is a translucent trail - as blocky as the arrow, since the
// accumulation is per cell.
uniform vec2  u_mb;     // the sweep, start -> end (end = u_tip), room px
uniform float u_mbk;    // instants along it, 1 = no blur

const float R    = 2.3;   // bevel radius, sprite px
const vec2  HOT  = vec2(3.0, 2.0);   // the sprite's origin, in its px
const float SIZE = 16.0;

// (field_rg, not `sample`: the Windows build cross-compiles to HLSL,
// where sample and cast are keywords - the puck learned that one)
vec3 field_rg(vec2 op)
{
    vec2 uv = u_uv.xy + clamp(op / SIZE, 0.0, 1.0) * (u_uv.zw - u_uv.xy);
    return texture2D(gm_BaseTexture, uv).rgb;
}
float field(vec2 op) { return field_rg(op).r * 8.0 - 4.0; }

// one instant: the cell's centre rp against the tip at `tip`. Returns
// false where the arrow is not, else the shaded colour.
bool cur_cast(vec2 rp, vec2 tip, out vec3 col)
{
    // room -> object: undo the squash about the tip. Along the axis the
    // solid is SHORTER by u_sq.x, across it WIDER by u_sq.y, so a screen
    // point maps to an object point further along and nearer across.
    vec2 rel = rp - tip;
    vec2 ax  = u_axis;
    vec2 nx  = vec2(-ax.y, ax.x);
    float al = dot(rel, ax) / u_sq.x;
    float ac = dot(rel, nx) / u_sq.y;
    vec2 op  = HOT + al * ax + ac * nx;       // sprite px, top-left origin
    if (op.x < 0.0 || op.y < 0.0 || op.x >= SIZE || op.y >= SIZE) return false;

    vec3 t = field_rg(op);
    float d = t.r * 8.0 - 4.0;
    if (d >= 0.0) return false;                // the sprite's coverage
    float ink = step(0.5, t.g);                // ...and its own ink ring
    // ...and its own TONE (his report, 2026-09-10: the model had lost the
    // tail's shadow shading the sprite has). The sprite is four greys -
    // white head, a lighter step, the shadowed tail, the dark outline -
    // and they are the ALBEDO here: the raycast lights them rather than
    // a flat white, so the tail stays in shadow and the bevel still
    // catches the light on top of it. Flat mode is the sprite exactly.
    float alb = t.b;

    if (u_lit < 0.5) {
        col = vec3(alb);
        return true;
    }

    // the height field: e = depth inside the edge, a quarter-round
    // bevel of radius R up to the flat top; slope = dz/de, the normal
    // tilts OUTWARD along the field's gradient by it, u_flat times
    float e = clamp(-d, 0.0, R);
    float u = 1.0 - e / R;
    float slope = (e < R) ? u / max(sqrt(1.0 - u * u), 0.08) : 0.0;
    vec2 h = vec2(0.25, 0.0);
    vec2 g = normalize(vec2(field(op + h.xy) - field(op - h.xy),
                            field(op + h.yx) - field(op - h.yx)) + vec2(0.00001));
    // the gradient is in object space; the squash shears it back into
    // screen space so the lit side stays the lit side while squashed
    vec2 gs = normalize(vec2(dot(g, ax) * u_sq.x, dot(g, nx) * u_sq.y));
    vec2 gv = gs.x * ax + gs.y * nx;
    vec3 n = normalize(vec3(gv * slope * u_flat, 1.0));

    // ---- lighting, the puck's model, on white matte ----
    vec3 body = vec3(alb);
    float df  = clamp(dot(n, u_light), 0.0, 1.0);
    col = body * (0.55 + 0.55 * df);           // flat top ~90% of the tone, lit bevel to 100%
    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), n);
    float sp2 = pow(clamp(dot(rf, u_light), 0.0, 1.0), 14.0);
    col += vec3(1.0) * sp2 * 0.22;
    float fr = pow(1.0 - clamp(abs(n.z), 0.0, 1.0), 2.0);
    col += vec3(1.0) * fr * 0.10;

    // the ring is the sprite's own dark grey, dimmer where the wall
    // faces away from the rim catch
    vec3 ring = vec3(alb) * (0.6 + 0.4 * fr);
    col = clamp(mix(col, ring, ink), 0.0, 1.0);
    return true;
}

void main()
{
    // one exact ray per cell: quantize the QUAD COORDINATE (the puck)
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 rp = u_quad.xy + q * u_quad.zw;      // the cell's centre, room px

    // K instants along the sweep: the tip at instant ft sits (1 - ft)
    // of the sweep behind where it is now
    int K = int(u_mbk + 0.5);
    if (K < 1) K = 1;
    vec3 acc = vec3(0.0);
    float hits = 0.0;
    for (int i = 0; i < 16; i++) {           // (sixteen: a flick is long)
        if (i >= K) break;
        float ft = (float(i) + 0.5) / float(K);
        vec2 tip = u_tip - u_mb * (1.0 - ft);
        vec3 c;
        if (cur_cast(rp, tip, c)) { acc += c; hits += 1.0; }
    }
    if (hits < 0.5) discard;
    gl_FragColor = vec4(acc / hits, hits / float(K));
}
