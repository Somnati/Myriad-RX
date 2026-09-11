if (s == undefined) exit;
var _pl = sprite_personalities();
var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
var _col  = s.col;
var _dark = merge_colour(_col, c_black, .45);

// ---- the body: a rasterised ellipse, squashed by the impulse ----
var _idle_bob = (st == 0 || st == 3) ? dsin(bob) * .6 : 0;
var _rx = r * (1 + sq * .35);
var _ry = r * (1 - sq * .30) + ((st == 3) ? -1 : 0);
var _cy = y - _ry - hop + _idle_bob;    // the body's centre; y is the feet
// the shadow
draw_sprite_ext(spr_pixel_1x1, 0, floor(x - _rx), floor(y), ceil(_rx * 2) + 1, 1, 0, c_black, .35);
for (var _dy = -floor(_ry); _dy <= floor(_ry); _dy++) {
	var _hw = _rx * sqrt(max(0, 1 - sqr(_dy / max(1, _ry))));
	var _w  = max(1, round(_hw * 2));
	draw_sprite_ext(spr_pixel_1x1, 0, floor(x - _hw), floor(_cy + _dy), _w, 1, 0,
		(_dy > _ry * .45) ? _dark : _col, 1);
}
// a highlight
draw_sprite_ext(spr_pixel_1x1, 0, floor(x - _rx * .45), floor(_cy - _ry * .55), 2, 1, 0, c_white, .35);

// ---- the eyes ----
var _ey = floor(_cy - _ry * .15);
for (var _k = -1; _k <= 1; _k += 2) {
	var _ex = floor(x + _k * 2.2) - 1;
	if (st == 3) {
		// asleep: closed
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ey + 1, 2, 1, 0, _dark, 1);
	} else if (happy > 0) {
		// ^ ^
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ey + 1, 1, 1, 0, _dark, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _ex + 1, _ey, 1, 1, 0, _dark, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _ex + 2, _ey + 1, 1, 1, 0, _dark, 1);
	} else if (blink > 0) {
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ey + 1, 2, 1, 0, _dark, 1);
	} else {
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ey, 2, 2, 0, c_white, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _ex + clamp(round(look_x * .8 + .5), 0, 1),
			_ey + clamp(round(look_y * .8 + .5), 0, 1), 1, 1, 0, c_black, 1);
	}
}
// the mouth: a dot, a smile when happy
if (happy > 0) draw_sprite_ext(spr_pixel_1x1, 0, floor(x) - 1, _ey + 3, 3, 1, 0, _dark, .9);
else if (st != 3) draw_sprite_ext(spr_pixel_1x1, 0, floor(x), _ey + 3, 1, 1, 0, _dark, .7);

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
	var _lines = [
		s.name,
		_p.name + "  -  autotapper",
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
