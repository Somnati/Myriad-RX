//
// THE TITLE'S TUBE (his ask, 2026-09-10): the title screen's background
// - the field, the halo, the glow pass, the gradient - seen through a
// CRT. syst_titlescreen captures the application surface at depth 20
// (everything deeper has drawn; the wordmark, the menu and the save
// card come after and stay crisp) and draws it back through this.
//
// What a tube does, in order:
//   curvature   a mild barrel: the picture bows out at the middle and
//               the corners fall off the glass (black past the edge).
//               This is the one place the house rule against
//               resampling is set aside - the softness IS the look,
//               and it never leaves the title screen
//   scanlines   one dark line per ROOM pixel row - 270 lines, which is
//               the tube this resolution would have had. The surface is
//               1920x1080, four rows to a room pixel, so the line is a
//               real gap between rows rather than a stripe painted on
//   phosphor    an RGB stripe mask at surface resolution, every third
//               column favouring one primary - sub-room-pixel, so it
//               reads as texture rather than as colour
//   aberration  red and blue pulled apart a hair toward the edges,
//               where a lens is worst
//   vignette    the glass darkens toward the corners
//   roll        a faint bright band drifting down every few seconds,
//               and a breath of flicker
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_res;    // the surface, px
uniform vec2  u_room;   // the room, px (scanline count = u_room.y)
uniform float u_time;   // seconds
uniform float u_amt;    // 0..1, the whole effect's strength

float hash11(float p) { return fract(sin(p * 127.1) * 43758.5453); }

void main()
{
    vec2 uv = v_vTexcoord;

    // ---- curvature ----
    vec2 c = uv * 2.0 - 1.0;
    float r2 = dot(c, c);
    vec2 cc = c * (1.0 + 0.045 * u_amt * r2);
    vec2 suv = cc * 0.5 + 0.5;
    if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // ---- aberration: red and blue pulled apart toward the edges ----
    vec2 ab = (cc / max(length(cc), 0.001)) * r2 * 0.0018 * u_amt;
    float rr = texture2D(gm_BaseTexture, clamp(suv + ab, 0.0, 1.0)).r;
    float gg = texture2D(gm_BaseTexture, suv).g;
    float bb = texture2D(gm_BaseTexture, clamp(suv - ab, 0.0, 1.0)).b;
    vec3 col = vec3(rr, gg, bb);

    // ---- scanlines: one per room row ----
    float line = 0.5 + 0.5 * sin(suv.y * u_room.y * 6.2831853 - 1.5707963);
    col *= 1.0 - 0.28 * u_amt * (1.0 - line);

    // ---- phosphor stripe, at surface resolution ----
    float px = floor(suv.x * u_res.x);
    float m = mod(px, 3.0);
    vec3 mask = vec3(1.0);
    if (m < 0.5)      mask = vec3(1.0, 0.86, 0.86);
    else if (m < 1.5) mask = vec3(0.86, 1.0, 0.86);
    else              mask = vec3(0.86, 0.86, 1.0);
    col *= mix(vec3(1.0), mask, u_amt);

    // ---- the roll and the flicker ----
    float roll = fract(u_time * 0.11);
    float band = exp(-pow((suv.y - roll) * 9.0, 2.0));
    col *= 1.0 + 0.05 * u_amt * band;
    col *= 1.0 + 0.012 * u_amt * (hash11(floor(u_time * 60.0)) - 0.5);

    // ---- the glass darkens at the corners, and a touch of gain ----
    float vig = 1.0 - 0.32 * u_amt * r2 * r2;
    col *= vig * (1.0 + 0.08 * u_amt);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0) * v_vColour;
}
