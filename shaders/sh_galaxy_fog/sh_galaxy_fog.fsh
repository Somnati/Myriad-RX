//
// the galaxy map's nebula fog, PROCEDURAL (his report, 2026-09-16: the
// nebulae came out circular - the density sheet is 64 cells of blurred
// star counts drawn bilinear, so every cloud was a round blob). the sheet
// (galaxy_neb_sheet, gray: red = density) stays the WHERE; the colour
// (warm core / cool rim) is the law below. this carves the HOW: the sheet is sampled
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
uniform vec3  u_gal;      // the galaxy's centre (uv) and disc radius (uv): the colour law's frame

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
    // the sheet is gray: its red is the density (alpha 1 - the bake owes nothing to a blend mode)
    float dens = texture2D(gm_BaseTexture, suv).r;
    // the colour law (the old bake's): warm toward the core, cool at the rim, darker where thin
    float rd = clamp(distance(suv, u_gal.xy) / u_gal.z, 0.0, 1.0);
    vec3 tcol = mix(vec3(1.0, 0.725, 0.490), vec3(0.510, 0.608, 1.0), rd);
    tcol = mix(vec3(0.094, 0.086, 0.118), tcol, 0.55 + 0.45 * dens);
    // THE TEXTURE (his reports, 2026-09-16: a fray that tore the skirts cut every cloud to smoke): the body stays
    // whole - the noise only modulates the density a little (mottling, never holes) and lifts the knots; the
    // domain warp above is what bends the outline off round
    float dm = dens * (0.80 + 0.40 * n);
    float bright = 0.85 + 0.30 * n;
    // (density cubed: the weight the old bake came to at its blit - the same fog, bent and mottled)
    vec4 c = vec4(tcol * bright, dm * dm * dm) * v_vColour;

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
