/// @description sprite_portrait(sprite, x, y, r) - the sprite as the room draws it (obj_blob: the sh_blob body in its material and colours, its eyes, a mouth), still, centred at x / y with radius r
/// His ask (2026-09-15): "the portrait of the sprite... the higher
/// quality one we see in the room". No scene light (the sheet is black),
/// no squash, the eyes open and looking ahead. Sets and resets its own
/// shader - a caller under the ui fade puts the fade back after.
function sprite_portrait(_s, _x, _y, _r) {
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		quad : shader_get_uniform(sh_blob, "u_quad"), cells : shader_get_uniform(sh_blob, "u_cells"),
		col : shader_get_uniform(sh_blob, "u_col"), col2 : shader_get_uniform(sh_blob, "u_col2"),
		mat : shader_get_uniform(sh_blob, "u_mat"), light : shader_get_uniform(sh_blob, "u_light"),
		sq : shader_get_uniform(sh_blob, "u_sq"), time : shader_get_uniform(sh_blob, "u_time"),
		amt : shader_get_uniform(sh_blob, "u_scene_amt"),
	};
	var _lk = sprite_looks();
	var _ey = _lk.eyes[clamp(_s[$ "eyes"] ?? 0, 0, array_length(_lk.eyes) - 1)];
	var _mat = _s[$ "mat"] ?? 0;
	var _col = _s.col, _col2 = _s[$ "col2"] ?? _s.col;
	var _dark = merge_colour(_col, c_black, .45);
	var _rx = _r, _ry = _r * .96;
	var _cy = _y;
	// the body
	var _half = max(_rx, _ry) + 1;
	var _qx = floor(_x - _half), _qy = floor(_cy - _half), _qs = ceil(_half * 2);
	var _sh = shader_current();
	shader_set(sh_blob);
	shader_set_uniform_f(_u.quad, _qx, _qy, _qs, _qs);
	shader_set_uniform_f(_u.cells, _qs);
	shader_set_uniform_f(_u.col,  colour_get_red(_col) / 255,  colour_get_green(_col) / 255,  colour_get_blue(_col) / 255);
	shader_set_uniform_f(_u.col2, colour_get_red(_col2) / 255, colour_get_green(_col2) / 255, colour_get_blue(_col2) / 255);
	shader_set_uniform_f(_u.mat, _mat);
	shader_set_uniform_f(_u.light, -.42, -.62, .66);
	shader_set_uniform_f(_u.sq, _rx / _half, _ry / _half);
	shader_set_uniform_f(_u.time, (current_time mod 100000) / 1000);
	shader_set_uniform_f(_u.amt, 0);
	draw_sprite_stretched(spr_pixel_1x1, 0, _qx, _qy, _qs, _qs);
	shader_reset();
	// the eyes, in their style (obj_blob's geometry, looking ahead)
	var _ew = _ey.w, _eh = _ey.h;
	var _eyy = floor(_cy - _ry * .15 - (_eh - 2) * .5);
	var _n_eyes = (_ey.gap > 0) ? 2 : 1;
	var _white = (_ey.name == "sparkle") ? _dark : c_white;
	var _pupil = (_ey.name == "sparkle") ? c_white : c_black;
	for (var _k = 0; _k < _n_eyes; _k++) {
		var _side = (_n_eyes == 1) ? 0 : ((_k == 0) ? -1 : 1);
		var _ex = floor(_x + _side * (_ey.gap * .5 + _ew * .5)) - floor(_ew * .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy, _ew, _eh, 0, _white, 1);
		if (_ey.name == "lidded") draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy, _ew, 1, 0, _dark, 1);
		if (_ey.pupil) draw_sprite_ext(spr_pixel_1x1, 0, _ex + floor((_ew - 1) * .5), _eyy + max((_ey.name == "lidded") ? 1 : 0, floor((_eh - 1) * .5)), 1, 1, 0, _pupil, 1);
		else if (_ey.name == "sparkle") draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy, 1, 1, 0, c_white, .9);
	}
	if (_ey.mouth) draw_sprite_ext(spr_pixel_1x1, 0, floor(_x), _eyy + _eh + 1, 1, 1, 0, _dark, .7);
	if (_sh != -1) shader_set(_sh);
}
