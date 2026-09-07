//
// sh_mandel vertex stage.
//
// ⚖️ IT DOES NOT USE THE TEXTURE COORDINATES, and that is the whole
// reason this file is not the default passthrough. The quad is
// spr_pixel_1x1 stretched over the room, and a 1x1 sprite's UVs are a
// ONE-TEXEL sub-rectangle of its texture page - v_vTexcoord would be
// very nearly constant across the entire screen, and the fractal would
// come out as a single flat colour. (A texture page is also free to
// move a sprite between builds, so anything derived from those UVs is
// unstable even when it happens to work.)
//
// The position is unambiguous instead: the quad is drawn at (0,0) with
// the room's size, so in_Position.xy / u_res IS the 0..1 coordinate
// across it - correct orientation, no dependence on the atlas, and no
// gl_FragCoord flip to worry about between the GL and DirectX targets.
//
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_pos;      // 0..1 across the quad, derived from position
varying vec4 v_vColour;

uniform vec2 u_res;      // the quad's size in room pixels (shared with the fsh)

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    v_vColour = in_Colour;
    v_pos     = in_Position.xy / u_res;
}
