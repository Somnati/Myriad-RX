//
// the galaxy map's nebula fog, PROCEDURAL (his report, 2026-09-16: the
// nebulae came out circular - the density sheet is 64 cells of blurred
// star counts drawn bilinear, so every cloud was a round blob). the sheet
// (galaxy_neb_sheet) stays the WHERE: its alpha the density, its rgb the
// warm-core / cool-rim colour. this carves the HOW: the sheet is sampled
// through a warped domain (fbm bending fbm, iq's recipe) so the outlines
// wander off round, then value noise frays the body into wisps - dense
// cores keep more of themselves, thin edges tear first - and brightens
// the knots. the noise lives in the sheet's uv (the map's own frame), so
// it pans and zooms with the map, and every galaxy seeds its own.
// temporal dither as sh_fog_dither, on an 8-bit page only.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_dither;   // 1 = dither here (an 8-bit page); 0 = the page is float, it dithers at its blit
uniform vec2  u_seed;     // the galaxy's noise domain offset
uniform float u_freq;     // noise cells across the sheet
uniform float u_warp;     // the outlines' wander, in sheet uv

float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p)
{
    float s = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        s += a * vnoise(p);
        p = p * 2.03 + vec2(17.3, 9.1);
        a *= 0.5;
    }
    return s;
}

void main()
{
    vec2 p = v_vTexcoord * u_freq + u_seed;
    // the warp: two fbm fields bend the domain, then it bends again
    vec2 q = vec2(fbm(p), fbm(p + vec2(5.2, 1.3)));
    vec2 r = vec2(fbm(p + 4.0 * q + vec2(1.7, 9.2)), fbm(p + 4.0 * q + vec2(8.3, 2.8)));
    float n = fbm(p + 3.0 * r);
    // the sheet through the wandering domain: the outlines stop being circles
    vec2 suv = clamp(v_vTexcoord + (r - 0.5) * u_warp, 0.0, 1.0);
    vec4 t = texture2D(gm_BaseTexture, suv);
    float dens = t.a;
    // the fray: the body of a cloud is never touched (a nebula stays a nebula - chopped fine, they all read as
    // smoke; his report), its skirts tear to wisps on a threshold the density lowers; the body's knots brighten a little
    float core = smoothstep(0.55, 0.95, dens);
    float thr = 0.60 - 0.30 * dens;
    float fray = smoothstep(thr - 0.22, thr + 0.22, n);
    float k = mix(fray, 1.0, core);
    float bright = 1.0 + 0.5 * (n - 0.5) * (0.3 + 0.7 * core);
    // (density cubed: the weight the old premultiplied bake came to at its blit - the fog keeps its depth)
    vec4 c = vec4(t.rgb * bright, dens * dens * dens * k) * v_vColour;

    // temporal dither on an 8-bit page (sh_fog_dither's law: white grain re-seeded at 30hz,
    // luminance-gated amplitude, alpha-compensated so it survives the sheet's low draw alpha)
    float fr = floor(u_time * 60.0);
    vec2 ip = floor(gl_FragCoord.xy) + vec2(fr * 13.0, fr * 7.0);
    float g = hash12(ip);
    float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114)) * c.a;
    float amp = min(lum * 255.0 * 0.5, 1.4) * u_dither;
    float a = max(c.a, 0.02);
    c.rgb += (g - 0.5) * (amp / 255.0) / a;
    gl_FragColor = c;
}
