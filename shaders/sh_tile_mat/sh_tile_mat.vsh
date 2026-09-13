//
// the tile surface's vertex pass: v_pos is the ROOM position of the
// fragment (the cursor's and the puck's construction) - the fragment
// quantizes it to one cell per room pixel and reads nothing from the
// quad's own texcoords.
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
