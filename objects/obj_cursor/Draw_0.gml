/// @description the pointer
///
/// ⚖️ IT GLIDES, AND THE ARROW STAYS CHUNKY (his ask, 2026-09-10:
/// "moves smoothly instead of snapping to the pixels but keep the mouse
/// itself pixelated"). The application surface is 1920x1080 (syst_display)
/// whatever the room's size, so a fractional room coordinate lands on a
/// fractional surface position - thirteen-odd surface pixels to a room
/// pixel in the money room - and the pointer moves as smoothly as the
/// mouse does. The snap he saw was take two's floor() on the hotspot,
/// put there so a cell would sit exactly on a sprite pixel; the cells
/// are the quad's own (sh_cursor quantizes the quad, anchored on the
/// hotspot), so they stay whole room pixels wherever the hotspot is,
/// and the floor bought nothing. A Draw GUI pass was tried first and
/// went invisible: the GUI mapping is set per room by the display
/// driver on swaps only, so it is stale in most rooms - the app surface
/// is the reliable canvas here, and at 1920 wide it is already finer
/// than the eye needs.

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

// ---- THE SWEEP (motion blur, his ask 2026-09-10 - the puck's law) ----
// The tip's last drawn seat to this one, over a fixed 1/60 shutter
// (this frame's travel / delta), capped at 24px so a warp to the other
// side of the room is a flick, not a bar across it. One instant per
// two pixels of travel, two at least once moving, eight at most; still
// draws once at rest.
var _mb  = variable_global_exists("motion_blur") ? g.motion_blur : true;
var _sdt = max(delta, .05);
var _bx = _mb ? (_tx - mbx) / _sdt : 0;
var _by = _mb ? (_ty - mby) / _sdt : 0;
var _bl = point_distance(0, 0, _bx, _by);
if (_bl > 24) { _bx *= 24 / _bl; _by *= 24 / _bl; _bl = 24; }
var _mbk = (_bl < .5) ? 1 : clamp(ceil(_bl / 2), 2, 8);
mbx = _tx; mby = _ty;

// the quad covers the sweep: a square from the earliest tip's box to
// the latest's, cells still one room pixel each
var _qx = min(_tx, _tx - _bx) - sprite_get_xoffset(spr_cursor) - CUR_PAD;
var _qy = min(_ty, _ty - _by) - sprite_get_yoffset(spr_cursor) - CUR_PAD;
var _qs = sprite_get_width(spr_cursor) + CUR_PAD * 2 + ceil(max(abs(_bx), abs(_by)));
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
shader_set_uniform_f(u_mb, _bx, _by);
shader_set_uniform_f(u_mbk, _mbk);
draw_sprite_stretched(spr_cursor_sdf, 0, _qx, _qy, _qs, _qs);
shader_reset();
gpu_set_tex_filter(false);
