/// @description planet_coast(pn) - THE COASTS (his pick, 2026-09-18: "2" of the terrain list): the shores FRAYED - bays, spits and islets where the fields drew a smooth line - and ISLAND ARCS, chains of volcanic islands bowed off the continents
/// THE FRAY: near sea level (within .06 of it) the height takes a fine
/// noise on the sphere, two octaves (45 and 90 cells a radius), up to
/// .025 either way at the shore itself and nothing inland or at depth -
/// the coastline wanders, a bay here, a spit there, an islet off the point.
/// THE ARCS: one to three a world (hashed), each from a sea texel near a
/// coast, bowing away from that land on a constant curve for fourteen to
/// thirty texels, a cone every three to five - most breach the sea (an
/// island, a summit .02-.07 above it), a few stay under (a seamount: the
/// shallows and the coral the biome law gives a sea floor that near the
/// surface). The biome law runs again on every touched texel. Living
/// worlds only (the others have no sea); the stamps (a map under a hundred
/// wide) take the fray alone. Once a world, from planet_bake after the
/// ranges and before the volcanoes (so pn.elev0, the tier's heights, has it)
function planet_coast(_pn) {
	if (_pn[$ "coast"] ?? false) return;
	_pn.coast = true;
	if (_pn.kind == "gas" || _pn.arch != "terra") return;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _sc = _tw / 320, _sd = _pn.seed;
	var _el = _pn.elev, _bm = _pn.biome, _dt = _pn.det, _mo = _pn.moi, _ps = _pn.smp, _sea = _pn.sea;
	var _touch = array_create(_n, 0);
	// THE FRAY
	for (var _i = 0; _i < _n; _i++) {
		var _b = 1 - clamp(abs(_el[_i] - _sea) / .06, 0, 1);
		if (_b <= 0) continue;
		var _u = ((_i mod _tw) + .5) / _tw, _v = ((_i div _tw) + .5) / _th;
		var _nz = planet_vn3(_sd + 4010, _u, _v, 45) * .6 + planet_vn3(_sd + 4020, _u, _v, 90) * .4;
		_el[_i] += (_nz - .5) * .05 * _b * _b;
		_touch[_i] = 1;
	}
	// THE ARCS
	if (_tw >= 100) {
		var _na = 1 + (hash_mix(_sd, 4100) mod 3);
		for (var _k = 0; _k < _na; _k++) {
			var _b0 = 300 * _k, _sx = -1, _sy = -1, _lx = 0, _ly = 0;
			// the start: a sea texel with land within eight texels; the arc bows AWAY from that land
			for (var _t = 0; _t < 30 && _sx < 0; _t++) {
				var _cx = floor(((hash_mix(_sd, 4101 + _b0 + _t * 2) mod 10000) / 10000) * _tw), _cy = floor(_th * (.12 + .76 * ((hash_mix(_sd, 4102 + _b0 + _t * 2) mod 10000) / 10000)));
				if (_el[_cx + _cy * _tw] > _sea - .02) continue;
				var _cl0 = max(.2, sin(pi * (_cy + .5) / _th)), _fx = 0, _fy = 0, _fn = 0;
				for (var _dy = -8; _dy <= 8; _dy += 2) { var _ny = _cy + _dy; if (_ny < 0 || _ny >= _th) continue;
					for (var _dx = -8; _dx <= 8; _dx += 2) { var _nx = (((_cx + round(_dx / _cl0)) mod _tw) + _tw) mod _tw; if (_el[_nx + _ny * _tw] >= _sea) { _fx += _dx; _fy += _dy; _fn++; } } }
				if (_fn < 2) continue;
				_sx = _cx; _sy = _cy; _lx = _fx / _fn; _ly = _fy / _fn;   // (the land's mean offset: the arc runs across it, bowing away)
			}
			if (_sx < 0) continue;
			var _away = darctan2(-_ly, -_lx);                                                  // (the bearing away from the land)
			var _br = _away + 90 * ((hash_mix(_sd, 4150 + _b0) mod 2 == 0) ? 1 : -1);          // (the walk runs ALONG the coast, off it)
			var _cv = (.9 + 1.8 * ((hash_mix(_sd, 4151 + _b0) mod 10000) / 10000)) * ((hash_mix(_sd, 4152 + _b0) mod 2 == 0) ? 1 : -1);   // (degrees a texel of curve; bowing toward 'away' on the whole by the sign chosen below)
			if (sign(_cv) != sign(angle_difference(_away, _br))) _cv = -_cv;
			var _len = floor((14 + 16 * ((hash_mix(_sd, 4153 + _b0) mod 10000) / 10000)) * _sc), _gap = 3 + (hash_mix(_sd, 4154 + _b0) mod 3);
			var _px = _sx + .5, _py = _sy + .5, _since = _gap;
			for (var _s = 0; _s < _len; _s++) {
				var _cl = max(.2, sin(pi * clamp(_py, .5, _th - .5) / _th));
				_px += dcos(_br) / _cl; _py += dsin(_br); _br += _cv;   // (raw atan2 bearings, y down the map - as _away was taken)
				if (_py < 2 || _py > _th - 3) break;
				var _ix0 = (((floor(_px)) mod _tw) + _tw) mod _tw, _iy0 = floor(_py), _i0 = _ix0 + _iy0 * _tw;
				if (_el[_i0] >= _sea) break;   // (it ran into land)
				_since++;
				if (_since < _gap) continue;
				_since = 0;
				// THE CONE: a lift from the sea floor round it to a summit just above the sea (or just under: a seamount)
				var _hh = (hash_mix(_sd, 4200 + _b0 + _s) mod 10000) / 10000;
				var _rad = (1.6 + 1.6 * _hh) * _sc, _under = ((hash_mix(_sd, 4250 + _b0 + _s) mod 100) < 28);
				var _sum = _under ? (_sea - .008) : (_sea + .02 + .05 * ((hash_mix(_sd, 4300 + _b0 + _s) mod 10000) / 10000));
				var _r = ceil(_rad), _rx = min(_tw div 2, ceil(_rad / _cl));
				for (var _dy = -_r; _dy <= _r; _dy++) { var _yy = _iy0 + _dy; if (_yy < 0 || _yy >= _th) continue;
					for (var _dx = -_rx; _dx <= _rx; _dx++) {
						var _xx = (((_ix0 + _dx) mod _tw) + _tw) mod _tw, _i = _xx + _yy * _tw;
						var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy) / _rad;
						if (_d > 1) continue;
						var _l = _el[_i] + (_sum - _el[_i]) * power(1 - _d, 1.3) * (.9 + .2 * _dt[_i]);
						if (_l > _el[_i]) { _el[_i] = _l; _touch[_i] = 1; }
					}
				}
			}
		}
	}
	// the biome law again on the touched
	for (var _i = 0; _i < _n; _i++) {
		if (_touch[_i] == 0) continue;
		_ps.oe = _el[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		_bm[_i] = _ps.ob;
	}
}
