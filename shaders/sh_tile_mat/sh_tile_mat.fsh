//
// sh_tile_mat - A TILE'S SURFACE (his ask, 2026-09-13: "unique shader
// patterns that move... one that has a pattern that doesn't move with
// the tile... liquidy watery surface... a hole that has parallax depth").
// One quad = one tile body; one cell per room pixel (the house
// pixelation rule: quantize the position, never average). The quad is
// spr_tile's rounded slab (or a stretched white pixel) - its alpha is
// the outline, sampled nearest so every fragment of a cell reads the
// one texel under it. The number draws over everything.
//
// ⚖️ THE COLOUR LAW (his rule: "maintain the vanilla color output... i
// don't want a shader affecting the overall brightness"). Every
// material is the body colour times (1 + amp x d) where d is a
// posterized pattern in -1..1 whose MEAN, over the tile and over time,
// is zero. Multiplicative, so hue and saturation are untouched cell by
// cell; zero-mean, so the tile's average colour is exactly the colour
// it was handed. The body arrives already darkened (the board draws it
// at 30% of the rung colour), so there is headroom for the crests and
// nothing ever clamps. datafiles/tilemat_twin.py ports every material
// and measures its mean; it must print HOLDS.
//
// ONE MATERIAL PER TIER (his call, 2026-09-13: "the shaders should be
// tied to the tier") - tile_mat_config is the ladder. u_kind:
//    1 sheen    WORLD  one diagonal wave crosses the whole board every
//                      twelve seconds, a bright band then a dark one
//    2 liquid   WORLD  two octaves of drifting noise, three tones -
//                      drag the tile and the water stays put
//    3 hole     TILE   a lit surface band round a dark mouth, the floor
//                      darkest, and the floor SHIFTS toward the eye by
//                      depth (parallax) so the far wall shows: right of
//                      centre you see the right wall, and moving the
//                      tile slides the floor under the lip
//    4 stars    WORLD  two depths of hashed stars drifting under the mask
//    5 bands    WORLD  scanlines: every fourth row lit, the second dark,
//                      rolling down
//    6 stripes  WORLD  a barber pole of diagonal stripes
//    7 lattice  WORLD  two families of diagonal lines drifting, a mesh
//    8 ripple   TILE   rings spreading from the tile's centre
//    9 ember    WORLD  fine noise rising fast, the liquid's hot cousin
//   10 orbit    TILE   a bright mote circling the rim, its dark twin
//                      opposite
//   11 pulse    TILE   the whole tile breathes, three tones over time
//   12 static   TILE   television snow: a fresh scatter twelve times a
//                      second, as many dark cells as bright
//   13 aurora   WORLD  tall curtains of light drifting sideways
//
varying vec2 v_pos;
varying vec2 v_uv;

uniform vec4  u_quad;   // the body rect x, y, w, h in room px
uniform float u_kind;
uniform vec3  u_col;    // the body colour 0..1 (already the board's darkened one)
uniform float u_alpha;
uniform float u_time;   // seconds
uniform float u_amp;    // the modulation depth, TILE_MAT_AMP
uniform vec2  u_view;   // the eye, room px (the room's centre) - the hole's parallax
uniform float u_par;    // the hole's floor shift per px from the eye
uniform float u_seed;   // per tile phase

// (sh_planet's hash: small multipliers, so room-pixel inputs keep their
// fraction on a mediump float)
float hash21(vec2 p)
{
    vec3 p3 = fract(vec3(p.x, p.y, p.x) * 0.1031);
    p3 += dot(p3, vec3(p3.y, p3.z, p3.x) + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// three tones about zero: crest past +th, trough past -th, else the body
float tones(float n, float th)
{
    return (n > th) ? 1.0 : ((n < -th) ? -1.0 : 0.0);
}

void main()
{
    // one cell per room pixel, sampled at its centre
    vec2 cell = floor(v_pos - u_quad.xy);
    vec2 p  = u_quad.xy + cell + 0.5;             // room px: the WORLD anchor
    vec2 hw = u_quad.zw * 0.5;
    vec2 q  = cell + 0.5 - hw;                    // px from the tile's centre
    float t = u_time;
    float d = 0.0;
    int k = int(u_kind + 0.5);

    if (k == 1) {
        // SHEEN: a wave down the diagonal, wavelength 480 px, 40 px/s
        float w  = dot(p, normalize(vec2(1.0, 0.6)));
        float ph = fract((w - t * 40.0) / 480.0);
        d = (ph < 0.05) ? 1.0 : ((ph < 0.10) ? -1.0 : 0.0);
    }
    else if (k == 2) {
        // LIQUID: two octaves, drifting against each other
        float n = vnoise(p * 0.11 + vec2(t * 0.35, t * 0.20) + u_seed) * 0.65
                + vnoise(p * 0.23 + vec2(-t * 0.25, t * 0.30) + u_seed * 3.0) * 0.35;
        d = tones((n - 0.5) * 2.0, 0.22);
    }
    else if (k == 3) {
        // HOLE. The tile's outer two px are the SURFACE, lit (+0.7); inside
        // is the mouth. The floor sits at depth 1 and shifts toward the eye
        // - plus a fixed nudge up-left, so even a tile at dead centre shows
        // its lower-right wall, the way an inset reads under a lamp. What
        // the shift uncovers between lip and floor is the far WALL (-0.35);
        // the floor is the dark of the hole (-1) with a scatter of grain.
        // The mean is zeroed from the areas, so any tile size balances
        vec2 c   = u_quad.xy + hw;
        vec2 sh  = -(c - u_view) * u_par - vec2(1.5, 1.5);
        vec2 mh  = hw - vec2(2.0, 2.0);           // the mouth's half size
        bool srf = (abs(q.x) >= mh.x) || (abs(q.y) >= mh.y);
        vec2 qf  = q - sh;
        vec2 fh  = mh - vec2(1.0, 1.0);           // the floor, a px inside the mouth, before the shift
        bool flr = (abs(qf.x) < fh.x) && (abs(qf.y) < fh.y);
        float grain = (hash21(floor(qf) + u_seed) > 0.82) ? -0.55 : -1.0;
        d = srf ? 0.7 : (flr ? grain : -0.35);
        // (the floor's area is what the shift leaves inside the mouth)
        float W = u_quad.z, H = u_quad.w;
        float A  = W * H;
        float fs = (A - (W - 4.0) * (H - 4.0)) / A;
        float ow = max(0.0, min(sh.x + fh.x, mh.x) - max(sh.x - fh.x, -mh.x));
        float oh = max(0.0, min(sh.y + fh.y, mh.y) - max(sh.y - fh.y, -mh.y));
        float ff = ow * oh / A;
        float fw = 1.0 - fs - ff;
        float bias = fs * 0.7 + ff * (0.82 * -1.0 + 0.18 * -0.55) + fw * -0.35;
        d -= bias;
    }
    else if (k == 4) {
        // STARS: two depths, drifting; the field pays the stars back
        vec2 p1 = p + vec2(t * 2.0, 0.0);
        vec2 p2 = p * 0.5 + vec2(t * 0.7, 0.0);
        float s = 0.0;
        if (hash21(floor(p1)) > 0.965) s = 1.0;
        if (hash21(floor(p2) + 7.0) > 0.975) s = 1.0;
        d = (s > 0.5) ? 1.0 : -0.064;
    }
    else if (k == 5) {
        // BANDS: rows rolling down, one in four lit, one in four dark
        float r = floor(p.y - t * 4.0);
        float m = mod(r, 4.0);
        d = (m < 0.5) ? 0.8 : ((m > 1.5 && m < 2.5) ? -0.8 : 0.0);
    }
    else if (k == 6) {
        // STRIPES: a barber pole, four px stripes on the diagonal
        float s = floor((p.x + p.y - t * 20.0) / 4.0);
        d = (mod(s, 2.0) < 0.5) ? 0.5 : -0.5;
    }
    else if (k == 7) {
        // LATTICE: two diagonal line families drifting apart; the mesh is
        // about a quarter of the cells, and the cells between pay for it
        float a = mod(p.x + p.y - t * 6.0, 8.0);
        float b = mod(p.x - p.y + t * 6.0, 8.0);
        bool on = (a < 1.0) || (b < 1.0);
        d = on ? 1.0 : -0.31;
    }
    else if (k == 8) {
        // RIPPLE: rings from the centre, the ellipse of the tile's aspect
        float r  = length(vec2(q.x, q.y * (hw.x / hw.y)));
        float ph = fract(r / 6.0 - t * 0.6 + u_seed);
        d = (ph < 0.25) ? 1.0 : ((ph < 0.5) ? -1.0 : 0.0);
    }
    else if (k == 9) {
        // EMBER: finer, faster, rising
        float n = vnoise(p * 0.2 + vec2(t * 0.4, t * 1.3) + u_seed) * 0.6
                + vnoise(p * 0.45 + vec2(-t * 0.5, t * 1.9) + u_seed * 3.0) * 0.4;
        d = tones((n - 0.5) * 2.0, 0.18);
    }
    else if (k == 10) {
        // ORBIT: a 2x2 mote circling the rim, its dark twin opposite
        float a  = t * 2.2 + u_seed;
        vec2 rr  = hw - vec2(3.0, 3.0);
        vec2 m1  = vec2(cos(a), sin(a)) * rr;
        vec2 m2  = -m1;
        vec2 d1  = abs(q - m1);
        vec2 d2  = abs(q - m2);
        if (d1.x < 1.0 && d1.y < 1.0) d = 1.0;
        else if (d2.x < 1.0 && d2.y < 1.0) d = -1.0;
    }
    else if (k == 11) {
        // PULSE: the whole tile breathes, three tones over time
        d = tones(sin(t * 2.0 + u_seed), 0.45) * 0.6;
    }
    else if (k == 12) {
        // STATIC: a fresh scatter twelve times a second
        float h = hash21(cell + floor(t * 12.0) * 13.7 + u_seed);
        d = (h > 0.86) ? 1.0 : ((h < 0.14) ? -1.0 : 0.0);
    }
    else if (k == 13) {
        // AURORA: tall curtains, drifting sideways
        float n = vnoise(vec2(p.x * 0.08 + t * 0.30, p.y * 0.02 + t * 0.15) + u_seed) * 0.7
                + vnoise(vec2(p.x * 0.17 - t * 0.22, p.y * 0.04) + u_seed * 3.0) * 0.3;
        d = tones((n - 0.5) * 2.0, 0.2);
    }

    // THE SPRITE IS THE MASK: the quad's alpha is the outline, its white
    // the body (nearest-sampled: one texel per cell)
    vec4 tex = texture2D(gm_BaseTexture, v_uv);
    vec3 col = tex.rgb * u_col * (1.0 + u_amp * d);
    gl_FragColor = vec4(col, tex.a * u_alpha);
}
