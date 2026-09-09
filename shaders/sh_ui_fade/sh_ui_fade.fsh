//
// ui fade: the default pass-through, times one uniform on the ALPHA
// channel only.
//
// It exists because fading a panel row by row meant reaching into 56
// separate draw calls across the statistics screen alone - every one a
// chance to miss a site, and a diff nobody could review. One uniform in
// front of the whole row loop is the same result with one place to be
// wrong, and it composites correctly over the blurred room underneath
// because it scales alpha rather than blending toward a flat colour.
//
// Alpha only, deliberately: multiplying the colour would darken rows
// toward black instead of dissolving them, which is the exact look the
// veil-over-the-row approach would have given.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_alpha;

void main()
{
    vec4 _c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    _c.a *= u_alpha;
    gl_FragColor = _c;
}
