//
// the pointer's vertex pass: the default pass-through. The quad is
// draw_sprite_pos's (already squashed along the arrow by obj_cursor), and
// the texcoord is what carries the SPRITE-space position into the
// fragment - so the squash deforms the shading with the silhouette.
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
