/// the card. Text on a plate: the objective's name behind a gold rule,
/// its steps under it each behind a box - filled gold with a black
/// check once ticked (the text dims with it), hollow while waiting.
/// The celebration turns the rule and the name green and says so.
if (a <= 0 || okey == "") exit;
var _o = objective_by_key(okey);
if (is_undefined(_o)) exit;

var _r  = __rect();
var _sl = 1 - power(1 - slide, 3);
var _ox = -(1 - _sl) * 18;                 // the arrival, from the left
var _al = a * (.4 + .6 * _sl);
var _x  = _r.x + _ox, _y = _r.y, _w = _r.w;
var _dim  = rgb(120, 130, 150);
var _done = (cel > 0);
var _ac   = _done ? c_sgreen : c_gold;     // the accent: gold, green while it celebrates
var _cb   = _done ? (.5 + .5 * abs(dsin(current_time * .5))) : 0;   // the celebration's breath

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- the plate ----
draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _r.h, 0, c_black, .82 * _al);
draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, 1, 0, c_white, .07 * _al);
draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, 2, _r.h, 0, _ac, (.85 + .15 * _cb) * _al);
if (_done) draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _r.h, 0, c_sgreen, .08 * _cb * _al);

// ---- the name (the "objective" label only where the width allows) ----
var _lx = _x + 8;
if (room_width > 300) {
	draw_set_color(_dim);
	draw_set_alpha(.55 * _al);
	draw_text(_lx, _y + 3, "objective");
	_lx += string_width("objective") + 6;
}
draw_set_color(_ac);
draw_set_alpha(.95 * _al);
var _nm = _o.name;
if (_done) _nm += (room_width > 300) ? "  -  complete" : " - done";
draw_text(_lx, _y + 3, _nm);

// ---- the steps ----
var _ls = __lines(_o);
var _ry = _y + 15;
for (var _i = 0; _i < array_length(_ls); _i++) {
	var _l  = _ls[_i];
	var _e  = (_i < array_length(se)) ? se[_i] : (_l.done ? 1 : 0);
	var _f  = (_i < array_length(sf)) ? sf[_i] : 0;
	var _bx = _x + 8, _by = _ry + 1;
	// the box: hollow, filling gold as it ticks; the flash rings it
	draw_px_rect(_bx, _by, 6, 6, _ac, (.55 + .45 * _e) * _al);
	if (_e > 0) draw_sprite_ext(spr_pixel_1x1, 0, _bx + 1, _by + 1, 4 * _e, 4, 0, _ac, .95 * _al);
	if (_e >= .999) {
		// the check: three cells, black on the gold
		draw_sprite_ext(spr_pixel_1x1, 0, _bx + 1, _by + 3, 1, 1, 0, c_black, .9 * _al);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx + 2, _by + 4, 1, 1, 0, c_black, .9 * _al);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx + 3, _by + 3, 1, 1, 0, c_black, .9 * _al);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx + 4, _by + 2, 1, 1, 0, c_black, .9 * _al);
	}
	if (_f > 0) draw_px_rect(_bx - 2, _by - 2, 10, 10, _ac, _f * .8 * _al);
	// the text: white while waiting, dim once ticked
	draw_set_color(merge_colour(c_white, _dim, _e));
	draw_set_alpha((.92 - .35 * _e) * _al);
	draw_text_ext(_x + 18, _ry, _l.txt, 9, _w - 24);
	_ry += _l.h;
}

draw_set_alpha(1);
draw_set_color(c_white);
