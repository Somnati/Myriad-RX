//
// sh_blur - a separable 9-tap gaussian (2026-09-15): one pass along
// u_dir (1,0 then 0,1), u_texel = one texel of the source in texcoord
// units. The galaxy view's bloom: the finished map blurred at half size
// and laid back additively (the glow the demo's fx layer gave it).
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_dir;
uniform vec2 u_texel;

void main()
{
    vec2 o = u_dir * u_texel;
    vec4 c = texture2D(gm_BaseTexture, v_vTexcoord) * 0.2270;
    c += texture2D(gm_BaseTexture, v_vTexcoord + o * 1.0) * 0.1945;
    c += texture2D(gm_BaseTexture, v_vTexcoord - o * 1.0) * 0.1945;
    c += texture2D(gm_BaseTexture, v_vTexcoord + o * 2.0) * 0.1216;
    c += texture2D(gm_BaseTexture, v_vTexcoord - o * 2.0) * 0.1216;
    c += texture2D(gm_BaseTexture, v_vTexcoord + o * 3.0) * 0.0540;
    c += texture2D(gm_BaseTexture, v_vTexcoord - o * 3.0) * 0.0540;
    c += texture2D(gm_BaseTexture, v_vTexcoord + o * 4.0) * 0.0162;
    c += texture2D(gm_BaseTexture, v_vTexcoord - o * 4.0) * 0.0162;
    gl_FragColor = c * v_vColour;
}
