if (s == undefined) exit;
var _pl = sprite_personalities();
var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
var _lk = sprite_looks();
var _ey = _lk.eyes[clamp(s[$ "eyes"] ?? 0, 0, array_length(_lk.eyes) - 1)];
var _mat = s[$ "mat"] ?? 0;
var _col  = s.col;
var _col2 = s[$ "col2"] ?? s.col;
var _dark = merge_colour(_col, c_black, .45);
var _glass = (_mat == 1);

// ---- the body's geometry: an ellipsoid squashed by the impulse ----
var _idle_bob = (st == 0 || st == 3) ? dsin(bob) * .6 : 0;
var _rx = r * (1 + sq * .35);
var _ry = r * (1 - sq * .30) + ((st == 3) ? -1 : 0);
var _cy = y - _ry - hop + _idle_bob;    // the body's centre; y is the feet
// the shadow
draw_sprite_ext(spr_pixel_1x1, 0, floor(x - _rx), floor(y), ceil(_rx * 2) + 1, 1, 0, c_black, .35);

// the glass ones glow a little; the orbiting specks are RANK (his
// call, 2026-09-11: "those circles should only spawn on more powerful
// sprites") - a sprite in the top tier of its personality's rate wears
// them, whatever its material, so the specks read as strength rather
// than as glass
if (_glass) {
	var _gs = (r * 6) / sprite_get_width(spr_vis_glow_soft);
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_vis_glow_soft, 0, x, _cy, _gs, _gs, 0, _col, .10);
	gpu_set_blendmode(bm_normal);
}
if (sprite_rate(s) >= SPRITE_SPECK_RATE) {
	for (var _k = 0; _k < array_length(spk); _k++) {
		var _sk = spk[_k];
		var _sa = _sk.a + bob * .35 * (1 + _k * .3);
		var _tw = .25 + .55 * abs(dsin(bob * 1.7 + _sk.ph));
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(x + lengthdir_x(_rx + _sk.r, _sa)), floor(_cy + lengthdir_y(_ry + _sk.r, _sa)),
			1, 1, 0, merge_colour(_col2, c_white, .6), _tw);
	}
}

// ---- THE BODY: sh_blob on a square quad, one ray per room px ----
var _half = max(_rx, _ry) + 1;
var _qx = x - _half, _qy = _cy - _half, _qs = _half * 2;
shader_set(sh_blob);
shader_set_uniform_f(u_quad_b, _qx, _qy, _qs, _qs);
shader_set_uniform_f(u_cells_b, ceil(_qs));
shader_set_uniform_f(u_col_b,  colour_get_red(_col) / 255,  colour_get_green(_col) / 255,  colour_get_blue(_col) / 255);
shader_set_uniform_f(u_col2_b, colour_get_red(_col2) / 255, colour_get_green(_col2) / 255, colour_get_blue(_col2) / 255);
shader_set_uniform_f(u_mat_b, _mat);
shader_set_uniform_f(u_light_b, -.42, -.62, .66);   // the dice's light
shader_set_uniform_f(u_sq_b, _rx / _half, _ry / _half);
shader_set_uniform_f(u_time_b, (current_time mod 100000) / 1000);
scene_light_bind(s_scene_b, s_scene_bw, u_sceneuv_b, u_sceneam_b);
draw_sprite_stretched(spr_pixel_1x1, 0, _qx, _qy, _qs, _qs);
shader_reset();
scene_light_unbind();

// ---- the eyes, in their style ----
var _ew = _ey.w, _eh = _ey.h;
var _eyy = floor(_cy - _ry * .15 - (_eh - 2) * .5);
var _n_eyes = (_ey.gap > 0) ? 2 : 1;
var _white = (_ey.name == "sparkle") ? _dark : c_white;
var _pupil = (_ey.name == "sparkle") ? c_white : c_black;
for (var _k = 0; _k < _n_eyes; _k++) {
	var _side = (_n_eyes == 1) ? 0 : ((_k == 0) ? -1 : 1);
	var _ex = floor(x + _side * (_ey.gap * .5 + _ew * .5)) - floor(_ew * .5);
	if (st == 3) {
		// asleep: closed
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy + _eh - 1, _ew, 1, 0, _dark, 1);
	} else if (happy > 0) {
		// ^ ^
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy + 1, 1, 1, 0, _dark, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _ex + 1, _eyy, max(1, _ew - 2), 1, 0, _dark, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _ex + _ew - 1, _eyy + 1, 1, 1, 0, _dark, 1);
	} else if (blink > 0) {
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy + _eh - 1, _ew, 1, 0, _dark, 1);
	} else {
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy, _ew, _eh, 0, _white, 1);
		if (_ey.name == "lidded")   // the lid: the top row darkened
			draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy, _ew, 1, 0, _dark, 1);
		if (_ey.pupil) {
			var _px = _ex + clamp(floor((_ew - 1) * .5 + look_x * .9), 0, _ew - 1);
			var _py = _eyy + clamp(floor((_eh - 1) * .5 + look_y * .9), (_ey.name == "lidded") ? 1 : 0, _eh - 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _px, _py, 1, 1, 0, _pupil, 1);
		} else if (_ey.name == "sparkle") {
			draw_sprite_ext(spr_pixel_1x1, 0, _ex, _eyy, 1, 1, 0, c_white, .9);
		}
	}
}
// the mouth: a dot, a smile when happy
var _my = _eyy + _eh + 1;
if (happy > 0) draw_sprite_ext(spr_pixel_1x1, 0, floor(x) - 1, _my, 3, 1, 0, _dark, .9);
else if (st != 3 && _ey.mouth) draw_sprite_ext(spr_pixel_1x1, 0, floor(x), _my, 1, 1, 0, _dark, .7);

// ---- asleep: a drifting z ----
if (st == 3) {
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.5 + .3 * dsin(bob * 2));
	draw_text(floor(x + r), floor(_cy - _ry - 6 - (bob mod 60) * .1), "z");
	draw_set_alpha(1);
}

// ---- the bubble ----
if (bub_t > 0 && bub != "") {
	draw_set_font(fnt);
	draw_set_halign(fa_center);
	var _bw = string_width(bub) + 6;
	var _bx = clamp(floor(x), _bw * .5 + 2, room_width - _bw * .5 - 2);
	var _by = floor(_cy - _ry - 14);
	var _ba = min(1, bub_t / 20);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx - _bw * .5, _by - 1, _bw, 10, 0, c_black, .75 * _ba);
	draw_px_rect(_bx - _bw * .5, _by - 1, _bw, 10, _col, .6 * _ba);
	draw_set_color(c_white);
	draw_set_alpha(.95 * _ba);
	draw_text(_bx, _by + 1, bub);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
}

// ---- the card ----
if (card > 0) {
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	var _mn = _lk.mats[clamp(_mat, 0, array_length(_lk.mats) - 1)].name;
	var _lines = [
		s.name,
		_p.name + "  -  " + _mn + ", " + _ey.name + "  -  autotapper",
		"taps " + string(s.taps) + ((s.away > 0) ? ("  (" + string(s.away) + " while you were away)") : ""),
	];
	var _cw = 0;
	for (var _k = 0; _k < 3; _k++) _cw = max(_cw, string_width(_lines[_k]));
	_cw += 10;
	var _ch = 34;
	var _cx = clamp(floor(x + r + 6), 2, room_width - _cw - 2);
	var _cy2 = clamp(floor(_cy - _ch), 20, room_height - _ch - 2);
	var _ca = min(1, card / 20);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy2, _cw, _ch, 0, c_black, .8 * _ca);
	draw_px_rect(_cx, _cy2, _cw, _ch, _col, .8 * _ca);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy2, 2, _ch, 0, _col, .95 * _ca);
	draw_set_color(_col);
	draw_set_alpha(.95 * _ca);
	draw_text(_cx + 5, _cy2 + 3, _lines[0]);
	draw_set_color(sett_ink);
	draw_set_alpha(.8 * _ca);
	draw_text(_cx + 5, _cy2 + 13, _lines[1]);
	draw_text(_cx + 5, _cy2 + 23, _lines[2]);
	draw_set_alpha(1);
}
draw_set_color(c_white);
