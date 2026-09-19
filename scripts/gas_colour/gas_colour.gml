/// @description gas_colour(ps, u, v) -> the giant's colour at the map point u / v (a GM colour), and the two fields the zoom tier interpolates left on ps (om = the BENT LATITUDE, od = the streak filament) - THE GIANT'S FACE (q236 / q238; his references: Universe Sandbox, Spiritus, Jupiter)
/// The latitude the palette's stops are read at is BENT: a slow wander
/// (the temper's wan), zonal shear (planet_vn3a squashed along the spin
/// axis - the jets' streaks; shr / shf), turbulence (the streaks' own
/// point bent by the wander - the marble's curl; turb), fine marbling; the
/// storms bend the bands round them and trail a WAKE of eddies eastward.
/// gas_paint lays the colour on that latitude. Called a texel of the base
/// map; the tier reads the kept fields and gas_paint alone - no allocation
function gas_colour(_ps, _u, _v) {
	var _sd = _ps.gseed, _gw = _ps.gw;
	var _wan = _gw.wan, _shr = _gw.shr, _shf = _gw.shf, _turb = _gw.turb;
	// THE VORTICES FIRST (q239): every storm turns the map point round its eye - the twist a hashed number of turns at the
	// eye, easing to nothing at 1.35 ovals out - and two eddies in its wake turn the other way, smaller. Everything below
	// (the wander, the streaks, the marbling, the gradient) is read at the TURNED point, so what winds into the spot is the
	// bands themselves. The turn is in the storm's own frame (east along the band, north up the meridian) and comes back
	// as a shift of latitude and longitude; inside a tenth of an oval the twist is held (the eye's paint covers it)
	var _sl = sin(_v * pi), _px = _sl * cos(_u * 2 * pi), _py = cos(_v * pi), _pz = _sl * sin(_u * 2 * pi);
	var _uu = _u, _vw = _v;
	var _sts = _ps.gstorms, _sn = array_length(_sts);
	for (var _k = 0; _k < _sn; _k++) {
		var _st = _sts[_k];
		if (_st[$ "pearl"] ?? false) continue;
		var _asp = _st[$ "asp"] ?? 1.8, _turns = _st[$ "turns"] ?? 1.6;
		var _d = point_distance_3d(_px, _py, _pz, _st.x, _st.y, _st.z);
		if (_d > _st.r * _asp * 4.2) continue;
		var _ssl = max(.05, sqrt(_st.x * _st.x + _st.z * _st.z));
		var _ex = -_st.z / _ssl, _ez = _st.x / _ssl;
		var _nx = -_st.y * _ez, _ny = _ssl, _nz = _st.y * _ex;
		var _tx = _px - _st.x, _ty = _py - _st.y, _tz = _pz - _st.z;
		var _ea = (_tx * _ex + _tz * _ez) / (_st.r * _asp), _na = (_tx * _nx + _ty * _ny + _tz * _nz) / _st.r;
		// the storm's own turn, then its two wake eddies (east of it, alternating, smaller and slower)
		for (var _w = 0; _w < 3; _w++) {
			var _cx = (_w == 0) ? 0 : ((_w == 1) ? 1.9 : 3.1), _cy = (_w == 0) ? 0 : ((_w == 1) ? .45 : -.35);
			var _wr = (_w == 0) ? 1 : ((_w == 1) ? .55 : .42), _wt = (_w == 0) ? _turns : ((_w == 1) ? -_turns * .45 : _turns * .3);
			var _dx = (_ea - _cx) / _wr, _dy = (_na - _cy) / _wr, _q = sqrt(_dx * _dx + _dy * _dy);
			if (_q > 1.35) continue;
			var _qq = max(_q, .10);
			var _th = _st.spin * _wt * 2 * pi * power(1 - _qq / 1.35, 1.7);
			var _c = cos(_th), _s = sin(_th);
			var _rx = _dx * _c - _dy * _s, _ry = _dx * _s + _dy * _c;
			var _ddx = (_rx - _dx) * _wr, _ddy = (_ry - _dy) * _wr;   // (in oval units)
			// back to the map: north is latitude (v runs down, so minus), east is longitude by the cosine of the latitude
			_vw -= _ddy * _st.r / pi;
			_uu += _ddx * _st.r * _asp / (2 * pi * max(.15, _sl));
		}
	}
	var _tu = _uu + (planet_vn3(_sd + 13, _uu, _vw, 3.1) - .5) * _turb, _tv = _vw + (planet_vn3(_sd + 14, _uu, _vw, 3.1) - .5) * _turb;
	var _w1 = (planet_vn3(_sd + 11, _uu, _vw, 2.4) - .5) * _wan + (planet_vn3(_sd + 12, _uu, _vw, 4.8) - .5) * _wan * .45;   // the wander
	var _w2 = (planet_vn3a(_sd + 23, _tu, _tv, 2.2, _shf) - .5) * _shr + (planet_vn3a(_sd + 24, _tu, _tv, 4.4, _shf * 2) - .5) * _shr * .5;   // the jets' streaks
	var _w3 = (planet_vn3(_sd + 37, _uu, _vw, 19) - .5) * .014;   // the marbling
	var _vv = clamp(_vw + _w1 + _w2 + _w3, 0, .9999);
	// the streak filament: light and dark marbling along the streaks (kept - the tier interpolates it)
	var _f1 = (planet_vn3a(_sd + 41, _tu, _tv, 3.0, 26) - .5) * .9;
	_ps.om = _vv; _ps.od = _f1;
	return gas_paint(_ps, _u, _v, _vv, _f1);
}
