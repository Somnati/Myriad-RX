draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dim = rgb(120, 130, 150);

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, sett_ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "automation");
if (tab == 0) {
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(room_width - 70, bby + 5,
		"one buy a second, while the bill fits the share");
	draw_set_halign(fa_left);
}

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// ---- the rail ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0,
	c_black, .55);
for (var _t = 0; _t < 3; _t++) {
	var _r  = __tab_rect(_t);
	var _on = (tab == _t);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0,
		_on ? merge_colour(tcol[_t], c_black, .6) : c_black, _on ? .95 : .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 2, _r.h, 0, tcol[_t],
		_on ? .95 : .3);
	draw_set_color(_on ? c_white : merge_colour(tcol[_t], c_white, .35));
	draw_set_alpha(_on ? .95 : .6);
	draw_text(_r.x + 7, _r.y + 5, tabs[_t]);
}

// ---- the page ----
var _rows = __page_rows();
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _rw = _rows[_i];
	var _ry = __row_y(_i);
	if (_ry + row_h > room_height - 4) break;

	// the row surface, statistics' language
	var _c = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
	draw_sprite_ext(spr_pixel_1x1, 0, cont_x, _ry, cont_w, row_h, 0, _c, 1);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, cont_x, _ry, cont_w, 1, 0,
		_c, c_black, c_black, _c, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, cont_x, _ry, 2, row_h, 0, _rw.col,
		_rw.on ? .9 : .25);

	draw_set_halign(fa_left);
	draw_set_color(_rw.on ? c_white : _dim);
	draw_set_alpha(_rw.on ? .95 : .6);
	draw_text(cont_x + 7, _ry + 3, _rw.name);

	// the toggle
	if (_rw.kind == 0 || _rw.kind == 2) {
		var _tg = __tog_r(_i);
		draw_sprite_ext(spr_pixel_1x1, 0, _tg.x, _tg.y, _tg.w, _tg.h, 0,
			_rw.on ? merge_colour(_rw.col, c_black, .5) : c_black,
			_rw.on ? .95 : .5);
		draw_px_rect(_tg.x, _tg.y, _tg.w, _tg.h, _rw.col, _rw.on ? .9 : .3);
		draw_set_halign(fa_center);
		draw_set_color(_rw.on ? c_white : _dim);
		draw_set_alpha(_rw.on ? .95 : .6);
		draw_text(_tg.x + _tg.w / 2 + 1, _tg.y + 2, _rw.on ? "on" : "off");
		draw_set_halign(fa_left);
	}

	// the slider - dim while its toggle is off, because a number that
	// is not being used should not read as one that is
	if (_rw.kind == 1 || _rw.kind == 2) {
		var _tk = __trk_r(_i);
		var _f  = clamp((_rw.val - _rw.lo) / max(1, _rw.hi - _rw.lo), 0, 1);
		var _a  = _rw.on ? 1 : .35;
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x, _tk.y, _tk.w, _tk.h, 0,
			c_black, .7 * _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x, _tk.y, _tk.w * _f, _tk.h, 0,
			_rw.col, .8 * _a);
		draw_px_rect(_tk.x, _tk.y, _tk.w, _tk.h, _rw.col, .35 * _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x + _tk.w * _f - 1, _tk.y - 2,
			3, _tk.h + 4, 0, c_white, .8 * _a);

		draw_set_halign(fa_right);
		draw_set_color(_rw.on ? c_white : _dim);
		draw_set_alpha(_rw.on ? .9 : .5);
		draw_text(cont_x + cont_w - 4, _ry + 3, string(_rw.val) + _rw.sfx);
		draw_set_halign(fa_left);
	}

	// the dial pages' verdict pill: what the automation did last pulse
	if (_rw.st >= 0) {
		var _px = cont_x + cont_w - 4;
		draw_set_halign(fa_right);
		draw_set_color((_rw.st == 2) ? c_sgreen : (_rw.st == 1) ? c_horange : _dim);
		draw_set_alpha((_rw.st == 0) ? .35 : .8);
		draw_text(_px, _ry + 3,
			(_rw.st == 2) ? "buying" : (_rw.st == 1) ? "waiting" : "off");
		draw_set_halign(fa_left);
	}
}

// ---- the page's footer note ----
var _fy = room_height - 30;
draw_set_color(_dim);
draw_set_alpha(.55);
if (tab == 1) {
	draw_text(cont_x, _fy,
		"EVERY enabled condition must pass - they are rails, not triggers");
	var _c = rebirth_calc();
	draw_set_color(_c.can ? c_sgreen : _dim);
	draw_set_alpha(.7);
	draw_text(cont_x, _fy + 10, "now: "
		+ (_c.can ? ("+" + crunch_arb(_c.units) + " units") : "nothing yet")
		+ "   run " + crunch_time_long(_c.run_s * 60)
		+ (_c.cool > 0 ? ("   cooldown " + string(ceil(_c.cool)) + "s") : ""));
}
if (tab == 2) {
	// SAY WHAT THE PERCENTAGE MEANS. "keep the best 25%" is only a
	// useful control if the screen also tells you which rung that is
	// today - the whole point of a relative filter is that the answer
	// moves, and a moving answer you cannot see is a mystery.
	var _fl = upgrade_keep_rarity();
	draw_text(cont_x, _fy, "keeping " + upgrade_rarity_info(_fl).name
		+ " and above - " + string(g.autom.upg.keep)
		+ "% of rolls, worked out from the live odds");
	draw_set_color(c_horange);
	draw_set_alpha(.6);
	draw_text(cont_x, _fy + 10,
		"it never sells a slot you have bought tiers into");
}

draw_set_alpha(1);
draw_set_color(c_white);
