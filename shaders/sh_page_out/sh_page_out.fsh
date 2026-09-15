//
// sh_page_out - THE ONE DITHER (2026-09-15): a float page surface meets
// 8-bit exactly once, here, at the blit to the screen. Two looks (his
// call, settings > visuals > "page dither"):
//   u_mode 0  FILM GRAIN - white noise (hash12, no lattice), triangular
//             (two hashes summed: the grain's level is the same everywhere),
//             u_amp levels either way, a fresh grain every frame
//   u_mode 1  THE OLD-SCHOOL ORDERED DITHER - an 8x8 Bayer threshold,
//             static, on the render's pixel cells; u_levels steps a
//             channel (255 = every 8-bit level, the crosshatch only shows
//             where a gradient steps; 15 / 7 = retro / chunky, the gradients
//             posterised into the pattern - the image he sent)
// Both on the render's pixel cells (u_cell window px). Exact black stays black.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_cell;
uniform float u_amp;
uniform float u_mode;
uniform float u_levels;

// white noise, no lattice (Hoskins' hash12): the grain that reads as film
// grain, not the diagonal checkerboard interleaved-gradient noise makes
// on pixel cells (his report, 2026-09-15)
float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// the Bayer matrices, built up from the 2x2 (0 .5 / .75 .25)
float bayer2(vec2 a) { a = floor(a); return fract(a.x / 2.0 + a.y * a.y * 0.75); }
float bayer4(vec2 a) { return bayer2(0.5 * a) * 0.25 + bayer2(a); }
float bayer8(vec2 a) { return bayer4(0.5 * a) * 0.25 + bayer2(a); }

void main()
{
    vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
    vec2 p = floor(gl_FragCoord.xy / max(u_cell, 1.0));
    if (u_mode < 0.5) {
        float fr = floor(u_time * 60.0);
        vec2 q = p + vec2(fr * 13.0, fr * 7.0);
        float n = hash12(q) + hash12(q + vec2(101.0, 57.0)) - 1.0;   // -1..1, triangular
        c.rgb += n * (u_amp / 255.0);
    } else {
        float t = bayer8(p);                                          // 0..1, this cell's threshold
        float L = max(u_levels, 1.0);
        c.rgb = floor(c.rgb * L + t) / L;                             // posterised through the pattern
    }
    gl_FragColor = vec4(clamp(c.rgb, 0.0, 1.0), c.a) * v_vColour;
}
