/// @description planet_plateaus(pn) - PLATEAUS AND CANYONS (his pick, 2026-09-18: "4" of the terrain list; "like the Grand Canyon... noticeably mountainous regarding its height, lots of depth"): a tableland lifted flat with a scarp round it, and where a river crosses it the river KEEPS ITS BED - the land rises round it into a gorge with terraced walls
/// The antecedent river, the way the real one was made: the plateau goes
/// up after the rivers have run (planet_bake, after planet_rivers), the
/// river holds its carved floor, so the gorge is the whole height of the
/// plateau (.15-.24 of the relief - a range is .30) with walls WITHIN two
/// or three texels, terraced: three benches, each ending in a cliff. Side
/// rivers cut their own, narrower. A living world takes one (two now and
/// then, none three times in ten), a barren world one in five twice, a
/// lava world none; the stamps (a map under a hundred wide) none. The site
/// is a great river's texel deep inland (a canyon wants a river), else the
/// levellest land; the bound is a wobbling blob (noise on the sphere) - a
/// butte or two stands off its edge on its own - and the scarp is the last
/// tenth of the radius. The lift goes into pn.elev AND pn.elev0 (the
/// tier's biome heights - else the tier would grass the top the map
/// rocks), and the biome law runs again on the lifted, on elev0, as the
/// tier's does. Hashed off the seed
function planet_plateaus(_pn) {
	if (_pn[$ "plateaus"] ?? false) return;
	_pn.plateaus = true;
	if (_pn.kind == "gas" || _pn.arch == "lava" || _pn.tw < 100) return;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _sc = _tw / 320, _sd = _pn.seed;
	var _hc = hash_mix(_sd, 4500) mod 100, _np = 0;
	if (_pn.arch == "barren") _np = (_hc < 40) ? 1 : 0;
	else _np = (_hc < 30) ? 0 : ((_hc < 85) ? 1 : 2);
	var _forced = (_pn[$ "plateau_ask"] ?? false);   // (a plateau asked for by the hint - at least one, on the biggest river there is; q210/q212)
	if (_forced) _np = max(1, _np);
	if (_np == 0) return;
	var _el = _pn.elev, _e0 = _pn[$ "elev0"], _bm = _pn.biome, _dt = _pn.det, _mo = _pn.moi, _ps = _pn.smp, _sea = _pn.sea;   // (elev0 exists only when the rivers ran - a world with no sea or all sea has none; the is_array guard below reads it, so the read here must not throw - live test fix 2)
	var _acc = _pn[$ "racc"], _rt = _pn[$ "rt"] ?? 6, _has_r = is_array(_acc);
	if (!is_array(_e0)) return;   // (no rivers ran: no elev0 to lift - nothing to do)
	var _touch = array_create(_n, 0);
	for (var _k = 0; _k < _np; _k++) {
		var _b = 400 * _k;
		// THE SITE: forty hashed tries; a great river's texel (twice the slice), inland (no sea within twelve texels), scores
		// high; level land scores; the best wins
		var _x = -1, _y = -1, _best = -1;
		for (var _t = 0; _t < 40; _t++) {
			var _cx = floor(((hash_mix(_sd, 4501 + _b + _t * 2) mod 10000) / 10000) * _tw), _cy = floor(_th * (.12 + .76 * ((hash_mix(_sd, 4502 + _b + _t * 2) mod 10000) / 10000)));
			var _ci = _cx + _cy * _tw;
			if (_el[_ci] < _sea + .02) continue;
			var _cl0 = max(.2, sin(pi * (_cy + .5) / _th)), _wet = false;
			for (var _a = 0; _a < 8 && !_wet; _a++) { var _px = (((_cx + round(dcos(_a * 45) * 12 / _cl0)) mod _tw) + _tw) mod _tw, _py = clamp(_cy + round(dsin(_a * 45) * 12), 0, _th - 1); if (_el[_px + _py * _tw] < _sea) _wet = true; }
			if (_wet) continue;
			var _hi2 = -9, _lo2 = 9;
			for (var _dy = -6; _dy <= 6; _dy += 3) for (var _dx = -6; _dx <= 6; _dx += 3) { var _ny = clamp(_cy + _dy, 0, _th - 1), _nx = ((_cx + _dx) mod _tw + _tw) mod _tw; var _ev = _el[_nx + _ny * _tw]; _hi2 = max(_hi2, _ev); _lo2 = min(_lo2, _ev); }
			var _river = (_has_r && _bm[_ci] == 11 && _acc[_ci] >= 2 * _rt) ? 1 : 0;
			var _s2 = _river * 3 + clamp(1 - (_hi2 - _lo2) / .15, 0, 1);
			if (_s2 > _best) { _best = _s2; _x = _cx; _y = _cy; }
		}
		// (asked for: the first plateau sits on the river texel with the greatest catchment that is inland - the canyon is the point)
		if (_forced && _k == 0 && _has_r) {
			var _ba = -1;
			for (var _i = 0; _i < _n; _i++) {
				if (_bm[_i] != 11 || _acc[_i] <= _ba) continue;
				var _cx = _i mod _tw, _cy = _i div _tw;
				if (_cy < _th * .12 || _cy > _th * .88) continue;
				var _cl0 = max(.2, sin(pi * (_cy + .5) / _th)), _wet = false;
				for (var _a = 0; _a < 8 && !_wet; _a++) { var _px = (((_cx + round(dcos(_a * 45) * 12 / _cl0)) mod _tw) + _tw) mod _tw, _py = clamp(_cy + round(dsin(_a * 45) * 12), 0, _th - 1); if (_el[_px + _py * _tw] < _sea) _wet = true; }
				if (_wet) continue;
				_ba = _acc[_i]; _x = _cx; _y = _cy;
			}
		}
		if (_x < 0) continue;
		var _R = (16 + 14 * ((hash_mix(_sd, 4550 + _b) mod 10000) / 10000)) * _sc, _H0 = .15 + .09 * ((hash_mix(_sd, 4551 + _b) mod 10000) / 10000);
		var _cl = max(.2, sin(pi * (_y + .5) / _th));
		var _r = ceil(_R * 1.3), _rx = min(_tw div 2, ceil(_R * 1.3 / _cl));
		// the region's mean height: the top stands H0 over it
		var _bs = 0, _bn = 0;
		for (var _dy = -_r; _dy <= _r; _dy += 3) { var _yy = _y + _dy; if (_yy < 0 || _yy >= _th) continue;
			for (var _dx = -_rx; _dx <= _rx; _dx += 3) { var _xx = (((_x + _dx) mod _tw) + _tw) mod _tw; if (sqrt(_dx * _dx * _cl * _cl + _dy * _dy) > _R) continue; _bs += _el[_xx + _yy * _tw]; _bn++; } }
		var _top = max(_sea + .03, _bs / max(1, _bn)) + _H0;
		// THE BOUND and the members: the blob's wobbling radius, the scarp over its last tenth; the rivers inside listed (the canyons)
		var _mem = [], _riv = [];
		for (var _dy = -_r; _dy <= _r; _dy++) { var _yy = _y + _dy; if (_yy < 0 || _yy >= _th) continue;
			for (var _dx = -_rx; _dx <= _rx; _dx++) {
				var _xx = (((_x + _dx) mod _tw) + _tw) mod _tw, _i = _xx + _yy * _tw;
				var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy);
				if (_d > _R * 1.3) continue;
				var _rb = _R * (.72 + .56 * planet_vn3(_sd + 4600 + _k, (_xx + .5) / _tw, (_yy + .5) / _th, 5));
				var _m = 1 - sstep(_d / max(1, _rb), .90, 1.0);
				if (_m <= 0.001) continue;
				if (_el[_i] < _sea) continue;
				var _bb = _bm[_i];
				if (_bb == 11 && _has_r && _acc[_i] >= _rt) { array_push(_riv, [_dx, _dy, _i, clamp(_acc[_i] / (6 * _rt), 0, 1)]); continue; }   // (a river: it keeps its bed - the canyon's floor)
				if (_bb == 1 || _bb == 0 || _bb == 25 || _bb == 11) continue;   // (the waters, and a shallows or a lesser river: never lifted; bug hunt 2026-09-18)
				array_push(_mem, [_dx, _dy, _i, _m]);
			}
		}
		// THE LIFT, with the CANYONS: a member near a river inside rises only to the wall's height at its distance - the
		// terraced convex curve from the river's bed to the top (three benches, each ending in a cliff)
		for (var _j = 0; _j < array_length(_mem); _j++) {
			var _mm = _mem[_j], _i = _mm[2], _m = _mm[3];
			var _tgt = _top + .012 * (_dt[_i] - .5);
			var _floor = -1, _wt = 1;
			for (var _q = 0; _q < array_length(_riv); _q++) {
				var _rv = _riv[_q], _ddx = (_mm[0] - _rv[0]) * _cl, _ddy = _mm[1] - _rv[1];
				var _W = (1.6 + 1.6 * _rv[3]) * _sc;   // (the half-width: a great river's gorge wider)
				var _dd = sqrt(_ddx * _ddx + _ddy * _ddy) / _W;
				if (_dd >= 1) continue;
				var _s3 = power(_dd, .55) * 3, _tr = (floor(_s3) + power(frac(_s3), 3.5)) / 3;   // (the terraces: a bench, then a cliff, three times)
				if (_tr < _wt) { _wt = _tr; _floor = _el[_rv[2]]; }
			}
			if (_floor >= 0) _tgt = _floor + (_tgt - _floor) * _wt;
			var _new = max(_el[_i], lerp(_el[_i], _tgt, _m));
			var _lift = _new - _el[_i];
			if (_lift <= 0) continue;
			_el[_i] = _new; _e0[_i] += _lift; _touch[_i] = 1;
		}
	}
	// the biome law again on the lifted, on the uncarved heights (as the tier decides its own)
	for (var _i = 0; _i < _n; _i++) {
		if (_touch[_i] == 0) continue;
		_ps.oe = _e0[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		_bm[_i] = _ps.ob;
	}
}
