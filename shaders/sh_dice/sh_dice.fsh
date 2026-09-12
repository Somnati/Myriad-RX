//
// lil die: per-pixel raymarched ROUNDED CUBE on a quad, orthographic
// rays (the house planet style, boxed). u_or maps VIEW space onto
// OBJECT space (transpose of the die's orientation), so pips are
// carved per-face from the object-space hit point and ride the tumble
// for free. quad coords quantize to u_cells - one exact ray per cell,
// razor-sharp blocks, never averaged (the house pixelation rule).
//
varying vec2 v_pos;

uniform vec4  u_quad;  // quad x, y, w, h in room px
uniform vec3  u_or[3]; // object-from-view rotation rows
uniform vec3  u_light; // direction TO the light, view space
uniform vec3  u_col;   // body tint 0..1
uniform vec3  u_ink;   // pip color (gml picks black/white by contrast)
uniform float u_metal; // finish: 0 = matte, 1 = metallic
uniform float u_iri;   // iridescence 0..1 (pearl, oil, opal). 0 = off,
                       // and off is bit-identical to before it existed
uniform float u_pad;   // quad half-extent in die half-extents
uniform float u_cells; // pixel cells across the quad. 0 = off
// THE ROOM'S LIGHT (syst_scene_light, 2026-09-11): the screen around
// the die, blurred at two widths, read along the normal and added as
// ambient - the field's colour on the faces. u_scene_amt 0 = off
uniform sampler2D u_scene;    // tight (reflection)
uniform sampler2D u_scene2;   // wide (ambient wash)
uniform vec2  u_scene_uv;     // room px -> uv
uniform float u_scene_amt;

const float RD = 0.17; // edge rounding (die half-extent = 1)

// ⚖️ IRIDESCENCE, added for the material roster (2026-09-09). The
// matte<->metal slide had no vocabulary for pearl: pearl is not a
// duller metal, it is a surface whose HUE depends on the angle you see
// it from, and no amount of u_metal produces that.
//
// This is the cheap film approximation, not a real thin-film integral:
// sweep a hue by the facing term and hand it back as a colour. Three
// cosines 120 degrees apart is the standard trick and it costs almost
// nothing. The point is not physical accuracy - it is that turning the
// die changes its colour, which is the entire read of a pearl.
vec3 iri_hue(float t)
{
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

float sd_die(vec3 p)
{
    vec3 q = abs(p) - vec3(1.0 - RD);
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - RD;
}

float pip(vec2 f, float cx, float cy)
{
    return step(length(f - vec2(cx, cy)), 0.235);
}

// standard western d6: 1-6, 2-5, 3-4 share opposite faces (sum 7)
float pips(float v, vec2 f)
{
    float g = 0.52;
    float m = 0.0;
    if (v < 1.5) {
        m = pip(f, 0.0, 0.0);
    }
    else if (v < 2.5) {
        m = max(pip(f, -g, -g), pip(f, g, g));
    }
    else if (v < 3.5) {
        m = max(pip(f, 0.0, 0.0), max(pip(f, -g, -g), pip(f, g, g)));
    }
    else if (v < 4.5) {
        m = max(max(pip(f, -g, -g), pip(f, g, g)),
                max(pip(f, -g,  g), pip(f, g, -g)));
    }
    else if (v < 5.5) {
        m = max(pip(f, 0.0, 0.0),
            max(max(pip(f, -g, -g), pip(f, g, g)),
                max(pip(f, -g,  g), pip(f, g, -g))));
    }
    else {
        m = max(max(pip(f, -g, -g), pip(f, g, g)),
                max(pip(f, -g,  g), pip(f, g, -g)));
        m = max(m, max(pip(f, -g, 0.0), pip(f, g, 0.0)));
    }
    return m;
}

void main()
{
    // quantize the QUAD COORDINATE, not the output: every cell casts
    // one ray, so the pixelation is native and razor sharp
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 s = (q * 2.0 - 1.0) * u_pad;

    // ---- THE ROOM'S LIGHT: five taps of each blurred copy around this
    // cell, read HERE - before the raymarch's early exit - because the
    // HLSL side forbids a texture read inside divergent flow. The
    // normal mixes them later: a face leaning left takes the left tap
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

    // orthographic ray, view space -> object space
    vec3 rov = vec3(s, 3.2);
    vec3 rdv = vec3(0.0, 0.0, -1.0);
    vec3 ro = vec3(dot(u_or[0], rov), dot(u_or[1], rov), dot(u_or[2], rov));
    vec3 rd = vec3(dot(u_or[0], rdv), dot(u_or[1], rdv), dot(u_or[2], rdv));

    float t = 1.3;
    float d = 1.0;
    for (int i = 0; i < 44; i++) {
        d = sd_die(ro + rd * t);
        if (d < 0.004 || t > 6.2) break;
        t += d;
    }
    if (d > 0.02) { gl_FragColor = vec4(0.0); return; }

    vec3 p = ro + rd * t;

    // tetrahedral normal, object space
    vec2 e = vec2(0.005, -0.005);
    vec3 n = normalize(
          vec3(e.x, e.y, e.y) * sd_die(p + vec3(e.x, e.y, e.y))
        + vec3(e.y, e.y, e.x) * sd_die(p + vec3(e.y, e.y, e.x))
        + vec3(e.y, e.x, e.y) * sd_die(p + vec3(e.y, e.x, e.y))
        + vec3(e.x, e.x, e.x) * sd_die(p + vec3(e.x, e.x, e.x)));

    // face id from the dominant normal axis; face-local coords are the
    // hit point's other two components
    vec3 an = abs(n);
    float v;
    vec2 f;
    if (an.x >= an.y && an.x >= an.z) { v = (n.x > 0.0) ? 3.0 : 4.0; f = p.yz; }
    else if (an.y >= an.z)            { v = (n.y > 0.0) ? 2.0 : 5.0; f = p.xz; }
    else                              { v = (n.z > 0.0) ? 1.0 : 6.0; f = p.xy; }
    float m = pips(v, f / (1.0 - RD));
    // pips live on the flat of the face only, never over the rounding
    m *= step(0.86, max(an.x, max(an.y, an.z)));

    // lighting in view space (u_or rows are O columns: O*n = sum below)
    // matte <-> metallic blend: metal drops the diffuse floor (metals
    // barely scatter), tightens and boosts the glint, and TINTS the
    // reflection with the body color the way real metal does
    vec3 nv = u_or[0] * n.x + u_or[1] * n.y + u_or[2] * n.z;
    float df = clamp(dot(nv, u_light), 0.0, 1.0);
    float dfw = mix(0.35 + 0.72 * df, 0.16 + 0.52 * df, u_metal);
    vec3 body = u_col * dfw;
    vec3 ink  = u_ink * (0.55 + 0.55 * df);
    vec3 col = mix(body, ink, m);

    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), nv);
    float sp = pow(clamp(dot(rf, u_light), 0.0, 1.0), mix(9.0, 36.0, u_metal));
    vec3 spc = mix(vec3(1.0), clamp(u_col * 1.2 + vec3(0.12), 0.0, 1.0), u_metal);
    // metals also pick up a cool sheen at grazing angles
    float fr = pow(1.0 - clamp(nv.z, 0.0, 1.0), 3.0);

    // the film: hue driven by how edge-on this pixel is, so the colour
    // travels across the die as it tumbles rather than sitting still on
    // it. Blended into the SPECULAR rather than the body, because that
    // is where a real film lives - a pearl's body stays pale and only
    // its sheen shifts.
    if (u_iri > 0.0) {
        vec3 ih = iri_hue(fr * 0.85 + df * 0.35);
        spc = mix(spc, ih, u_iri);
        // and a soft wash of it on the body, so the die reads coloured
        // even on the faces pointing straight at you
        col = mix(col, mix(col, ih * (0.45 + 0.55 * dfw), 0.35), u_iri);
    }

    col += spc * sp * mix(0.22, 0.95, u_metal) * (1.0 - m * 0.35);
    // ...and the rim, which iridescence rides hardest of all
    col += spc * fr * mix(0.22 * u_metal, 0.5, u_iri);

    // ---- the room's light, along the normal (the taps were read at
    // the top; a face turned left takes the left one) ----
    vec3 amb  = max(sw0 + swx * 0.5 * nv.x + swy * 0.5 * nv.y, 0.0);
    vec3 refl = max(st0 + stx * 0.5 * nv.x + sty * 0.5 * nv.y, 0.0);
    col += u_col * amb * u_scene_amt * 1.1 * (1.0 - m * 0.6);
    col += spc * refl * u_scene_amt * (0.5 * u_metal + 0.35 * fr);

    gl_FragColor = vec4(col, 1.0);
}
