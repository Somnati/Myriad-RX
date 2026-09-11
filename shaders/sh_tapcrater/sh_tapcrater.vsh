//
// sh_tapcrater's vertex pass: v_pos is the room position (the puck's
// construction) - the fragment casts one ray per room-pixel cell.
//
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_pos;

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    v_pos = in_Position.xy;
}
