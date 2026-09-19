/// @description gas_colour(ps, u, v) -> the giant's colour at the map point u / v (a GM colour) - THE GIANT'S FACE (q236; his references, 2026-09-18: Universe Sandbox's candy marbles, Spiritus's pastel swirls)
/// A smooth gradient of the palette's STOPS (ps.gstops: { v, col } up the
/// latitude) read at a latitude BENT three ways - a slow warp (the bands
/// wander), zonal shear (planet_vn3a, squashed along the spin axis: the
/// streaks jets draw), fine marbling - then storm ovals (ps.gstorms) that
/// bend the bands round them and wear their own colour with a spiral and
/// a bright rim, and a marbled light / dark filament on top. Every noise
/// hangs off the seed and the map point, so the zoom tier reads the same
/// face three times finer, not a blur of it. Called thousands of times a
/// world - no allocation
function gas_colour(_ps, _u, _v) {
	var _sd = _ps.gseed, _gw = _ps.gw;
	var _wan = _gw.wan, _shr = _gw.shr, _shf = _gw.shf, _mar = _gw.mar, _turb = _gw.turb;
	// THE TURBULENCE (the temper's turb): the point the streaks are read at is itself bent by the wander - domain warping,
	// the curl of a marble - a calm giant has none, a churned one folds its bands into eddies
	var _tu = _u + (planet_vn3(_sd + 13, _u, _v, 3.1) - .5) * _turb, _tv = _v + (planet_vn3(_sd + 14, _u, _v, 3.1) - .5) * _turb;
	var _w1 = (planet_vn3(_sd + 11, _u, _v, 2.4) - .5) * _wan + (planet_vn3(_sd + 12, _u, _v, 4.8) - .5) * _wan * .45;   // the wander
	var _w2 = (planet_vn3a(_sd + 23, _tu, _tv, 2.2, _shf) - .5) * _shr + (planet_vn3a(_sd + 24, _tu, _tv, 4.4, _shf * 2) - .5) * _shr * .5;   // the jets' streaks
	var _w3 = (planet_vn3(_sd + 37, _u, _v, 19) - .5) * .014;   // the marbling
	var _vv = _v + _w1 + _w2 + _w3;
	// the storms: the bands bend round each, its own colour inside with a spiral, a bright rim
	var _sl = sin(_v * pi), _px = _sl * cos(_u * 2 * pi), _py = cos(_v * pi), _pz = _sl * sin(_u * 2 * pi);
	var _sts = _ps.gstorms, _sn = array_length(_sts), _scol = -1, _smix = 0, _srim = 0;
	for (var _k = 0; _k < _sn; _k++) {
		var _st = _sts[_k];
		var _d = point_distance_3d(_px, _py, _pz, _st.x, _st.y, _st.z);
		if (_d > _st.r * 1.35) continue;
		var _q = _d / _st.r;
		// the angle round the storm's eye (its own tangents)
		var _ex = 0, _ey = 1, _ez = 0;
		if (abs(_st.y) > .9) { _ex = 1; _ey = 0; }
		var _e1x = _st.y * _ez - _st.z * _ey, _e1y = _st.z * _ex - _st.x * _ez, _e1z = _st.x * _ey - _st.y * _ex;
		var _e1l = max(.0001, sqrt(_e1x * _e1x + _e1y * _e1y + _e1z * _e1z)); _e1x /= _e1l; _e1y /= _e1l; _e1z /= _e1l;
		var _e2x = _st.y * _e1z - _st.z * _e1y, _e2y = _st.z * _e1x - _st.x * _e1z, _e2z = _st.x * _e1y - _st.y * _e1x;
		var _tx = _px - _st.x, _ty = _py - _st.y, _tz = _pz - _st.z;
		var _th = arctan2(_tx * _e2x + _ty * _e2y + _tz * _e2z, _tx * _e1x + _ty * _e1y + _tz * _e1z);
		_vv += (1 - min(1, _q)) * .045 * sin(_th * 2 + _q * 5) * _st.spin;   // (the bands bend round the eye)
		if (_q < 1) {
			var _in = power(1 - _q, .8);
			var _spiral = .5 + .5 * sin(_th * 2 + _q * 11 * _st.spin);
			var _m = _in * (.55 + .35 * _spiral);
			if (_m > _smix) { _smix = _m; _scol = _st.col; }
		}
		_srim = max(_srim, (1 - abs(_q - 1) / .22) * .32);   // (the rim, either side of the eye's edge)
	}
	_vv = clamp(_vv, 0, .9999);
	// the gradient: the two stops round the latitude, eased between
	var _gs = _ps.gstops, _gn = array_length(_gs), _k0 = 0;
	for (var _k = 0; _k < _gn; _k++) if (_vv >= _gs[_k].v) _k0 = _k;
	var _c0 = _gs[_k0].col, _c1 = _gs[min(_gn - 1, _k0 + 1)].col;
	var _t = (_k0 + 1 < _gn) ? clamp((_vv - _gs[_k0].v) / max(.0001, _gs[_k0 + 1].v - _gs[_k0].v), 0, 1) : 0;
	_t = _t * _t * (3 - 2 * _t);
	var _col = merge_colour(_c0, _c1, _t);
	if (_smix > 0) _col = merge_colour(_col, _scol, min(1, _smix));
	// the filaments: a light and a dark marbling along the streaks, and a fine grain
	var _f = (planet_vn3a(_sd + 41, _tu, _tv, 3.0, 26) - .5) * .9 + (planet_vn3(_sd + 42, _u, _v, 33) - .5) * .3;
	_col = merge_colour(_col, (_f > 0) ? c_white : c_black, clamp(abs(_f), 0, 1) * _mar);
	// the pole caps (the temper's cap): the high latitudes darken or pale, as some giants' do
	if (_gw.cap > 0) { var _pc = power(clamp(abs(_v - .5) * 2, 0, 1), 3); _col = merge_colour(_col, (_gw.capd < 0) ? c_black : c_white, _pc * _gw.cap); }
	if (_srim > 0) _col = merge_colour(_col, c_white, clamp(_srim, 0, 1));
	return _col;
}
