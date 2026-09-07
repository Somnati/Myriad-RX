//
// sh_mandel vertex stage - the plain passthrough, deliberately.
//
// ⚖️ IT DECLARES NO UNIFORMS AND PASSES NO DERIVED COORDINATE, and
// both of those are the point.
//
// The first cut computed `v_pos = in_Position.xy / u_res` here, to
// avoid the OTHER trap (the quad is spr_pixel_1x1 stretched, and a 1x1
// sprite's texture coordinates are a single texel of its atlas page -
// v_vTexcoord is effectively constant across the whole screen, which
// renders the fractal as one flat colour). That swapped one flat screen
// for another: a uniform read in the VERTEX stage is not reliably
// populated by shader_set_uniform_f, so u_res arrived as zero, the
// division produced NaN, and every NaN comparison in the fragment
// shader is false - so every pixel took the same branch and the screen
// came out one colour again.
//
// The fragment shader derives its coordinate from gl_FragCoord instead.
// That needs nothing from here, and it is the same source the shipped
// sh_fog_dither already uses successfully in this exact pipeline.
//
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}
