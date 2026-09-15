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

// white noise, no lattice (Hoskins' hash12): the grain that reads as film
// grain, not the diagonal checkerboard interleaved-gradient noise makes
// on pixel cells (his report, 2026-09-15)
float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main()
{
    vec4 c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);

    // REMASTERED: jimenez IGN, pattern re-seeded at 30hz (half the
    // shimmer of every-frame, same temporal averaging)
    float fr = floor(u_time * 60.0);
    vec2 p = floor(gl_FragCoord.xy) + vec2(fr * 13.0, fr * 7.0);
    float n = hash12(p);   // (white grain, not the lattice)

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
