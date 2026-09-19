/// @description gas_paint(ps, u, v, vv, f1) -> the giant's colour at the map point u / v, given its BENT LATITUDE vv and streak filament f1 (gas_colour's, or the tier's interpolation of them) - THE PAINT (q238): the stops' gradient, the storms' anatomy, the pearls, the filaments, the pole caps
/// THE GREAT SPOT (his Jupiter reference, 2026-09-18): an oval long along
/// the band, its inside LAYERED - concentric tones winding in to a deeper
/// eye - a pale COLLAR on its poleward side (the hollow the spot sits in),
/// a pressed dark rim equatorward, and no white halo (the first cut's
/// "white blurry ring trying to be a spiral"). The PEARLS: a string of
/// small pale ovals along one band, the way Jupiter wears them
function gas_paint(_ps, _u, _v, _vv, _f1) {
	var _sd = _ps.gseed, _gw = _ps.gw;
	// the gradient: the two stops round the latitude, eased between
	var _gs = _ps.gstops, _gn = array_length(_gs), _k0 = 0;
	for (var _k = 0; _k < _gn; _k++) if (_vv >= _gs[_k].v) _k0 = _k;
	var _c0 = _gs[_k0].col, _c1 = _gs[min(_gn - 1, _k0 + 1)].col;
	var _t = (_k0 + 1 < _gn) ? clamp((_vv - _gs[_k0].v) / max(.0001, _gs[_k0 + 1].v - _gs[_k0].v), 0, 1) : 0;
	_t = _t * _t * (3 - 2 * _t);
	var _col = merge_colour(_c0, _c1, _t);
	// the storms and the pearls
	var _sl = sin(_v * pi), _px = _sl * cos(_u * 2 * pi), _py = cos(_v * pi), _pz = _sl * sin(_u * 2 * pi);
	var _sts = _ps.gstorms, _sn = array_length(_sts), _collar = 0, _rim = 0;
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
		if (_st[$ "pearl"] ?? false) {
			if (_q < 1) _col = merge_colour(_col, _st.col, power(1 - _q, .5) * .85);
			continue;
		}
		var _pw = ((_st.y >= 0) ? _na : -_na);   // (+ toward the pole the storm sits nearer)
		if (_q < 1) {
			var _in = power(1 - _q, .55);
			_col = merge_colour(_col, _st.col, _in * .92);
			var _rings = .5 + .5 * cos(_q * _q * 22 + _st.spin * 1.3);                                  // the layered inside, winding in
			_col = merge_colour(_col, ((_st[$ "eyel"] ?? 0) > 0) ? c_white : c_black, _rings * .10 * _in);
			var _eye = 1 - sstep(_q, .10, .34);                                                        // the deeper eye
			_col = merge_colour(_col, ((_st[$ "eyel"] ?? 0) > 0) ? c_white : c_black, _eye * .28);
		}
		_collar = max(_collar, exp(-sqr((_q - 1.14) / .17)) * (.30 + .70 * clamp(_pw, 0, 1)) * .30);   // the pale collar, poleward
		_rim    = max(_rim, clamp(1 - abs(_q - .97) / .11, 0, 1) * (.35 + .65 * clamp(-_pw, 0, 1)) * .24);   // the pressed rim, equatorward
	}
	// the filaments: the kept streak marbling, and the fine grain read here (the tier's own detail)
	var _f = _f1 + (planet_vn3(_sd + 42, _u, _v, 33) - .5) * .3;
	_col = merge_colour(_col, (_f > 0) ? c_white : c_black, clamp(abs(_f), 0, 1) * _gw.mar);
	// the pole caps (the temper's cap): the high latitudes darken or pale, as some giants' do
	if (_gw.cap > 0) { var _pc = power(clamp(abs(_v - .5) * 2, 0, 1), 3); _col = merge_colour(_col, (_gw.capd < 0) ? c_black : c_white, _pc * _gw.cap); }
	if (_collar > 0) _col = merge_colour(_col, c_white, clamp(_collar, 0, 1));
	if (_rim > 0) _col = merge_colour(_col, c_black, clamp(_rim, 0, 1));
	return _col;
}
