/// @description the pointer - DRAW GUI, so it moves smoothly (his ask,
/// 2026-09-10: "moves smoothly instead of snapping to the pixels but
/// keep the mouse itself pixelated").
///
/// ⚖️ THE ROOM IS A GRID; THE GUI IS NOT. Everything in a Draw event
/// lands on the application surface at room resolution - 144 px across
/// - and is scaled up to the window, so a pointer drawn there can only
/// stand on room pixels and steps eight or nine screen pixels at a
/// time. The GUI layer is a coordinate MAPPING over the window's own
/// pixels (display_set_gui_size(room_width, room_height) sets the
/// units, not a surface), so a quad drawn here at a fractional room
/// coordinate rasterises at the window's resolution: the pointer
/// glides. The ARROW stays chunky because its cells are its own -
/// sh_cursor quantizes the quad into one-room-pixel cells anchored on
/// the hotspot, so the blocks ride with the pointer instead of the
/// room's grid. It also puts the pointer above the app surface and
/// every FX layer for free, which is what the -20000 depth was for.
/// Draw GUI still orders by depth, so it tops the fps text and the
/// dialogue box too.

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
// on the hotspot.
var _al = max(.3, 1 - sq), _ac = 1 + sq;
var _tx = mousex, _ty = mousey;   // fractional: the glide (the cells are the quad's own, so the arrow stays whole pixels)
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
