//
// TAP EFFECTS THAT BEND THE ROOM (his trial, 2026-09-10): the RIPPLE
// and the HOLD HEAT. syst_tapfx captures the application surface once
// a frame while either is live and draws the affected region back over
// itself through this: every fragment picks its source pixel from
// somewhere nearby, so the room under the tap appears to move.
//
// ⚖️ PIXEL-NATIVE, the house rule two ways: the displacement is
// evaluated once per ROOM CELL (the fragment's room coordinate is
// floored) and it is a WHOLE number of cells, so the ring shoves blocks
// of the room by blocks - never a smooth smear across a pixel game.
//
//   ripple    a crest running out from the tap: outward push on the
//             ring, a brightness lift on its crest, both fading with
//             the ring's amplitude
//   hold heat a shimmer around the held finger: a hashed wobble of one
//             or two cells that jitters each frame, scaled by heat
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_room;       // room size in px (the surface maps it 1:1)
uniform float u_n;          // live rings, 0..8
uniform vec4  u_ring[8];    // x, y (room px), radius (px), amplitude (px)
uniform vec4  u_haze;       // x, y (room px), radius, heat 0..1
uniform float u_time;

float hash21(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main()
{
    vec2 rp = floor(v_vTexcoord * u_room) + 0.5;   // the cell's centre, room px
    vec2 off = vec2(0.0);
    float lift = 0.0;

    // ---- the rings ----
    int n = int(u_n + 0.5);
    for (int i = 0; i < 8; i++) {
        if (i >= n) break;
        vec4 r = u_ring[i];
        vec2 d = rp - r.xy;
        float dd = length(d);
        if (dd < 0.001) continue;
        float w = exp(-pow((dd - r.z) / 4.0, 2.0));       // the crest's width
        float crest = cos((dd - r.z) * 0.9);               // push out ahead, pull behind
        off += (d / dd) * r.w * w * crest;
        lift += w * r.w * 0.16;
    }

    // ---- the haze ----
    if (u_haze.w > 0.001) {
        float dd = length(rp - u_haze.xy);
        float fall = 1.0 - smoothstep(u_haze.z * 0.4, u_haze.z, dd);
        if (fall > 0.0) {
            vec2 cell = floor(rp / 3.0);                    // one wobble per 3x3 cells
            float t = floor(u_time * 12.0);                 // twelve jitters a second
            float a = hash21(cell + t) - 0.5;
            float b = hash21(cell + t + 17.0) - 0.5;
            off += vec2(a, b) * 3.2 * u_haze.w * fall;
        }
    }

    // whole cells, then the source sample from the displaced cell
    off = floor(off + 0.5);
    vec2 src = (rp + off) / u_room;
    src = clamp(src, vec2(0.0), vec2(1.0));
    vec4 c = texture2D(gm_BaseTexture, src);
    c.rgb += vec3(lift);
    gl_FragColor = vec4(clamp(c.rgb, 0.0, 1.0), 1.0) * v_vColour;
}
