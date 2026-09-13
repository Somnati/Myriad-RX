//
// sh_tile_mat - A TILE'S SURFACE (his ask, 2026-09-13: "unique shader
// patterns that move... one that has a pattern that doesn't move with
// the tile... liquidy watery surface... a hole that has parallax depth").
// One quad = one tile body; one cell per room pixel (the house
// pixelation rule: quantize the position, never average). The rims,
// studs and pips of the accretion scheme draw OVER this on the CPU; the
// number draws over everything.
//
// ⚖️ THE COLOUR LAW (his rule: "maintain the vanilla color output... i
// don't want a shader affecting the overall brightness"). Every
// material is the body colour times (1 + amp x d) where d is a
// posterized pattern in -1..1 whose MEAN, over the tile and over time,
// is zero. Multiplicative, so hue and saturation are untouched cell by
// cell; zero-mean, so the tile's average colour is exactly the colour
// it was handed. The body arrives already darkened (the board draws it
// at 30% of the rung colour), so there is headroom for the crests and
// nothing ever clamps. datafiles/tilemat_twin.py measures every
// material's mean and must print HOLDS.
//
// u_kind: 1 sheen, 2 liquid, 3 hole, 4 stars (0 = flat, never sent)
//   sheen   WORLD-ANCHORED: one diagonal wave crosses the whole board
//           every twelve seconds - a bright band followed by a dark
//           band of the same width, so a period integrates to zero.
//           Every sheen tile on the board is crossed in the same sweep
//   liquid  WORLD-ANCHORED: two octaves of value noise drifting,
//           posterized to three tones about the body. Drag a tile and
//           the water stays where it was - the tile is a window on it
//   hole    TILE-ANCHORED with PARALLAX: a lit rim, dark walls, a
//           floor - and the floor shifts toward the room's centre by
//           depth, so a tile right of centre shows its far (right)
//           wall, and moving it slides the floor under the rim: you
//           are looking down into it. The floor carries a still,
//           hashed grain so it does not read as a raised plate
//   stars   WORLD-ANCHORED: two depths of hashed stars drifting at two
//           speeds under the mask, the field paying the stars back
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
uniform float u_seed;   // per tile, so two liquids are not the same liquid

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

void main()
{
    // one cell per room pixel, sampled at its centre
    vec2 cell = floor(v_pos - u_quad.xy);
    vec2 p = u_quad.xy + cell + 0.5;              // room px: the WORLD anchor
    vec2 q = cell + 0.5 - u_quad.zw * 0.5;        // px from the tile's centre
    float d = 0.0;

    if (u_kind < 1.5) {
        // SHEEN: a wave down the diagonal, wavelength 480 px, 40 px/s
        float w  = dot(p, normalize(vec2(1.0, 0.6)));
        float ph = fract((w - u_time * 40.0) / 480.0);
        d = (ph < 0.05) ? 1.0 : ((ph < 0.10) ? -1.0 : 0.0);
    }
    else if (u_kind < 2.5) {
        // LIQUID: two octaves, drifting against each other, three tones
        float n = vnoise(p * 0.11 + vec2(u_time * 0.35, u_time * 0.20) + u_seed) * 0.65
                + vnoise(p * 0.23 + vec2(-u_time * 0.25, u_time * 0.30) + u_seed * 3.0) * 0.35;
        n = (n - 0.5) * 2.0;
        d = (n > 0.22) ? 1.0 : ((n < -0.22) ? -1.0 : 0.0);
    }
    else if (u_kind < 3.5) {
        // HOLE: rim +1 (depth 0), walls -1, floor +0.4 (depth 1, shifted
        // toward the eye by parallax). The mean is zeroed by the areas:
        // the fractions derive from the quad, so any tile size balances
        vec2 hw = u_quad.zw * 0.5;
        vec2 c  = u_quad.xy + hw;
        vec2 sh = -(c - u_view) * u_par;          // the floor's shift, toward the eye
        bool rim = (abs(q.x) > hw.x - 1.0) || (abs(q.y) > hw.y - 1.0);
        vec2 qf = q - sh;
        vec2 fh = hw - vec2(3.0, 3.0);            // floor half size: rim 1 + wall 2
        bool flr = (abs(qf.x) < fh.x) && (abs(qf.y) < fh.y);
        float tone_f = (hash21(floor(qf) + u_seed) > 0.85) ? -0.2 : 0.4;   // the floor's grain
        d = rim ? 1.0 : (flr ? tone_f : -1.0);
        // the balance: rim, floor, wall fractions of the quad's area
        float W = u_quad.z, H = u_quad.w;
        float A  = W * H;
        float fr = (A - (W - 2.0) * (H - 2.0)) / A;
        float ff = max(0.0, (W - 6.0) * (H - 6.0)) / A;
        float fw = 1.0 - fr - ff;
        float bias = fr * 1.0 + ff * (0.85 * 0.4 - 0.15 * 0.2) - fw * 1.0;
        d -= bias;
    }
    else {
        // STARS: two depths, drifting; the field pays the stars back
        vec2 p1 = p + vec2(u_time * 2.0, 0.0);
        vec2 p2 = p * 0.5 + vec2(u_time * 0.7, 0.0);
        float s = 0.0;
        if (hash21(floor(p1)) > 0.965) s = 1.0;
        if (hash21(floor(p2) + 7.0) > 0.975) s = 1.0;
        d = (s > 0.5) ? 1.0 : -0.064;
    }

    // THE SPRITE IS THE MASK: the quad is spr_tile's rounded slab (or a
    // stretched white pixel for the plain rectangle) - its alpha is the
    // outline, its white the body. Nearest-sampled, so every fragment of
    // a cell reads the one texel under it
    vec4 tex = texture2D(gm_BaseTexture, v_uv);
    vec3 col = tex.rgb * u_col * (1.0 + u_amp * d);
    gl_FragColor = vec4(col, tex.a * u_alpha);
}
