//
// THE TUBE (his ask, 2026-09-10, first for the title screen; then "i
// like the CRT effect but am curious if we can use it and keep the
// vanilla brightness of all our pixels... put it in front of
// everything... add some settings"). syst_crt captures the application
// surface at its depth - over everything but the pointer, or behind
// the interface - and draws it back through this. Every knob is a
// uniform fed from settings > crt.
//
// ⚖️ BRIGHTNESS-NEUTRAL BY CONSTRUCTION (his ask: vanilla brightness).
// The first tube darkened the whole picture - a sine scanline profile
// that never reached 1 on any row, a phosphor tint that only ever
// took, a vignette, and an 8% gain to hide the loss. Now nothing here
// dims a pixel that is not IN a gap:
//   scanlines   a dark line at every ROOM-ROW boundary - the surface is
//               1920x1080, four rows to a room pixel, and the profile
//               (a cosine bump raised to the fourth) sits on the two
//               rows either side of a boundary and leaves the row's
//               middle untouched. The pixel keeps its brightness; the
//               gap is the gap
//   grille      the RGB stripe is NORMALISED: the column's own primary
//               is lifted by twice what the other two lose, so the
//               mean of every channel over three columns is exactly 1.
//               Texture, not a tint
//   vignette    OFF at 0 (its default) - it is the one knob that
//               darkens pixels on purpose, so it is his to turn up
//   gain        gone
//   bloom       ADDS light (his ask, 2026-09-10: "since its crt doesnt
//               it need a subtle bloom?"): u_blur is the frame SQUARED
//               and then blurred wide (syst_crt's bright pass through
//               blur_snap), added after the scanlines so the glow
//               fills the gaps the way halation in the glass does -
//               the bloom has no lines. Squared BEFORE the blur, not
//               after (his report: "bloom doesn't appear to do
//               anything" - the first cut blurred the plain frame and
//               squared the result, and a blurred line of white text
//               is a .2 that squares to nothing; squared first, the
//               text's energy is what spreads)
//   roll        a band drifting down the face every six seconds - a
//               lift the picture rides AND a faint additive glow, so
//               it shows on the dark field too - and a flicker of a
//               couple of percent (the first cut's 5%/1% were
//               invisible on a picture this dark)
//
// ⚖️ THE GRILLE IS FLAT (his report, 2026-09-10: "bowing lines in
// it... subtle but noticable"). It was computed on the WARPED
// coordinate, so the stripe pitch changed across the bulge - 3.0 px in
// the middle, 2.8 at the edges - and a stripe that is not a whole
// number of pixels beats against the pixel grid: moire, bowed with
// the glass. The mask sits on the front of the tube, not in the
// picture, so it reads the SCREEN coordinate - an exact 3px pitch
// everywhere. The scanlines keep the warp on purpose: they are the
// beam, and a beam bows with the face.
//
// ⚖️ THE GLASS IS PINNED TO THE FRAME. The title's first tube barrelled
// outward (cc = c x (1 + k r^2)) and let the corners fall off the
// glass into black - fine behind a wordmark, fatal over an interface
// whose corner buttons and counter live exactly there. This bulge is
// the other way round: the source is compressed in the MIDDLE
// (magnified to the eye) by k x (1-x^2)(1-y^2), which is 0 on every
// edge - so the frame stays where it is, nothing is cropped, and the
// scanlines still bow through the middle the way a curved face reads.
// The cost is honest: over the interface the picture in the middle
// sits a few room pixels from where its hit regions are (about 2px at
// the default, nothing at 0), which is why curvature is a slider.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_res;     // the surface, px
uniform vec2  u_room;    // the room, px (scanline count = u_room.y)
uniform float u_time;    // seconds
uniform float u_curve;   // 0..1  the bulge
uniform float u_scan;    // 0..1  gap darkness
uniform float u_grille;  // 0..1  stripe contrast
uniform float u_chroma;  // 0..1  red/blue split toward the edges
uniform float u_vig;     // 0..1  corner darkening
uniform float u_roll;    // 0/1   the drifting band and the flicker
uniform float u_bloom;   // halation strength (0 = u_blur unused)
uniform sampler2D u_blur;   // the frame squared then blurred wide (blur_snap's top link)

float hash11(float p) { return fract(sin(p * 127.1) * 43758.5453); }

void main()
{
    vec2 uv = v_vTexcoord;
    vec2 c = uv * 2.0 - 1.0;

    // ---- the glass: a bulge pinned to the frame ----
    float bulge = (1.0 - c.x * c.x) * (1.0 - c.y * c.y);
    vec2 cc = c * (1.0 - 0.06 * u_curve * bulge);
    vec2 suv = clamp(cc * 0.5 + 0.5, 0.0, 1.0);
    float r2 = dot(c, c);

    // ---- aberration: red and blue pulled apart toward the edges ----
    vec2 ab = (c / max(length(c), 0.001)) * r2 * 0.0025 * u_chroma;
    float rr = texture2D(gm_BaseTexture, clamp(suv + ab, 0.0, 1.0)).r;
    float gg = texture2D(gm_BaseTexture, suv).g;
    float bb = texture2D(gm_BaseTexture, clamp(suv - ab, 0.0, 1.0)).b;
    vec3 col = vec3(rr, gg, bb);

    // ---- scanlines: a gap at every room-row boundary ----
    float t = fract(suv.y * u_room.y);
    float bump = 0.5 + 0.5 * cos(t * 6.2831853);
    float gap = bump * bump * bump * bump;
    col *= 1.0 - 0.7 * u_scan * gap;

    // ---- the grille, normalised and FLAT (see the header) ----
    float px = floor(uv.x * u_res.x);
    float m = mod(px, 3.0);
    float s = 0.22 * u_grille;
    vec3 mask = vec3(1.0 - s);
    if (m < 0.5)      mask.r = 1.0 + 2.0 * s;
    else if (m < 1.5) mask.g = 1.0 + 2.0 * s;
    else              mask.b = 1.0 + 2.0 * s;
    col *= mask;

    // ---- the halation (sampled unconditionally: a gradient read
    // inside flow control is the one thing the HLSL side is picky
    // about; at u_bloom 0 the read costs a fetch and adds nothing) ----
    vec3 bl = texture2D(u_blur, suv).rgb;
    col += bl * u_bloom;

    // ---- the roll and the flicker ----
    float roll = fract(u_time * 0.17);
    float bd = (suv.y - roll) * 12.0;
    float band = exp(-bd * bd);
    col = col * (1.0 + 0.12 * u_roll * band) + vec3(0.035 * u_roll * band);
    col *= 1.0 + 0.045 * u_roll * (hash11(floor(u_time * 60.0)) - 0.5);

    // ---- the glass darkens at the corners, if asked ----
    col *= 1.0 - 0.5 * u_vig * r2 * r2;

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0) * v_vColour;
}
