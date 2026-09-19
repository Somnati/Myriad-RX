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
	var _tu = _u + (planet_vn3(_sd + 13, _u, _v, 3.1) - .5) * _turb, _tv = _v + (planet_vn3(_sd + 14, _u, _v, 3.1) - .5) * _turb;
	var _w1 = (planet_vn3(_sd + 11, _u, _v, 2.4) - .5) * _wan + (planet_vn3(_sd + 12, _u, _v, 4.8) - .5) * _wan * .45;   // the wander
	var _w2 = (planet_vn3a(_sd + 23, _tu, _tv, 2.2, _shf) - .5) * _shr + (planet_vn3a(_sd + 24, _tu, _tv, 4.4, _shf * 2) - .5) * _shr * .5;   // the jets' streaks
	var _w3 = (planet_vn3(_sd + 37, _u, _v, 19) - .5) * .014;   // the marbling
	var _vv = _v + _w1 + _w2 + _w3;
	// the storms bend the bands round them, and trail a wake of eddies behind them (east, the flow's way)
	var _sl = sin(_v * pi), _px = _sl * cos(_u * 2 * pi), _py = cos(_v * pi), _pz = _sl * sin(_u * 2 * pi);
	var _sts = _ps.gstorms, _sn = array_length(_sts);
	for (var _k = 0; _k < _sn; _k++) {
		var _st = _sts[_k];
		var _asp = _st[$ "asp"] ?? 1.8;
		var _d = point_distance_3d(_px, _py, _pz, _st.x, _st.y, _st.z);
		if (_d > _st.r * _asp * 1.7) continue;
		// the storm's own frame on the sphere: east (along the band) and north (the meridian's tangent)
		var _ssl = max(.05, sqrt(_st.x * _st.x + _st.z * _st.z));
		var _ex = -_st.z / _ssl, _ez = _st.x / _ssl;
		var _nx = -_st.y * _ez, _ny = _ssl, _nz = _st.y * _ex;
		var _tx = _px - _st.x, _ty = _py - _st.y, _tz = _pz - _st.z;
		var _ea = (_tx * _ex + _tz * _ez) / (_st.r * _asp), _na = (_tx * _nx + _ty * _ny + _tz * _nz) / _st.r;   // the oval's coordinates: 1 at its edge
		var _q = sqrt(_ea * _ea + _na * _na);
		if (_st[$ "pearl"] ?? false) continue;
		var _th = arctan2(_na, _ea);
		_vv += (1 - min(1, _q)) * .05 * sin(_th * 2 + _q * 5) * _st.spin;
		if (_ea > 0 && abs(_na) < 1.3) _vv += .03 * exp(-_ea * .7) * sin(_na * 7 + _ea * 5) * _st.spin;
	}
	_vv = clamp(_vv, 0, .9999);
	// the streak filament: light and dark marbling along the streaks (kept - the tier interpolates it)
	var _f1 = (planet_vn3a(_sd + 41, _tu, _tv, 3.0, 26) - .5) * .9;
	_ps.om = _vv; _ps.od = _f1;
	return gas_paint(_ps, _u, _v, _vv, _f1);
}
