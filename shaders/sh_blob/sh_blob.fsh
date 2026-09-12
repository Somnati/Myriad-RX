//
// A SPRITE'S BODY (his ask, 2026-09-11: "different eyes and colors and
// maybe even shaders/materials"). A raycast sphere seen straight on -
// the cheapest raycast there is: one ray per ROOM-PIXEL CELL (the
// house rule: quantise the quad coordinate, one exact sample, never
// averaged), a ray-sphere hit is p.x^2 + p.y^2 <= 1, the normal is
// (p, sqrt(1 - r^2)). A body is a dozen cells across, so twenty of
// them cost less than one dial row - his performance question.
//
// The quad is square; u_sq is the body's extent inside it (x, y), so a
// squash is two numbers and the sphere becomes the ellipsoid the pixel
// blob was. Four materials on one uniform:
//   0 matte   lambert + a soft rim - the pixel blob's look, lit
//   1 glass   his inspiration: a bubble - dark interior grading from
//             u_col2 (top) to u_col (bottom), a bright fresnel RING at
//             the rim in the body colour, two glints, a touch of
//             translucency at the centre
//   2 metal   dark base, a hard specular, the rim in the body colour
//   3 jelly   translucent, the shading wobbles slowly (u_time), a soft
//             glint
//   4 opal    the glass with an iridescent film on its rim: the hue
//             travels with the fresnel and the light, so the colour
//             moves across the body as it turns and the room moves -
//             the divine and ultimate rungs
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;    // x, y, w, h in room px (square)
uniform float u_cells;   // cells across the quad - one per room px
uniform vec3  u_col;     // the body
uniform vec3  u_col2;    // the second colour (glass top, jelly depth)
uniform float u_mat;     // 0 matte, 1 glass, 2 metal, 3 jelly, 4 opal
uniform vec3  u_light;   // the dice's light
uniform vec2  u_sq;      // the body's half-extent inside the quad, 0..1 each
uniform float u_time;
// THE ROOM'S LIGHT (syst_scene_light, 2026-09-11) - see sh_dice
uniform sampler2D u_scene;
uniform sampler2D u_scene2;
uniform vec2  u_scene_uv;
uniform float u_scene_amt;

void main()
{
    vec2 uv = (v_pos - u_quad.xy) / u_quad.zw;
    vec2 cell = (floor(uv * u_cells) + 0.5) / u_cells;
    vec2 p = (cell * 2.0 - 1.0) / max(u_sq, vec2(0.05));
    vec2 q = cell;
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
    vec3 swx = texture2D(u_scene2, clamp((spos + vec2( 12.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene2, clamp((spos + vec2(-12.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 swy = texture2D(u_scene2, clamp((spos + vec2(0.0,  12.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene2, clamp((spos + vec2(0.0, -12.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 st0 = texture2D(u_scene,  clamp( spos                     * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 stx = texture2D(u_scene,  clamp((spos + vec2( 5.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene,  clamp((spos + vec2(-5.0, 0.0)) * u_scene_uv, 0.0, 1.0)).rgb;
    vec3 sty = texture2D(u_scene,  clamp((spos + vec2(0.0,  5.0)) * u_scene_uv, 0.0, 1.0)).rgb
             - texture2D(u_scene,  clamp((spos + vec2(0.0, -5.0)) * u_scene_uv, 0.0, 1.0)).rgb;

    float r2 = dot(p, p);
    if (r2 > 1.0) discard;
    float z = sqrt(1.0 - r2);
    // y-DOWN, like the dice's view space - the shared light (-.42, -.62,
    // .66) is from the upper left in that frame (the first cut flipped
    // y and lit the blob from below)
    vec3 n = normalize(vec3(p.x, p.y, z));
    vec3 L = normalize(u_light);
    float dif = max(dot(n, L), 0.0);
    vec3 H = normalize(L + vec3(0.0, 0.0, 1.0));
    float spec = pow(max(dot(n, H), 0.0), 24.0);
    float fres = pow(1.0 - z, 2.5);
    vec3 glint2 = normalize(vec3(-0.5, 0.6, 0.6));

    vec3 col;
    float a = 1.0;
    if (u_mat < 0.5) {
        col = u_col * (0.40 + 0.60 * dif) + vec3(0.10) * fres;
    } else if (u_mat < 1.5) {
        float dep = 1.0 - z;
        vec3 inner = mix(u_col2, u_col, clamp(0.5 + p.y * 0.5, 0.0, 1.0));
        col  = inner * (0.16 + 0.30 * dif) * (0.55 + 0.45 * dep);
        col += u_col * 0.95 * pow(fres, 1.2);
        col += vec3(0.85) * pow(spec, 2.0) * 0.6;
        col += mix(u_col, vec3(1.0), 0.4) * pow(max(dot(n, glint2), 0.0), 40.0) * 0.5;
        a = 0.86 + 0.14 * dep;
    } else if (u_mat < 2.5) {
        col = u_col * (0.12 + 0.45 * dif) + vec3(1.0) * spec * 0.8 + u_col * 0.5 * fres;
    } else if (u_mat > 3.5) {
        float dep = 1.0 - z;
        vec3 inner = mix(u_col2, u_col, clamp(0.5 + p.y * 0.5, 0.0, 1.0));
        col  = inner * (0.14 + 0.26 * dif) * (0.55 + 0.45 * dep);
        // the film: a hue from how edge-on this cell is and the light
        float hue = fract(fres * 1.4 + dif * 0.35 + u_time * 0.06);
        vec3 film = 0.5 + 0.5 * cos(6.2831853 * (hue + vec3(0.0, 0.33, 0.67)));
        col += film * pow(fres, 1.1) * 0.95;
        col += mix(film, vec3(1.0), 0.5) * pow(spec, 2.0) * 0.6;
        a = 0.88 + 0.12 * dep;
    } else {
        float wob = sin(u_time * 2.0 + p.x * 3.0) * 0.5 + sin(u_time * 1.4 + p.y * 4.0) * 0.5;
        vec3 nw = normalize(vec3(p.x + wob * 0.08, p.y, z));
        float d2 = max(dot(nw, L), 0.0);
        col = mix(u_col2, u_col, z) * (0.35 + 0.55 * d2) + vec3(0.6) * pow(spec, 1.5) * 0.35 + u_col * 0.3 * fres;
        a = 0.88;
    }
    // ---- the room's light, along the normal: glass and metal reflect
    // the tight copy (the rim most of all), matte and jelly take the
    // wide wash on their colour (the taps were read at the top) ----
    vec3 amb  = max(sw0 + swx * 0.5 * n.x + swy * 0.5 * n.y, 0.0);
    vec3 refl = max(st0 + stx * 0.5 * n.x + sty * 0.5 * n.y, 0.0);
    if (u_mat < 0.5)      col += u_col * amb * u_scene_amt * 1.2;
    else if (u_mat < 1.5) col += refl * u_scene_amt * (0.45 + 0.75 * fres) + amb * u_scene_amt * 0.3;
    else if (u_mat < 2.5) col += refl * u_scene_amt * (0.6 + 0.5 * fres) * mix(vec3(1.0), u_col, 0.5);
    else if (u_mat > 3.5) col += refl * u_scene_amt * (0.4 + 0.7 * fres) + amb * u_scene_amt * 0.3;
    else                  col += mix(u_col2, u_col, z) * amb * u_scene_amt * 1.0 + refl * u_scene_amt * 0.2;

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), a * keep);
}
