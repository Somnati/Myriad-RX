/// @description planet_texel(ps, u, v) - one texel of planet terrain
/// (the tech demo's scr_planet_texel, verbatim): writes ps.oe
/// (elevation) and ps.ob (biome index). Runs thousands of times per
/// world - no allocation.
function planet_texel(_ps, _u, _v) {
	var _sl  = sin(_v * pi);
	var _py  = cos(_v * pi);
	var _lon = _u * 2 * pi;
	var _px  = _sl * cos(_lon);
	var _pz  = _sl * sin(_lon);

	if (_ps.kind == "gas") {
		var _wrp = (_ps.ctx.fbm3(_px * 2.6, _py * 2.6, _pz * 2.6, _ps.o1, 2) - .5) * .14;
		var _sw  = _ps.ctx.fbm3(_px * 5.2, _py * 5.2, _pz * 5.2, _ps.o2, 2);
		var _vv  = clamp(_v + _wrp + (_sw - .5) * .05, 0, .999);
		var _b   = 0;
		var _bn  = array_length(_ps.bands);
		for (var _k = 0; _k < _bn; _k++)
			if (_vv >= _ps.bands[_k].v0) _b = _k;
		if (!is_undefined(_ps.storm)) {
			var _st = _ps.storm;
			if (point_distance_3d(_px, _py, _pz, _st.x, _st.y, _st.z) < _st.r) _b = _st.b;
		}
		_ps.oe = _sw;
		_ps.ob = _b;
		return;
	}

	// ---- rocky world ----
	var _lf  = 1 - abs(_v * 2 - 1); // 1 equator, 0 poles
	var _e   = _ps.ctx.fbm3(_px * 2.3, _py * 2.3, _pz * 2.3, _ps.o1, 3);
	var _det = _ps.ctx.fbm3(_px * 6.1, _py * 6.1, _pz * 6.1, _ps.o2, 2);
	var _mraw = _ps.ctx.fbm3(_px * 3.2, _py * 3.2, _pz * 3.2, _ps.o3, 2);
	var _moi  = _mraw + _ps.mshift;
	var _tmp = clamp(_lf * .85 + _det * .15 + _ps.theat, 0, 1);
	var _h = (_e - _ps.hbase) / max(.001, 1 - _ps.hbase) + (_det - .5) * .5;

	var _b;
	if (_ps.arch == "lava") {
		if (_e < .34)                      _b = 18;
		else if (abs(_mraw * 2 - 1) < .07) _b = 18;
		else if (_h > .34)                 _b = 9;
		else                               _b = 17;
	} else if (_ps.arch == "barren") {
		if (_h > .34)      _b = 9;
		else if (_e < .36) _b = 13;
		else               _b = 3;
		var _cn = array_length(_ps.craters);
		for (var _k = 0; _k < _cn; _k++) {
			var _c  = _ps.craters[_k];
			var _dd = point_distance_3d(_px, _py, _pz, _c.x, _c.y, _c.z);
			if (_dd < _c.r) { _b = (_dd < _c.r * .68) ? 15 : 16; break; }
		}
	} else {
		if (_e < _ps.sea - .05)      _b = 0;
		else if (_e < _ps.sea)       _b = (_e > _ps.sea - .028 && _tmp > .30) ? 11 : 1;
		else {
			if (_h > .34)            _b = (_tmp < .45) ? 10 : 9;
			else if (_tmp < .12)     _b = 14;
			else if (_tmp < .20)     _b = 8;
			else if (_tmp < .34)     _b = 7;
			else if (_moi > .62 && _tmp > .45 && _e < _ps.sea + .07) _b = 12;
			else if (_moi < .18)     _b = 3;
			else if (_moi < .40 && _tmp > .60) _b = 3;
			else if (_moi > .60 && _tmp > .55) _b = 6;
			else if (_moi > .48)     _b = 5;
			else                     _b = 4;
			if (_e < _ps.sea + .012) _b = 2;
		}
		if ((_b <= 1 || _b == 11) && _tmp < .16) _b = 8;

		// the pixel cities: a street grid in each city's tangent frame
		if (!is_undefined(_ps[$ "cities"]))
		if (_b > 2 && _b != 8 && _b != 9 && _b != 10 && _b != 14) {
			var _cn9 = array_length(_ps.cities);
			for (var _k9 = 0; _k9 < _cn9; _k9++) {
				var _ct9 = _ps.cities[_k9];
				var _dd9 = point_distance_3d(_px, _py, _pz, _ct9.x, _ct9.y, _ct9.z);
				if (_dd9 > _ct9.r) continue;
				var _hl9 = sqrt(_ct9.x * _ct9.x + _ct9.z * _ct9.z);
				var _ex9 = 1, _ez9 = 0;
				if (_hl9 > .01) { _ex9 = _ct9.z / _hl9; _ez9 = -_ct9.x / _hl9; }
				var _du9 = (_px - _ct9.x) * _ex9 + (_pz - _ct9.z) * _ez9;
				var _dv9 = (_px - _ct9.x) * _ct9.y * _ez9
					+ (_py - _ct9.y) * (_ct9.z * _ex9 - _ct9.x * _ez9)
					+ (_pz - _ct9.z) * (-_ct9.y * _ex9);
				var _gx9 = floor(_du9 / .05);
				var _gy9 = floor(_dv9 / .05);
				var _bh9 = _ps.ctx.h3(_gx9, _gy9, _k9 * 17 + 5, _ps.o2 + 733);
				if (_dd9 > _ct9.r * (.40 + .60 * _bh9)) continue;
				var _fx9 = _du9 / .05 - _gx9;
				var _fy9 = _dv9 / .05 - _gy9;
				if (_fx9 < .32 || _fy9 < .32) _b = 19;
				else _b = (_bh9 > .30) ? 20 : 19;
				break;
			}
		}
	}
	_ps.oe = _e;
	_ps.ob = _b;
}
