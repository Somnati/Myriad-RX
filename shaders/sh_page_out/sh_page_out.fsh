//
// sh_page_out - THE ONE DITHER (2026-09-15): a float page surface meets
// 8-bit exactly once, here, at the blit to the screen. Uniform noise of
// half a level either way (u_amp levels peak to peak) on the render's
// pixel cells (u_cell window px), jimenez IGN re-seeded at 30hz. Exact
// black stays black (noise under half a level never rounds up), so the
// night sky is untouched without a luminance gate.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_cell;
uniform float u_amp;

void main()
{
    vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
    vec2 p = floor(gl_FragCoord.xy / max(u_cell, 1.0))
        + fract(floor(u_time * 30.0) * vec2(0.7548776, 0.5698402)) * 64.0;
    float n = fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
    c.rgb += (n - 0.5) * (u_amp / 255.0);
    gl_FragColor = vec4(max(c.rgb, vec3(0.0)), c.a) * v_vColour;
}
