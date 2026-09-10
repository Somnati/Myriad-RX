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

const float R    = 2.3;   // bevel radius, sprite px
const vec2  HOT  = vec2(3.0, 2.0);   // the sprite's origin, in its px
const float SIZE = 16.0;

vec3 sample(vec2 op)
{
    vec2 uv = u_uv.xy + clamp(op / SIZE, 0.0, 1.0) * (u_uv.zw - u_uv.xy);
    return texture2D(gm_BaseTexture, uv).rgb;
}
float field(vec2 op) { return sample(op).r * 8.0 - 4.0; }

void main()
{
    // one exact ray per cell: quantize the QUAD COORDINATE (the puck)
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 rp = u_quad.xy + q * u_quad.zw;      // the cell's centre, room px

    // room -> object: undo the squash about the tip. Along the axis the
    // solid is SHORTER by u_sq.x, across it WIDER by u_sq.y, so a screen
    // point maps to an object point further along and nearer across.
    vec2 rel = rp - u_tip;
    vec2 ax  = u_axis;
    vec2 nx  = vec2(-ax.y, ax.x);
    float al = dot(rel, ax) / u_sq.x;
    float ac = dot(rel, nx) / u_sq.y;
    vec2 op  = HOT + al * ax + ac * nx;       // sprite px, top-left origin
    if (op.x < 0.0 || op.y < 0.0 || op.x >= SIZE || op.y >= SIZE) discard;

    vec3 t = sample(op);
    float d = t.r * 8.0 - 4.0;
    if (d >= 0.0) discard;                     // the sprite's coverage
    float ink = step(0.5, t.g);                // ...and its own ink ring

    if (u_lit < 0.5) {
        gl_FragColor = vec4(vec3(1.0 - ink), 1.0);
        return;
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
    vec3 body = vec3(0.97);
    float df  = clamp(dot(n, u_light), 0.0, 1.0);
    vec3 col = body * (0.50 + 0.58 * df);      // flat top ~85% white, lit bevel to 100%
    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), n);
    float sp2 = pow(clamp(dot(rf, u_light), 0.0, 1.0), 14.0);
    col += vec3(1.0) * sp2 * 0.22;
    float fr = pow(1.0 - clamp(abs(n.z), 0.0, 1.0), 2.0);
    col += vec3(1.0) * fr * 0.10;

    // the ring stays ink; the rim only lifts it a shade
    vec3 ring = vec3(0.02) + vec3(0.14) * fr;
    col = mix(col, ring, ink);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
