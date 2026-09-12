/// the panel's face. Draw-only; the Step's hits share this geometry.
var _b   = g.battery;
var _cap = battery_cap();
var _dim = rgb(120, 130, 150);

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- the title strip - slides down from under the header ----
var _sp = ui_anim_in(oa, 1);
if (_sp > .001) {
	var _so = -(1 - _sp) * UI_IN_SLIDE;
	if (_so != 0) matrix_set(matrix_world, matrix_build(0, _so, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_sp);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, 16, 0, c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, hh + 15, room_width, 1, 0, sett_ink, .25);
	draw_set_color(c_sgreen);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "battery");
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(room_width - 8, hh + 5, "what runs while you are away, and for how long");
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the charge meter ----
if (__part(2) > 0) {
	var _f = clamp(_b.charge / max(1, _cap), 0, 1);
	var _bx = col_x, _by = bat_y;
	// the battery: a body of ten cells and a nub
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, bat_w, bat_h, 0, c_black, .8);
	draw_px_rect(_bx, _by, bat_w, bat_h, c_sgreen, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx + bat_w, _by + 6, 4, bat_h - 12, 0, c_sgreen, .6);
	var _cells = 10;
	var _cw = (bat_w - 4 - (_cells - 1) * 2) / _cells;
	for (var _k = 0; _k < _cells; _k++) {
		var _lo = _k / _cells, _hi = (_k + 1) / _cells;
		var _fill = clamp((_f - _lo) / (_hi - _lo), 0, 1);
		var _cx = _bx + 2 + _k * (_cw + 2);
		if (_fill > 0)
			draw_sprite_ext(spr_pixel_1x1, 0, _cx, _by + 3, _cw * _fill, bat_h - 6, 0,
				(_f < .2) ? c_hred : c_sgreen, .9);
		draw_px_rect(_cx, _by + 3, _cw, bat_h - 6, c_sgreen, .15);
	}
	// the numbers
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_bx, _by + bat_h + 4,
		((_b.charge >= 1) ? crunch_time_long(_b.charge * 60) : "empty") + " of " + crunch_time_long(_cap * 60));
	draw_set_color(_dim);
	draw_set_alpha(.7);
	var _need = (_cap - _b.charge) / max(.001, battery_rate());
	draw_text(_bx, _by + bat_h + 14, (_b.charge >= _cap - 1) ? "full"
		: ("full in " + crunch_time_long(_need * 60) + " here  -  or crank it"));
	// how long it lasts away, the readout the sliders are for
	var _lasts = battery_lasts();
	var _draw  = battery_draw();
	draw_set_color(c_gold);
	draw_set_alpha(.9);
	draw_text(_bx, _by + bat_h + 30, (_draw <= 0) ? "nothing draws - it lasts forever"
		: ("lasts " + crunch_time_long(_lasts * 60) + " away at these rates"
			+ ((_draw < .999) ? ("  (draw x" + string_format(_draw, 1, 2) + ")") : "")));
	__part_end();
}

// ---- the offline rates ----
if (__part(3) > 0) {
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(col_x, rate_y - 12, "offline speed - slower draws much less (the square)");
	var _a = g.autom;
	for (var _i = 0; _i < 3; _i++) {
		var _ry = rate_y + _i * rate_p;
		var _v  = _b.rate[$ rates[_i]];
		var _on = (_i == 0) ? _a.run.on : ((_i == 1) ? _a.fab.on
		        : (variable_global_exists("tiles") && g.tiles.automerge));
		var _sa = _on ? 1 : .4;
		draw_set_color(_on ? c_white : _dim);
		draw_set_alpha(.9 * _sa);
		draw_text(col_x, _ry + 2, rate_lbl[_i]);
		var _t = __trk_r(_i);
		var _f = clamp((_v - 5) / 95, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x, _t.y, _t.w, _t.h, 0, c_black, .7 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x, _t.y, _t.w * _f, _t.h, 0, rate_col[_i], .8 * _sa);
		draw_px_rect(_t.x, _t.y, _t.w, _t.h, rate_col[_i], .35 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x + _t.w * _f - 1, _t.y - 2, 3, _t.h + 4, 0, c_white, .8 * _sa);
		draw_set_color(_on ? c_white : _dim);
		draw_set_alpha(.9 * _sa);
		draw_text(_t.x + _t.w + 6, _ry + 2, string(_v) + "%" + (_on ? "" : "  (off in automation)"));
	}
	__part_end();
}

// ---- the two ladders ----
if (__part(4) > 0) {
	for (var _r = 0; _r < 2; _r++) {
		var _ry = upg_y + _r * upg_p;
		var _q  = (_r == 0) ? q_cap : q_rate;
		draw_set_color(c_white);
		draw_set_alpha(.9);
		if (_r == 0) {
			var _next = BAT_CAP0 * (1 + BAT_CAP_STEP * (_b.cap_lv + 1));
			draw_text(col_x, _ry + 3, "capacity  lv " + string(_b.cap_lv) + "  "
				+ crunch_time_long(_cap * 60) + " > " + crunch_time_long(_next * 60));
		} else {
			var _fill = _cap / battery_rate();
			var _fill2 = _cap / ((BAT_CAP0 / BAT_FILL0) * (1 + BAT_RATE_STEP * (_b.rate_lv + 1)));
			draw_text(col_x, _ry + 3, "charge speed  lv " + string(_b.rate_lv) + "  full in "
				+ crunch_time_long(_fill * 60) + " > " + crunch_time_long(_fill2 * 60));
		}
		var _br = __btn_r(_r);
		draw_ui_button(_br.x, _br.y, _br.w, _br.h, string(_q.cost) + " cr",
			_q.ok ? c_sgreen : c_gray, _q.ok, _q.ok);
	}
	draw_set_color(_dim);
	draw_set_alpha(.55);
	draw_text(col_x, upg_y + 2 * upg_p + 4,
		"credits, the dropper's. equal levels fill in the same two minutes;");
	draw_text(col_x, upg_y + 2 * upg_p + 14,
		"a capacity ahead of its charge speed takes longer. the time bank still");
	draw_text(col_x, upg_y + 2 * upg_p + 24,
		"banks the whole absence; only the machines stop when this runs dry.");
	__part_end();
}

// ---- THE CRANK ----
if (__part(5) > 0) {
	var _gc = merge_colour(c_sgreen, c_white, .3 * crank_glow);
	// ⚖️ STAMPS, NOT PRIMITIVES (his report, 2026-09-11: "Could not
	// generate input layout"). While the panel is arriving __part
	// leaves sh_ui_fade set, and that shader reads in_TextureCoord -
	// which GM's draw_circle / draw_line_width vertices do not carry,
	// so the input layout could not be built. Everything here is
	// spr_pixel_1x1 now, in the house grammar: a rasterised disc
	// (rows), a one-cell ring, spokes as cells along the radius.
	// the disc, row by row
	for (var _dy = -crank_r; _dy <= crank_r; _dy++) {
		var _hw = sqrt(max(0, sqr(crank_r) - sqr(_dy)));
		draw_sprite_ext(spr_pixel_1x1, 0, floor(crank_cx - _hw), floor(crank_cy + _dy),
			max(1, round(_hw * 2)), 1, 0, c_black, .7);
	}
	// the rim: one cell per degree-ish, two px thick
	var _steps = round(crank_r * 6.3);
	for (var _k = 0; _k < _steps; _k++) {
		var _ra = _k * 360 / _steps;
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(crank_cx + lengthdir_x(crank_r - 1, _ra)), floor(crank_cy + lengthdir_y(crank_r - 1, _ra)),
			2, 2, 0, _gc, .85);
	}
	// four spokes, cells along the radius
	for (var _k = 0; _k < 4; _k++) {
		var _sa = ang + _k * 90;
		for (var _d = 4; _d < crank_r - 2; _d++)
			draw_sprite_ext(spr_pixel_1x1, 0,
				floor(crank_cx + lengthdir_x(_d, _sa)), floor(crank_cy + lengthdir_y(_d, _sa)),
				2, 2, 0, _gc, .85);
	}
	// the hub
	draw_sprite_ext(spr_pixel_1x1, 0, floor(crank_cx) - 4, floor(crank_cy) - 4, 9, 9, 0,
		merge_colour(_gc, c_black, .4), .95);
	// the handle knob, on the rim at the crank's angle
	var _hx = floor(crank_cx + lengthdir_x(crank_r, ang));
	var _hy = floor(crank_cy + lengthdir_y(crank_r, ang));
	draw_sprite_ext(spr_pixel_1x1, 0, _hx - 3, _hy - 3, 7, 7, 0, held ? c_gold : c_white, .95);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx - 2, _hy - 4, 5, 9, 0, held ? c_gold : c_white, .95);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx - 4, _hy - 2, 9, 5, 0, held ? c_gold : c_white, .95);
	draw_set_halign(fa_center);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(crank_cx, crank_cy + crank_r + 8, "crank to fast charge");
	draw_set_color(_dim);
	draw_set_alpha(.5);
	draw_text(crank_cx, crank_cy + crank_r + 18,
		"a turn is 1/" + string(BAT_CRANK_REV) + " of the capacity");
	if (abs(vel) > .5 && !held) {
		draw_set_color(c_gold);
		draw_set_alpha(.7);
		draw_text(crank_cx, crank_cy - crank_r - 12, "spinning");
	}
	draw_set_halign(fa_left);
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
