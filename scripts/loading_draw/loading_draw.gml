/// @description loading_draw(cx, cy, sc, txt, prog, col) - THE SPINNER: a ring of
/// eight pixel dots stepping on the wall clock, the caption left of it, a
/// one-pixel progress bar under both (the boot's, 2026-09-16 - "a smooth
/// minimal loading icon"; a script since 2026-09-17 so the expedition panel's
/// loading veil draws the very same thing). cx/cy = the ring's centre, sc =
/// the pixel scale (1 in a room, the house scale on the boot's gui)
function loading_draw(_cx, _cy, _sc, _txt, _prog, _col) {
	// THE DOTS: eight round the ring, 2x2 pixels each, on a 6px radius; the
	// head steps a dot every 90 ms and the tail fades by .6 a dot behind it
	var _head = floor(current_time / 90) mod 8;
	for (var _k = 0; _k < 8; _k++) {
		var _back = (_head - _k + 8) mod 8;
		var _a = max(.08, power(.6, _back));
		var _dx = _cx + lengthdir_x(6 * _sc, _k * 45 - 90), _dy = _cy + lengthdir_y(6 * _sc, _k * 45 - 90);
		_dx = floor(_dx / _sc) * _sc; _dy = floor(_dy / _sc) * _sc;
		draw_sprite_ext(spr_pixel_1x1, 0, _dx - _sc, _dy - _sc, 2 * _sc, 2 * _sc, 0, (_back == 0) ? merge_colour(_col, c_white, .45) : _col, _a);
	}
	draw_set_alpha(1);
	// THE CAPTION, left of the ring, and THE BAR under both
	var _bx1 = _cx + 8 * _sc, _bx0 = _bx1 - 92 * _sc;
	if (variable_global_exists("font")) {
		draw_set_font(fnt);
		_bx0 = _cx - 12 * _sc - max(string_width("charting the galaxy"), string_width(_txt)) * _sc;
		draw_set_halign(fa_right); draw_set_valign(fa_top);
		draw_set_color(rgb(120, 130, 150)); draw_set_alpha(.7);
		draw_text_transformed(_cx - 12 * _sc, _cy - 4 * _sc, _txt, _sc, _sc, 0);
		draw_set_halign(fa_left); draw_set_alpha(1);
	}
	var _by = _cy + 12 * _sc, _bw = _bx1 - _bx0;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx0, _by, _bw, _sc, 0, merge_colour(_col, c_black, .8), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx0, _by, floor(_bw * clamp(_prog, 0, 1) / _sc) * _sc, _sc, 0, _col, .85);
	draw_set_color(c_white); draw_set_alpha(1);
}
