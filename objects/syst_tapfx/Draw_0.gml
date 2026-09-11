if (!__live()) exit;

// ---- glow (DE) ----
for (var _i = 0; _i < array_length(glows); _i++) {
	var _g = glows[_i];
	var _f = 1 - _g.t / 10;
	var _s = (_g.crit ? .30 : .20) * (1.2 - _f * .4);
	draw_sprite_ext(spr_vis_glow_soft, 0, _g.x, _g.y, _s, _s, 0,
		_g.crit ? c_gold : g.profit_color, .55 * _f);
}

// ---- shockwaves: one-cell rings, mono or chroma (see the Create) ----
for (var _i = 0; _i < array_length(shocks); _i++) {
	var _sh = shocks[_i];
	var _rmax = _sh.crit ? 16 : 12;
	var _f = 1 - _sh.r / _rmax;
	var _kind = _sh.kind;
	var _split = (_kind == 1) ? 0 : round(2 * _f);
	var _steps = 12 + floor(_sh.r * 4);
	var _pts = array_create(_steps * 2);
	for (var _k = 0; _k < _steps; _k++) {
		var _a = _k * 360 / _steps;
		_pts[_k * 2]     = floor(_sh.x + lengthdir_x(_sh.r, _a));
		_pts[_k * 2 + 1] = floor(_sh.y + lengthdir_y(_sh.r, _a));
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

// ---- the second batch (see the Create) - every mark is a whole cell ----
for (var _i = 0; _i < array_length(fxs); _i++) {
	var _e = fxs[_i];
	switch (_e.kind) {

	case "star": {
		// dashes flying out: each is `len` cells laid along its heading,
		// the head at r0 + t x speed, fading with life
		var _f = 1 - _e.t / 8;
		var _len = (_e.n == 4) ? 4 : 3;
		var _r0 = 2 + _e.t * 1.5;
		for (var _k = 0; _k < _e.n; _k++) {
			var _a = _e.a0 + _k * 360 / _e.n;
			for (var _c = 0; _c < _len; _c++) {
				var _rr = _r0 + _c;
				draw_sprite_ext(spr_pixel_1x1, 0,
					floor(_e.x + lengthdir_x(_rr, _a)), floor(_e.y + lengthdir_y(_rr, _a)),
					1, 1, 0, (_c == _len - 1) ? c_white : _e.col, .9 * _f);
			}
		}
		break;
	}

	case "square": {
		// the perimeter of a square of half-side r, one cell thick
		var _rmax = _e.crit ? 16 : 12;
		var _f = 1 - _e.r / _rmax;
		var _hr = floor(_e.r);
		for (var _k = -_hr; _k <= _hr; _k++) {
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_e.x) + _k, floor(_e.y) - _hr, 1, 1, 0, c_white, .85 * _f);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_e.x) + _k, floor(_e.y) + _hr, 1, 1, 0, c_white, .85 * _f);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_e.x) - _hr, floor(_e.y) + _k, 1, 1, 0, c_white, .85 * _f);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_e.x) + _hr, floor(_e.y) + _k, 1, 1, 0, c_white, .85 * _f);
		}
		break;
	}

	case "implode": {
		// a ring closing on the tap, brightening as it lands, then a dot
		if (_e.r > .5) {
			var _rmax = _e.crit ? 16 : 12;
			var _f = 1 - _e.r / _rmax;            // 0 far, 1 at the centre
			var _steps = 12 + floor(_e.r * 4);
			for (var _k = 0; _k < _steps; _k++) {
				var _a = _k * 360 / _steps;
				draw_sprite_ext(spr_pixel_1x1, 0,
					floor(_e.x + lengthdir_x(_e.r, _a)), floor(_e.y + lengthdir_y(_e.r, _a)),
					1, 1, 0, merge_colour(_e.col, c_white, _f), .35 + .6 * _f);
			}
		} else {
			// the pop: a 3x3 flash that fades over the last three frames
			var _pa = clamp((_e.r + 3) / 3, 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_e.x) - 1, floor(_e.y) - 1, 3, 3, 0, c_white, _pa);
		}
		break;
	}

	case "echo": {
		if (_e.r < .5) break;                     // not born yet
		var _rmax = _e.crit ? 16 : 12;
		var _f = 1 - _e.r / _rmax;
		var _steps = 12 + floor(_e.r * 4);
		for (var _k = 0; _k < _steps; _k++) {
			var _a = _k * 360 / _steps;
			draw_sprite_ext(spr_pixel_1x1, 0,
				floor(_e.x + lengthdir_x(_e.r, _a)), floor(_e.y + lengthdir_y(_e.r, _a)),
				1, 1, 0, c_white, .6 * _f);
		}
		break;
	}

	case "dust": {
		// puffs drifting out on their own headings, slowing, dying
		var _f = 1 - _e.t / 18;
		for (var _k = 0; _k < array_length(_e.puffs); _k++) {
			var _p = _e.puffs[_k];
			var _d = _p.s * _e.t * (1 - _e.t / 40);   // eases off as it goes
			draw_sprite_ext(spr_pixel_1x1, 0,
				floor(_e.x + lengthdir_x(_d, _p.a)) - 1, floor(_e.y + lengthdir_y(_d, _p.a)) - 1,
				2, 2, 0, merge_colour(_e.col, c_black, .3), .55 * _f);
		}
		break;
	}

	case "bolt": {
		// the jagged line, cell by cell along each segment; white for the
		// first two frames, the profit colour dimming after
		var _white = (_e.t < 2);
		var _f = 1 - _e.t / 5;
		var _n = array_length(_e.pts) div 2;
		for (var _k = 0; _k < _n - 1; _k++) {
			var _x0 = _e.pts[_k * 2], _y0 = _e.pts[_k * 2 + 1];
			var _x1 = _e.pts[_k * 2 + 2], _y1 = _e.pts[_k * 2 + 3];
			var _steps = max(1, ceil(point_distance(_x0, _y0, _x1, _y1)));
			for (var _c = 0; _c <= _steps; _c++) {
				var _q = _c / _steps;
				draw_sprite_ext(spr_pixel_1x1, 0,
					floor(lerp(_x0, _x1, _q)), floor(lerp(_y0, _y1, _q)), 1, 1, 0,
					_white ? c_white : _e.col, _white ? 1 : .8 * _f);
			}
		}
		break;
	}

	case "checker": {
		// 5x5 about the tap, alternating, each cell alive until its own
		// death frame - the board dissolving rather than fading
		for (var _k = 0; _k < 25; _k++) {
			if (_e.t >= _e.die[_k]) continue;
			var _cx = _k mod 5 - 2, _cy = _k div 5 - 2;
			var _odd = ((_cx + _cy) & 1) == 1;
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_e.x) + _cx, floor(_e.y) + _cy, 1, 1, 0,
				_odd ? _e.col : c_white, _odd ? .8 : .95);
		}
		break;
	}
	}
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
