/// @description moon_tex() -> { t, c, h } the moons' shared textures: a cratered gray (MOON_TEX_W x MOON_TEX_H), a blank cloud, and its HEIGHT (the craters' depth - q206)
/// Baked once (kept in g.moon_tex_c - NOT g.moon_tex: a script function IS a global, so that name is the method itself; rebuilt when the gpu loses them): every
/// moon wears the same rock, tinted its own colour at the draw (moon_draw),
/// the tech demo's way. The craters are a few darker rings on value noise.
function moon_tex() {
	if (variable_global_exists("moon_tex_c") && is_struct(g.moon_tex_c) && surface_exists(g.moon_tex_c.t) && surface_exists(g.moon_tex_c.c) && surface_exists(g.moon_tex_c.h)) return g.moon_tex_c;
	var _w = MOON_TEX_W, _h = MOON_TEX_H;
	var _t = surface_create(_w, _h), _c = surface_create(1, 1), _hs = -1;
	var _sh = shader_current();
	if (_sh != -1) shader_reset();
	surface_set_target(_c); draw_clear_alpha(c_black, 0); surface_reset_target();
	// THE CRATERS WITH DEPTH (q206; his ask: "crater depths"): heights first - a plain at .34, twenty-six craters on a power
	// law (mostly small, a few big), each a flat floor sunk by its depth, a wall from half the radius to the rim, a rim
	// lip, an apron of ejecta, a peak in the big ones - into the HEIGHT sheet (red), which sh_planet marches as relief
	// (moon_draw sets u_relief and u_bump now); the colour from the height (floors dark, rims bright) on the old grain,
	// and bright RAYS out of the three biggest, the fresh ones
	var _hg = array_create(_w * _h, .34);
	var _cr = [];
	for (var _i = 0; _i < 26; _i++) {
		var _u = (hash_mix(77, _i * 5 + 2) mod 1000) / 1000;
		array_push(_cr, { x : (hash_mix(77, _i * 5) mod _w), y : 2 + (hash_mix(77, _i * 5 + 1) mod (_h - 4)), r : 1.3 + 9 * power(_u, 2.6), a0 : (hash_mix(77, _i * 5 + 3) mod 360) });
	}
	array_sort(_cr, function(_p, _q) { return _q.r - _p.r; });   // (the biggest first: the small ones cut into them)
	for (var _i = 0; _i < array_length(_cr); _i++) {
		var _c1 = _cr[_i], _D = .10 + .022 * _c1.r, _Rh = _D * .4, _pk = (_c1.r > 6) ? _D * .45 : 0;
		var _cl = max(.2, sin(pi * (_c1.y + .5) / _h)), _rr = ceil(_c1.r * 1.8), _rxx = min(_w div 2, ceil(_c1.r * 1.8 / _cl));
		for (var _dy = -_rr; _dy <= _rr; _dy++) { var _yy = _c1.y + _dy; if (_yy < 0 || _yy >= _h) continue;
			for (var _dx = -_rxx; _dx <= _rxx; _dx++) {
				var _xx = (((_c1.x + _dx) mod _w) + _w) mod _w, _j = _xx + _yy * _w;
				var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy) / _c1.r;
				if (_d > 1.8) continue;
				var _e = _hg[_j];
				if (_d <= 1) { _e = lerp(_e, .34, power(1 - _d, .6)); _e -= _D * (1 - sstep(_d, .5, 1)); _e += _pk * clamp(1 - _d / .18, 0, 1); }
				_e += _Rh * exp(-sqr((_d - 1) / .14));
				if (_d > 1) _e += _Rh * .3 * sqr(1 - (_d - 1) / .8);
				_hg[_j] = clamp(_e, .02, .98);
			}
		}
	}
	surface_set_target(_t);
	draw_clear_alpha(c_black, 1);
	gpu_set_blendmode(bm_normal);
	for (var _y = 0; _y < _h; _y++) for (var _x = 0; _x < _w; _x++) {
		var _n = (hash_mix(_x * 7 + 1, _y * 13 + 3) mod 1000) / 1000;
		var _v = 150 + (_n - .5) * 40 + (_hg[_x + _y * _w] - .34) * 210;
		// the rays: the three biggest craters, fresh - bright streaks out of them, a dozen a crater, fading with the distance
		for (var _i = 0; _i < 3; _i++) {
			var _c1 = _cr[_i], _cl = max(.2, sin(pi * (_c1.y + .5) / _h));
			var _ddx = _x - _c1.x; if (_ddx > _w * .5) _ddx -= _w; if (_ddx < -_w * .5) _ddx += _w;
			var _ddy = _y - _c1.y, _d = sqrt(_ddx * _ddx * _cl * _cl + _ddy * _ddy) / _c1.r;
			if (_d < 1.05 || _d > 4.5) continue;
			var _ang = darctan2(_ddy, _ddx * _cl) + _c1.a0;
			var _ray = power(max(0, dcos(_ang * 7)), 14) * (1 - (_d - 1.05) / 3.45);
			_v += 55 * _ray;
		}
		_v = clamp(round(_v), 30, 235);
		draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, 1, 1, 0, make_colour_rgb(_v, _v, _v), 1);
	}
	surface_reset_target();
	// the height sheet: red = the height, the plain at .34 (a bowl sits below it, a rim above); no water, no woods
	_hs = surface_create(_w, _h);
	surface_set_target(_hs);
	draw_clear_alpha(c_black, 1);
	gpu_set_blendmode_ext(bm_one, bm_zero);
	for (var _y = 0; _y < _h; _y++) for (var _x = 0; _x < _w; _x++) draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, 1, 1, 0, make_colour_rgb(floor(_hg[_x + _y * _w] * 255), 0, 0), 1);
	gpu_set_blendmode(bm_normal);
	surface_reset_target();
	if (_sh != -1) shader_set(_sh);
	g.moon_tex_c = { t : _t, c : _c, h : _hs };
	return g.moon_tex_c;
}
