/// @description the pointer

// mobile has no pointer to draw, and drawing one at the last touch
// position leaves an arrow stranded on screen after the finger lifts
if (os_type == os_android || os_type == os_ios) exit;

// ⚖️ SQUASHED ALONG THE ARROW, NOT DOWN THE SCREEN (his report,
// 2026-09-10). The first pass scaled the sprite's own axes - wider and
// shorter - which on an arrow that points up-left reads as the arrow
// bending sideways. A press pushes the arrow INTO the thing it points
// at, so the squash is along the arrow's length: shorter tip-to-tail,
// wider across. The sprite's axes are not the arrow's, so the four
// corners are projected onto the arrow's axis and its normal, scaled
// there, and the sprite is drawn on the resulting quad - the tip is
// the pivot, so it stays exactly on the hotspot however hard the
// squash is.
var _ax = dcos(axis), _ay = dsin(axis);   // along the arrow (screen y down)
var _nx = -_ay,           _ny = _ax;                 // across it
var _al = max(.3, 1 - sq), _ac = 1 + sq;
var _ox = sprite_get_xoffset(spr_cursor), _oy = sprite_get_yoffset(spr_cursor);
var _w  = sprite_get_width(spr_cursor),   _h  = sprite_get_height(spr_cursor);
var _px = [-_ox, _w - _ox, _w - _ox, -_ox];
var _py = [-_oy, -_oy, _h - _oy, _h - _oy];
var _qx = array_create(4), _qy = array_create(4);
for (var _i = 0; _i < 4; _i++) {
	var _a = (_px[_i] * _ax + _py[_i] * _ay) * _al;   // along, squashed
	var _c = (_px[_i] * _nx + _py[_i] * _ny) * _ac;   // across, widened
	_qx[_i] = mousex + _a * _ax + _c * _nx;
	_qy[_i] = mousey + _a * _ay + _c * _ny;
}
// ...and through the raycast (settings > visuals "raycast pointer").
// The page rect + trim come from sprite_get_uvs: GM may crop a sprite's
// transparent margin on the texture page, and the shader has to know
// where the trimmed rect sits in the 16x16 to recover the pixel.
var _uv = sprite_get_uvs(spr_cursor, 0);
shader_set(sh_cursor);
shader_set_uniform_f(u_uv, _uv[0], _uv[1], _uv[2], _uv[3]);
shader_set_uniform_f(u_trim, _uv[4], _uv[5], _w * _uv[6], _h * _uv[7]);
shader_set_uniform_f(u_light, -.42, -.62, .66);   // the dice's light
shader_set_uniform_f(u_on, (variable_global_exists("cursor_ray") && g.cursor_ray) ? 1 : 0);
draw_sprite_pos(spr_cursor, 0, _qx[0], _qy[0], _qx[1], _qy[1],
	_qx[2], _qy[2], _qx[3], _qy[3], 1);
shader_reset();
