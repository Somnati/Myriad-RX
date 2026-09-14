/// the panel's face. Draw-only; the Step's hits share this geometry.
/// THE DIAL (his inspiration, 2026-09-11): a ring, the percentage,
/// the charge as a liquid with a moving surface, the crank's handle on
/// the rim. Everything is spr_pixel_1x1 stamps - no primitives, ever,
/// under a shader (the input-layout lesson).
var _b   = g.battery;
var _cap = battery_cap();
var _dim = rgb(120, 130, 150);
var _f   = clamp(_b.charge / max(1, _cap), 0, 1);
var _low = (_f < .2);
var _gc  = _low ? c_hred : c_sgreen;                 // the theme: green, red when low
var _gl  = merge_colour(_gc, c_white, .3 * crank_glow);
var _cranking = (held || abs(vel) > .5);

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
	draw_set_color(c_feat_battery);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "battery");
	// the crank hint lives in the strip now (the band took the bottom)
	draw_set_halign(fa_right);
	draw_set_color(_cranking ? _gc : _dim);
	draw_set_alpha(_cranking ? .9 : .6);
	draw_text(room_width - 8, hh + 5, _cranking ? "cranking"
		: (land ? "turn the ring to fast charge" : "turn to charge"));
	draw_set_halign(fa_left);
	__part_end();
}

// ---- THE DIAL ----
if (__part(2) > 0) {
	var _cx = disc_cx, _cy = disc_cy, _R = disc_r;

	// a soft glow behind it, breathing while it cranks
	var _gs = (_R * 4.6) / sprite_get_width(spr_vis_glow_soft);
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_vis_glow_soft, 0, _cx, _cy, _gs, _gs, 0, _gc, .05 + .07 * crank_glow);
	gpu_set_blendmode(bm_normal);

	// the interior: a dark rasterised disc (the phone's - the liquid
	// lives in the dark, it does not flood the face)
	for (var _dy = -_R; _dy <= _R; _dy++) {
		var _hw = sqrt(max(0, sqr(_R) - sqr(_dy)));
		draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx - _hw), floor(_cy + _dy),
			max(1, round(_hw * 2)), 1, 0, merge_colour(c_black, _gc, .06), .95);
	}

	// ⚖️ THE LIQUID (his ask, then "improve the green liquid look"). A
	// TRANSLUCENT dark green, not a lime flood: the fill line eases
	// toward the charge (a crank's burst rises), and it never quite
	// reaches the top - at 100% a sliver of dark stays above the crest
	// so the surface is always there to read. Two waves: a dim back
	// one and the front one with a lit crest and a lighter band under
	// it for depth; both slosh harder while the crank turns. Column by
	// column, one stamp each, clipped to the circle
	liq_t += delta * (1 + min(abs(vel), 10) * .15);
	var _target = _cy + _R - 2 * (_R - 5) * _f - 1;
	if (liq_lvl < 0) liq_lvl = _target;
	liq_lvl += (_target - liq_lvl) * min(1, .12 * delta);
	var _amp = 1 + min(abs(vel), 10) * .25;
	var _liq  = merge_colour(_gc, c_black, .35);
	var _liqb = merge_colour(_gc, c_black, .55);
	for (var _pass = 0; _pass < 2; _pass++) {
		var _back = (_pass == 0);
		for (var _x = -_R + 2; _x < _R - 1; _x++) {
			var _hw = sqrt(max(0, sqr(_R - 2) - sqr(_x)));
			var _top = _cy - _hw, _bot = _cy + _hw;
			var _w = _back
				? liq_lvl - 1.5 + (1.6 * dsin(_x * 8 - liq_t * 1.9) + 1.0 * dsin(_x * 15 + liq_t * 1.3)) * _amp
				: liq_lvl       + (1.8 * dsin(_x * 9 + liq_t * 2.4) + 1.1 * dsin(_x * 17 - liq_t * 1.6)) * _amp;
			var _y0 = clamp(_w, _top, _bot);
			if (_y0 >= _bot) continue;
			var _yy = floor(_y0);
			var _hh2 = ceil(_bot) - _yy;
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx + _x), _yy, 1, _hh2, 0, _back ? _liqb : _liq, _back ? .5 : .62);
			if (!_back) {
				draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx + _x), _yy, 1, 1, 0, merge_colour(_gc, c_white, .4), .95);
				if (_hh2 > 2) draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx + _x), _yy + 1, 1, 1, 0, _gc, .45);
			}
		}
	}

	// the ring: a dark gap inside a one-cell bright rim, so it reads
	// as a ring whatever the liquid does under it
	var _steps = round(_R * 6.3);
	for (var _k = 0; _k < _steps; _k++) {
		var _ra = _k * 360 / _steps;
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(_cx + lengthdir_x(_R - 2, _ra)), floor(_cy + lengthdir_y(_R - 2, _ra)), 1, 1, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(_cx + lengthdir_x(_R, _ra)), floor(_cy + lengthdir_y(_R, _ra)), 1, 1, 0, _gl, .95);
	}
	// the eight notches the detents reel the handle into, just outside
	for (var _k = 0; _k < 8; _k++)
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(_cx + lengthdir_x(_R + 4, _k * 45)), floor(_cy + lengthdir_y(_R + 4, _k * 45)),
			1, 1, 0, _gc, (_k == 0) ? .8 : .3);
	// the crank's handle, riding the rim: a small knob, theme green
	// with a white heart, gold in the hand, white on a click
	var _hx = floor(_cx + lengthdir_x(_R, ang));
	var _hy = floor(_cy + lengthdir_y(_R, ang));
	var _kc = (crank_flash > 0) ? c_white : (held ? c_gold : _gc);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx - 2, _hy - 2, 5, 5, 0, _kc, .95);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx - 1, _hy - 3, 3, 7, 0, _kc, .95);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx - 3, _hy - 1, 7, 3, 0, _kc, .95);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx, _hy, 1, 1, 0, c_white, .9);

	// the bolt above the number, brighter while it cranks
	var _bx = floor(_cx), _by = floor(_cy - _R * .5);
	var _ba = .55 + .4 * crank_glow;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx + 1, _by,     2, 1, 0, _gc, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx,     _by + 1, 2, 1, 0, _gc, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx - 1, _by + 2, 3, 1, 0, _gc, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx,     _by + 3, 2, 1, 0, _gc, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx - 1, _by + 4, 2, 1, 0, _gc, _ba);

	// the percentage, big, the sign under it
	draw_set_halign(fa_center);
	draw_set_font(fnt_large_outline);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_cx, _cy - 6, string(floor(_f * 100)));
	draw_set_font(fnt);
	draw_set_color(merge_colour(c_white, _gc, .35));
	draw_set_alpha(.75);
	draw_text(_cx, _cy + 8, "%");
	draw_set_halign(fa_left);
	__part_end();
}

// ---- the two readouts, centred under the disc ----
if (__part(3) > 0) {
	var _need  = (_cap - _b.charge) / max(.001, battery_rate());
	var _lasts = battery_lasts();
	var _draw  = battery_draw();
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.9);
	draw_text(disc_cx, read_y, (_b.charge >= _cap - 1)
		? ("full  -  " + crunch_time_long(_cap * 60) + " of charge")
		: ("full in " + crunch_time_long(_need * 60)));
	draw_set_color(c_gold);
	draw_set_alpha(.85);
	draw_text(disc_cx, read_y + 11, (_draw <= 0) ? "nothing draws - it lasts forever"
		: ("lasts " + crunch_time_long(_lasts * 60) + " away" + ((_draw < .999) ? ("  (x" + string_format(_draw, 1, 2) + ")") : "")));
	draw_set_halign(fa_left);
	__part_end();
}

// ---- THE BAND: a faint rule, then the rates ----
if (__part(4) > 0) {
	draw_sprite_ext(spr_pixel_1x1, 0, 8, band_y, room_width - 16, 1, 0, sett_ink, .18);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(rate_x, rate_y - 11, "offline speed");
	var _a = g.autom;
	for (var _i = 0; _i < 3; _i++) {
		var _ry = rate_y + _i * rate_p;
		var _v  = _b.rate[$ rates[_i]];
		var _on = (_i == 0) ? _a.run.on : ((_i == 1) ? _a.fab.on
		        : (variable_global_exists("tiles") && g.tiles.automerge));
		var _sa = _on ? 1 : .4;
		draw_set_color(_on ? c_white : _dim);
		draw_set_alpha(.9 * _sa);
		draw_text(rate_x, _ry + 2, rate_lbl[_i]);
		var _t = __trk_r(_i);
		var _fr = clamp((_v - 5) / 95, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x, _t.y, _t.w, _t.h, 0, c_black, .7 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x, _t.y, _t.w * _fr, _t.h, 0, rate_col[_i], .8 * _sa);
		draw_px_rect(_t.x, _t.y, _t.w, _t.h, rate_col[_i], .35 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x + _t.w * _fr - 1, _t.y - 2, 3, _t.h + 4, 0, c_white, .8 * _sa);
		draw_set_color(_on ? c_white : _dim);
		draw_set_alpha(.9 * _sa);
		draw_text(_t.x + _t.w + 5, _ry + 2, string(_v) + "%" + ((_on || !land) ? "" : "  (off)"));
	}
	__part_end();
}

// ---- the two ladders ----
if (__part(5) > 0) {
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(upg_x, upg_y - 11, "upgrades");
	for (var _r = 0; _r < 2; _r++) {
		var _ry = upg_y + _r * upg_p;
		var _q  = (_r == 0) ? q_cap : q_rate;
		draw_set_color(c_white);
		draw_set_alpha(.9);
		if (_r == 0) {
			var _next = BAT_CAP0 * (1 + BAT_CAP_STEP * (_b.cap_lv + 1));
			draw_text(upg_x, _ry + 3, (land ? "capacity  " : "cap ") + crunch_time_long(_cap * 60) + " > " + crunch_time_long(_next * 60));
		} else {
			var _fill  = _cap / battery_rate();
			var _fill2 = _cap / ((BAT_CAP0 / BAT_FILL0) * (1 + BAT_RATE_STEP * (_b.rate_lv + 1)));
			draw_text(upg_x, _ry + 3, (land ? "speed  full in " : "spd ") + crunch_time_long(_fill * 60) + " > " + crunch_time_long(_fill2 * 60));
		}
		var _br = __btn_r(_r);
		draw_ui_button(_br.x, _br.y, _br.w, _br.h, string(_q.cost) + " cr",
			_q.ok ? c_sgreen : c_gray, _q.ok, _q.ok);
	}
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
