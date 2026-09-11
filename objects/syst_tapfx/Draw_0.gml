if (!__live()) exit;

// ---- glow (DE) ----
for (var _i = 0; _i < array_length(glows); _i++) {
	var _g = glows[_i];
	var _f = 1 - _g.t / 10;
	var _s = (_g.crit ? .30 : .20) * (1.2 - _f * .4);
	draw_sprite_ext(spr_vis_glow_soft, 0, _g.x, _g.y, _s, _s, 0,
		_g.crit ? c_gold : g.profit_color, .55 * _f);
}

// ---- shockwaves: one-cell rings, five ways (see the Create) ----
for (var _i = 0; _i < array_length(shocks); _i++) {
	var _sh = shocks[_i];
	if (_sh.r < .5) continue;                  // (a double's second ring, not yet born)
	var _rmax = _sh.crit ? 22 : 16;
	var _f = 1 - _sh.r / _rmax;
	var _kind = _sh.kind;
	var _split = (_kind == 1) ? 0 : round(2 * _f);
	var _steps = 12 + floor(_sh.r * 4);
	// the ring's radius at angle a: round, or wobbling, or a diamond
	var _pts = array_create(_steps * 2);
	for (var _k = 0; _k < _steps; _k++) {
		var _a = _k * 360 / _steps;
		var _rr = _sh.r;
		if (_kind == 3) _rr += 1.6 * dsin(_a * 3 + _sh.ph + _sh.r * 25) * (1 + _sh.r * .06);
		var _dx = lengthdir_x(_rr, _a), _dy = lengthdir_y(_rr, _a);
		if (_kind == 4) {
			// city-block: push the round point out to the diamond
			var _m = abs(_dx) + abs(_dy);
			if (_m > 0) { _dx *= _rr / _m; _dy *= _rr / _m; }
		}
		_pts[_k * 2]     = floor(_sh.x + _dx);
		_pts[_k * 2 + 1] = floor(_sh.y + _dy);
	}
	if (_split > 0) {
		gpu_set_blendmode(bm_add);
		for (var _k = 0; _k < _steps; _k++) {
			draw_sprite_ext(spr_pixel_1x1, 0, _pts[_k * 2] - _split, _pts[_k * 2 + 1], 1, 1, 0, c_red,  .55 * _f);
			draw_sprite_ext(spr_pixel_1x1, 0, _pts[_k * 2] + _split, _pts[_k * 2 + 1], 1, 1, 0, c_blue, .55 * _f);
		}
		gpu_set_blendmode(bm_normal);
	}
	var _thick = (_kind == 1) ? 2 : 1;
	for (var _k = 0; _k < _steps; _k++)
		draw_sprite_ext(spr_pixel_1x1, 0, _pts[_k * 2], _pts[_k * 2 + 1], _thick, _thick, 0,
			c_white, ((_kind == 1) ? .9 : .8) * _f);
}

// ---- the [fx] chip ----
var _r = __chip_r();
draw_set_font(fnt);
draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_black, .6);
draw_px_rect(_r.x, _r.y, _r.w, _r.h, c_white, .25);
draw_set_halign(fa_left);
draw_set_color(rgb(120, 130, 150));
draw_set_alpha(.8);
draw_text(_r.x + 4, _r.y + 2, "fx");
draw_set_color(c_gold);
draw_text(_r.x + 4 + string_width("fx  "), _r.y + 2, fx_names[__fx()]);
draw_set_alpha(1);
draw_set_color(c_white);
