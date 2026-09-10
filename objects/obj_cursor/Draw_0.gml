/// @description the pointer

// mobile has no pointer to draw, and drawing one at the last touch
// position leaves an arrow stranded on screen after the finger lifts
if (os_type == os_android || os_type == os_ios) exit;

// ⚖️ SQUASHED ALONG THE ARROW, NOT DOWN THE SCREEN (his report,
// 2026-09-10): a press pushes the arrow INTO the thing it points at, so
// the squash is along the arrow's length - shorter tip-to-tail, wider
// across - and, take two, it is the SOLID that squashes, not a quad
// with the sprite on it: sh_cursor casts one ray per room pixel into
// the arrow deformed in object space, so the shape re-rasterises cell
// by cell (the dice's native pixelation) and the bevel that catches the
// light is the squashed bevel. A press also flattens it (u_flat), so
// the highlight softens as it squashes. The tip is the pivot and sits
// on the hotspot to the pixel.
var _al = max(.3, 1 - sq), _ac = 1 + sq;
var _tx = floor(mousex), _ty = floor(mousey);   // whole px: at rest every cell is a sprite pixel
var _qx = _tx - sprite_get_xoffset(spr_cursor) - CUR_PAD;
var _qy = _ty - sprite_get_yoffset(spr_cursor) - CUR_PAD;
var _qs = sprite_get_width(spr_cursor) + CUR_PAD * 2;
var _uv = sprite_get_uvs(spr_cursor_sdf, 0);   // opaque throughout, so never trimmed

gpu_set_tex_filter(true);   // the field reads smooth between its samples
shader_set(sh_cursor);
shader_set_uniform_f(u_quad, _qx, _qy, _qs, _qs);
shader_set_uniform_f(u_tip, _tx, _ty);
shader_set_uniform_f(u_uv, _uv[0], _uv[1], _uv[2], _uv[3]);
shader_set_uniform_f(u_axis, dcos(axis), dsin(axis));
shader_set_uniform_f(u_sq, _al, _ac);
shader_set_uniform_f(u_flat, max(.25, 1 - sq * 1.2));
shader_set_uniform_f(u_light, -.42, -.62, .66);   // the dice's light
shader_set_uniform_f(u_cells, _qs);
shader_set_uniform_f(u_lit, (variable_global_exists("cursor_ray") && g.cursor_ray) ? 1 : 0);
draw_sprite_stretched(spr_cursor_sdf, 0, _qx, _qy, _qs, _qs);
shader_reset();
gpu_set_tex_filter(false);
