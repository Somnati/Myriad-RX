//
// sh_blob's vertex pass: the room position rides through so the
// fragment can quantise the ray to room-pixel cells (sh_cursor's way).
//
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_pos;
varying vec2 v_uv;    // the sprite's texcoord - read once in the fragment
                      // so gm_BaseTexture keeps sampler 0 (see the .fsh)

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    v_pos = in_Position.xy;
    v_uv  = in_TextureCoord;
}
