//
// fog dither: interleaved gradient noise per screen pixel, RE-SEEDED
// EVERY FRAME. the whole gm pipeline is 8-bit (app surface + every fx
// layer pass), so a dark gradient this wide bands at every stage, and
// the fx layers re-quantize AFTER any static dither: temporal noise is
// what actually wins, the bands shimmer frame to frame and the eye
// integrates them flat.
// the noise divides by the fragment's alpha so it survives the sheet's
// low draw alpha: without that, alpha * noise rounds back to zero.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;

void main()
{
    vec4 c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);

    // REMASTERED: jimenez IGN, pattern re-seeded at 30hz (half the
    // shimmer of every-frame, same temporal averaging)
    vec2 p = floor(gl_FragCoord.xy)
        + fract(floor(u_time * 30.0) * vec2(0.7548776, 0.5698402)) * 64.0;
    float n = fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));

    // LUMINANCE-GATED amplitude (in final 8-bit levels, the alpha
    // compensation below cancels): zero on pure black - the night sky
    // stays untouched - ramping to ~1.4 levels by the time the fog
    // carries ~3 levels of signal. banding lives exactly in that dim
    // ramp; the dither now lives ONLY there too.
    float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114)) * c.a;
    float amp = min(lum * 255.0 * 0.5, 1.4);

    float a = max(c.a, 0.02);
    c.rgb += (n - 0.5) * (amp / 255.0) / a;

    gl_FragColor = c;
}
