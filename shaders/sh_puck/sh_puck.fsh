//
// THE PUCK: a per-pixel raymarched ROUNDED CYLINDER on a quad,
// orthographic rays, top-down - obj_dice's construction with a
// different solid (his ask: make the puck 3D like the dice, and make it
// look like a hockey puck).
//
// ⚖️ ONE ANGLE, NOT A MATRIX. The die needed a full object-from-view
// rotation because it tumbles: any of its six faces can end up pointing
// at the camera, and pips have to be carved per-face from the object-
// space hit point. A puck lying on a table has exactly one degree of
// freedom - it YAWS. So this takes a single float, builds the rotation
// in the shader from one sin/cos pair, and skips nine uniforms, nine
// dot products per ray and the entire mat3 dependency.
//
// quad coords quantize to u_cells - one exact ray per cell, razor-sharp
// blocks, never averaged (the house pixelation rule).
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;  // quad x, y, w, h in room px
uniform float u_yaw;   // spin about the puck's axis, RADIANS
uniform vec3  u_light; // direction TO the light, view space
uniform vec3  u_col;   // rubber body 0..1
uniform vec3  u_ring;  // the stamped ring on the crown - the throw's
                       // own colour, so a puck is still identifiable
                       // mid-flight without being a coloured blob
uniform float u_metal; // finish: 0 = matte rubber, 1 = polished
uniform float u_pad;   // quad half-extent in puck radii
uniform float u_cells; // pixel cells across the quad. 0 = off
// THE ROOM'S LIGHT (syst_scene_light, 2026-09-11) - see sh_dice
uniform sampler2D u_scene;
uniform sampler2D u_scene2;
uniform vec2  u_scene_uv;
uniform float u_scene_amt;
// ⚖️ MOTION BLUR, THE REAL KIND (his ask, 2026-09-10: per-object blur
// for the mouse, puck, dice and bits - the puck first). The quad is
// centred on the MIDPOINT of this frame's sweep (last drawn centre to
// this one, over a fixed 1/60 shutter), and every cell casts its ray
// K times, at K transforms spread evenly along that sweep - position
// AND yaw - accumulating the shaded hits. Output is the mean colour at
// alpha hits/K: a cell the puck covered for the whole shutter is solid,
// one it only passed through is a translucent trail. Every sub-sample
// is a real lit hit of the real solid, so the knurl smears into bands
// and the stamped ring streaks exactly as a camera would see it; and
// the accumulation is PER CELL, so the blur is as blocky as the puck.
uniform vec3  u_mb;    // the sweep: xy in radii (start -> end), z the yaw swept, radians
uniform float u_mbk;   // sub-samples across the sweep, 1 = no blur

const float HH = 0.34;  // half-height in radii. A real puck is 3in
                        // across and 1in thick, so 0.333 - and it is
                        // worth being accurate here, because the
                        // proportion IS the silhouette
const float CR = 0.09;  // edge rounding. Pucks are sharp-ish; too much
                        // rounding and it reads as a pebble

// rounded cylinder, radius 1, half-height HH
float sd_puck(vec3 p)
{
    vec2 d = vec2(length(p.xy) - (1.0 - CR), abs(p.z) - (HH - CR));
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - CR;
}

// one ray, one transform (puck_cast: `cast` is an HLSL intrinsic and the
// Windows build cross-compiles to HLSL): the cell's quad point s (in radii, about the
// quad centre), the puck's yaw at that instant. Returns false on a miss.
bool puck_cast(vec2 s, float yaw, vec3 sw0, vec3 swx, vec3 swy, vec3 st0, vec3 stx, vec3 sty, out vec3 col)
{
    // view -> object is a yaw about z, so it is a 2x2 on xy and nothing
    // on the axis. Inverse of a rotation by yaw is a rotation by -yaw.
    float cy = cos(-yaw);
    float sy = sin(-yaw);
    vec3 ro = vec3(s.x * cy - s.y * sy, s.x * sy + s.y * cy, 3.0);
    vec3 rd = vec3(0.0, 0.0, -1.0);

    float t = 1.2;
    float d = 1.0;
    for (int i = 0; i < 40; i++) {
        d = sd_puck(ro + rd * t);
        if (d < 0.004 || t > 5.5) break;
        t += d;
    }
    if (d >= 0.004) return false;

    vec3 p = ro + rd * t;

    // normal by central differences on the same field the silhouette
    // came from, so shading and outline can never disagree
    vec2 e = vec2(0.0025, 0.0);
    vec3 n = normalize(vec3(
        sd_puck(p + e.xyy) - sd_puck(p - e.xyy),
        sd_puck(p + e.yxy) - sd_puck(p - e.yxy),
        sd_puck(p + e.yyx) - sd_puck(p - e.yyx)));

    float rad = length(p.xy);
    float ang = atan(p.y, p.x);
    float top = smoothstep(0.55, 0.85, abs(n.z));   // crown vs side wall

    vec3 body = u_col;

    // ---- THE KNURL ----
    // A real puck's edge is cut with vertical grooves so a stick can
    // grip it, and it is the single detail that makes the silhouette
    // read as "hockey puck" rather than "black cylinder". It also does
    // the spin an enormous favour: a smooth black cylinder rotating
    // about its own axis is INVISIBLY rotating, and the grooves are
    // what turn u_yaw into something you can actually see.
    float kn = 0.5 + 0.5 * cos(ang * 34.0);
    kn = smoothstep(0.35, 0.9, kn);
    body *= mix(1.0, mix(0.72, 1.16, kn), 1.0 - top);

    // ---- THE CROWN ----
    // the shallow dish real pucks have stamped into both faces, and the
    // coloured ring around it
    float dish = smoothstep(0.80, 0.62, rad) * top;
    body *= mix(1.0, 0.88, dish);
    float ring = smoothstep(0.055, 0.0, abs(rad - 0.70)) * top;
    body = mix(body, u_ring, ring * 0.92);
    // a hairline highlight just outside it, so the stamp reads as
    // pressed INTO the rubber rather than painted onto it
    float lip = smoothstep(0.03, 0.0, abs(rad - 0.775)) * top;
    body = mix(body, body * 1.5 + 0.06, lip * 0.6);

    // ---- lighting, the die's model ----
    // the puck's axis is the view axis, so object space IS view space
    // for the normal - no transform needed, which is the other saving
    // the single-yaw form buys
    float df  = clamp(dot(n, u_light), 0.0, 1.0);
    float dfw = mix(0.30 + 0.75 * df, 0.16 + 0.52 * df, u_metal);
    col = body * dfw;

    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), n);
    float sp = pow(clamp(dot(rf, u_light), 0.0, 1.0), mix(11.0, 40.0, u_metal));
    vec3 spc = mix(vec3(1.0), clamp(u_col * 1.2 + vec3(0.12), 0.0, 1.0), u_metal);
    // rubber is not shiny, and the restraint is the point: the ONE
    // bright thing on this object should be the coloured ring, or the
    // puck stops reading as a heavy dull object
    col += spc * sp * mix(0.14, 0.9, u_metal);

    // the rim catch, which on a dark matte cylinder is most of what
    // separates it from the room behind it
    float fr = pow(1.0 - clamp(abs(n.z), 0.0, 1.0), 2.0);
    col += spc * fr * 0.13 * (1.0 - top);

    // ---- the room's light, along the normal (rubber takes a wash,
    // polish takes a reflection; the taps were read in main) ----
    vec3 amb  = max(sw0 + swx * 0.5 * n.x + swy * 0.5 * n.y, 0.0);
    vec3 refl = max(st0 + stx * 0.5 * n.x + sty * 0.5 * n.y, 0.0);
    col += body * amb * u_scene_amt * 1.3;
    col += spc * refl * u_scene_amt * (0.55 * u_metal + 0.25 * fr);
    return true;
}

void main()
{
    // quantize the QUAD COORDINATE, not the output: every cell casts its
    // rays from one point, so the pixelation is native rather than a
    // filter over it
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 s = (q * 2.0 - 1.0) * u_pad;

    // ⚖️ gm_BaseTexture MUST STAY SAMPLER 0 (his report, 2026-09-11:
    // "interpolation on random UI elements"). A shader that never reads
    // it does not get it, so u_scene became sampler 0 - the stage
    // draw_sprite binds the quad's own texture to, which clobbered the
    // scene copy, and the filter scene_light_bind switched on for that
    // stage was then the filter for EVERY draw after. One read of the
    // base texture keeps it in slot 0 and the scene samplers in 1 / 2;
    // max(a, 1) is 1 for the opaque pixel quad and is not optimised out
    float keep = max(texture2D(gm_BaseTexture, v_uv).a, 1.0);

    // ---- THE ROOM'S LIGHT: five taps of each blurred copy around this
    // cell, read HERE - before the raymarch's early exit - because the
    // HLSL side forbids a texture read inside divergent flow. The
    // normal mixes them later: a face leaning left takes the left tap
    vec2 spos = u_quad.xy + q * u_quad.zw;
    vec3 sw0 = texture2D(u_scene2, clamp( spos                     * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 swx = texture2D(u_scene2, clamp((spos + vec2( 16.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene2, clamp((spos + vec2(-16.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 swy = texture2D(u_scene2, clamp((spos + vec2(0.0,  16.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene2, clamp((spos + vec2(0.0, -16.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 st0 = texture2D(u_scene,  clamp( spos                     * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 stx = texture2D(u_scene,  clamp((spos + vec2( 6.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene,  clamp((spos + vec2(-6.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 sty = texture2D(u_scene,  clamp((spos + vec2(0.0,  6.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene,  clamp((spos + vec2(0.0, -6.0)) * u_scene_uv, 0.0, 1.0)).rgb;

    // K transforms along the sweep (see u_mb): the puck's centre at
    // sub-frame t sits (t - .5) of the sweep from the quad centre, and
    // its yaw is this frame's less what it still had to turn
    int K = int(u_mbk + 0.5);
    if (K < 1) K = 1;
    vec3 acc = vec3(0.0);
    float hits = 0.0;
    for (int i = 0; i < 8; i++) {
        if (i >= K) break;
        float ft = (float(i) + 0.5) / float(K);
        vec2 off = (ft - 0.5) * u_mb.xy;
        float yw = u_yaw - (1.0 - ft) * u_mb.z;
        vec3 c;
        if (puck_cast(s - off, yw, sw0, swx, swy, st0, stx, sty, c)) { acc += c; hits += 1.0; }
    }
    if (hits < 0.5) discard;
    gl_FragColor = vec4(acc / hits, hits / float(K) * keep);
}
