/// the panel's face. Draw-only; the Step's hits share this geometry.
/// The battery dial's language in lavender: a disc, a moving liquid for
/// the fill, the count inside; everything is spr_pixel_1x1 stamps.
var _c   = g.ccore;
var _v   = ccore_values();
var _dim = rgb(120, 130, 150);
var _lc  = c_lavender;
var _on  = (_c.lv > 0);
// the fill, 0..1: what is in the well, or the cooldown's remainder
var _f = 0;
if (_c.st == 1 || _c.st == 2) _f = clamp(_c.xp / max(1, _v.cap), 0, 1);
if (_c.st == 3) _f = clamp(_c.xp / max(1, _c.cool_from), 0, 1);
var _gc = (_c.st == 3) ? c_sblue : _lc;   // the theme: lavender, blue while it cools

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
	draw_set_color(_lc);
	draw_set_alpha(.95);
	draw_text(6, hh + 5, "credit core");
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(room_width - 8, hh + 5, land ? "a slow well of credits - collect it by hand" : "collect by hand");
	draw_set_halign(fa_left);
	__part_end();
}

// ---- THE DIAL ----
if (__part(2) > 0) {
	var _cx = disc_cx, _cy = disc_cy, _R = disc_r;

	// a soft glow behind it, breathing as it fills, bright when full
	var _gs = (_R * 4.6) / sprite_get_width(spr_vis_glow_soft);
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_vis_glow_soft, 0, _cx, _cy, _gs, _gs, 0, _gc,
		.04 + .08 * glow * (.7 + .3 * abs(dsin(current_time * .25))));
	gpu_set_blendmode(bm_normal);

	// the interior: a dark rasterised disc
	for (var _dy = -_R; _dy <= _R; _dy++) {
		var _hw = sqrt(max(0, sqr(_R) - sqr(_dy)));
		draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx - _hw), floor(_cy + _dy),
			max(1, round(_hw * 2)), 1, 0, merge_colour(c_black, _gc, .06), .95);
	}

	// THE LIQUID (the battery's, in lavender): the fill line eases toward
	// the count, two waves, a lit crest, clipped to the circle
	liq_t += delta;
	var _target = _cy + _R - 2 * (_R - 5) * _f - 1;
	if (liq_lvl < 0) liq_lvl = _target;
	liq_lvl += (_target - liq_lvl) * min(1, .12 * delta);
	var _liq  = merge_colour(_gc, c_black, .35);
	var _liqb = merge_colour(_gc, c_black, .55);
	if (_on)
	for (var _pass = 0; _pass < 2; _pass++) {
		var _back = (_pass == 0);
		for (var _x = -_R + 2; _x < _R - 1; _x++) {
			var _hw = sqrt(max(0, sqr(_R - 2) - sqr(_x)));
			var _top = _cy - _hw, _bot = _cy + _hw;
			var _w = _back
				? liq_lvl - 1.5 + (1.6 * dsin(_x * 8 - liq_t * 1.9) + 1.0 * dsin(_x * 15 + liq_t * 1.3))
				: liq_lvl       + (1.8 * dsin(_x * 9 + liq_t * 2.4) + 1.1 * dsin(_x * 17 - liq_t * 1.6));
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

	// the ring: a dark gap inside a one-cell bright rim
	var _steps = round(_R * 6.3);
	for (var _k = 0; _k < _steps; _k++) {
		var _ra = _k * 360 / _steps;
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(_cx + lengthdir_x(_R - 2, _ra)), floor(_cy + lengthdir_y(_R - 2, _ra)), 1, 1, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(_cx + lengthdir_x(_R, _ra)), floor(_cy + lengthdir_y(_R, _ra)), 1, 1, 0,
			merge_colour(_gc, c_white, .3 * glow), .95);
	}

	// the count, big, the cap under it - or the cooldown's percent
	draw_set_halign(fa_center);
	if (!_on) {
		draw_set_color(_dim);
		draw_set_alpha(.7);
		draw_text(_cx, _cy - 3, "locked");
	} else if (_c.st == 3) {
		draw_set_font(fnt_large_outline);
		draw_set_color(c_white);
		draw_set_alpha(.95);
		draw_text(_cx, _cy - 6, string(floor(_f * 100)) + "%");
		draw_set_font(fnt);
		draw_set_color(merge_colour(c_white, _gc, .35));
		draw_set_alpha(.75);
		draw_text(_cx, _cy + 8, "cooling");
	} else {
		draw_set_font(fnt_large_outline);
		draw_set_color(c_white);
		draw_set_alpha(.95);
		draw_text(_cx, _cy - 6, string(floor(_c.xp)));
		draw_set_font(fnt);
		draw_set_color(merge_colour(c_white, _gc, .35));
		draw_set_alpha(.75);
		draw_text(_cx, _cy + 8, "/ " + string(_v.cap));
	}
	draw_set_halign(fa_left);

	// the collect's flush
	if (flash > 0)
		for (var _dy = -_R; _dy <= _R; _dy++) {
			var _hw = sqrt(max(0, sqr(_R) - sqr(_dy)));
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx - _hw), floor(_cy + _dy),
				max(1, round(_hw * 2)), 1, 0, _lc, .5 * flash);
		}
	__part_end();
}

// ---- the state line + the collect button ----
if (__part(3) > 0) {
	draw_set_halign(fa_center);
	if (!_on) {
		draw_set_color(_dim);
		draw_set_alpha(.7);
		draw_text(disc_cx, read_y, "buy the first level to light it");
	} else if (_c.st == 2) {
		draw_set_color(_lc);
		draw_set_alpha(.8 + .2 * abs(dsin(current_time * .3)));
		draw_text(disc_cx, read_y, "full - ready to collect");
	} else if (_c.st == 3) {
		draw_set_color(c_sblue);
		draw_set_alpha(.8);
		draw_text(disc_cx, read_y, "cooling down");
	} else {
		var _left = (_v.cap - _c.xp) / max(.0001, _v.gain);
		draw_set_color(c_white);
		draw_set_alpha(.85);
		draw_text(disc_cx, read_y, "filling - full in " + crunch_time_long(_left * 60));
	}
	// the well's lifetime, under the state line (his ask: the core's
	// stats - drawn credits and collects, saved with it)
	if (_on && (_c[$ "pulls"] ?? 0) > 0) {
		draw_set_halign(fa_center);
		draw_set_color(_dim);
		draw_set_alpha(.65);
		draw_text(disc_cx, btn_y + btn_h + 4, string(_c[$ "made"] ?? 0) + " drawn over " + string(_c.pulls)
			+ ((_c.pulls == 1) ? " collect" : " collects"));
	}
	draw_set_halign(fa_left);
	var _cb  = __col_r();
	var _can = (_c.st == 1 || _c.st == 2) && floor(_c.xp) >= 1;
	draw_ui_button(_cb.x, _cb.y, _cb.w, _cb.h,
		_can ? ("collect " + string(floor(_c.xp))) : ((_c.st == 3) ? "cooling" : "collect"),
		_can ? _lc : c_gray, _can, _can);
	__part_end();
}

// ---- THE BAND: a faint rule, the split slider, the level ladder ----
if (__part(4) > 0) {
	draw_sprite_ext(spr_pixel_1x1, 0, 8, band_y, room_width - 16, 1, 0, sett_ink, .18);
	var _sa = _on ? 1 : .35;

	// the split: how the levels divide between capacity and rate
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(sl_x, band_y + 6, "split  -  " + string(_v.cap_lv) + " to capacity, " + string(_v.gain_lv) + " to rate");
	var _sr = __sl_r();
	// THE KNOB POINTS AT WHAT GETS MORE (his report, 2026-09-14): capacity
	// is the left label, so the knob sits at 1 - split; the fill runs from
	// the middle (an even split) toward the knob, a bias bar
	var _fr = 1 - _c.split / 100;
	var _mid = _sr.x + _sr.w * .5, _kx = _sr.x + _sr.w * _fr;
	draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, c_black, .7 * _sa);
	draw_sprite_ext(spr_pixel_1x1, 0, min(_mid, _kx), _sr.y, abs(_kx - _mid), _sr.h, 0, _lc, .8 * _sa);
	draw_px_rect(_sr.x, _sr.y, _sr.w, _sr.h, _lc, .35 * _sa);
	draw_sprite_ext(spr_pixel_1x1, 0, floor(_mid), _sr.y - 1, 1, _sr.h + 2, 0, c_white, .3 * _sa);
	draw_sprite_ext(spr_pixel_1x1, 0, _kx - 1, _sr.y - 2, 3, _sr.h + 4, 0, c_white, .8 * _sa);
	draw_set_color(_on ? c_white : _dim);
	draw_set_alpha(.9 * _sa);
	draw_text(_sr.x, _sr.y + 8, "capacity");
	draw_set_halign(fa_right);
	draw_text(_sr.x + _sr.w, _sr.y + 8, "rate");
	draw_set_halign(fa_left);
	// what the split buys, under the track
	draw_set_color(_lc);
	draw_set_alpha(.85 * _sa);
	draw_text(_sr.x, _sr.y + 19, "holds " + string(_v.cap) + "  -  +" + string_format(_v.gain * 60, 1, 2)
		+ " a minute  -  fills in " + crunch_time_long(_v.mins * 60));

	// the level ladder: the level, and the next one's price
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(lv_x, lv_y, "level");
	draw_set_color(c_white);
	draw_set_alpha(.9);
	draw_text(lv_x, lv_y + 15, _on ? ("core lv " + string(_c.lv) + "  >  " + string(_c.lv + 1)) : "not lit yet");
	var _br   = __buy_r();
	var _cost = ccore_cost();
	var _ok   = (g.credits >= arb(_cost));
	draw_ui_button(_br.x, _br.y, _br.w, _br.h, string(_cost) + " cr", _ok ? _lc : c_gray, _ok, _ok);
	__part_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
