/// @description planet_biome(ps, u, v) - the BIOME (ps.ob) from the fields planet_fields wrote (ps.oe / od / om) at a map coordinate
/// The half of planet_texel that decides (the tech demo's law, verbatim);
/// split out 2026-09-17 so the fields and the law can be read apart
function planet_biome(_ps, _u, _v) {
	var _sl  = sin(_v * pi);
	var _py  = cos(_v * pi);
	var _lon = _u * 2 * pi;
	var _px  = _sl * cos(_lon);
	var _pz  = _sl * sin(_lon);

	if (_ps.kind == "gas") {
		var _wrp = _ps.od;
		var _sw  = _ps.oe;
		var _vv  = clamp(_v + _wrp + (_sw - .5) * .05, 0, .999);
		var _b   = 0;
		var _bn  = array_length(_ps.bands);
		for (var _k = 0; _k < _bn; _k++)
			if (_vv >= _ps.bands[_k].v0) _b = _k;
		if (!is_undefined(_ps.storm)) {
			var _st = _ps.storm;
			if (point_distance_3d(_px, _py, _pz, _st.x, _st.y, _st.z) < _st.r) _b = _st.b;
		}
		_ps.ob = _b;
		// THE GIANT'S FACE (q236 / q238): the texel's colour, the sheet's rgb - the band index above stays for anything that
		// reads it. The base map bends the latitude and keeps it (om) with the streak filament (od); the zoom tier hands
		// those back INTERPOLATED (ps.tier) and gas_paint adds only the fine grain - nine times fewer noise reads
		_ps.oc = (_ps[$ "tier"] ?? false) ? gas_paint(_ps, _u, _v, _ps.om, _ps.od) : gas_colour(_ps, _u, _v);
		return;
	}

	// ---- rocky world ----
	var _lf  = 1 - abs(_v * 2 - 1); // 1 equator, 0 poles
	var _e   = _ps.oe;
	var _det = _ps.od;
	var _mraw = _ps.om;
	var _h = (_e - _ps.hbase) / max(.001, 1 - _ps.hbase) + (_det - .5) * .5;
	// THE ECOTONES (his pick, 2026-09-17): a grain of hashed jitter on the moisture and the warmth, so a biome's
	// border is a band where the two mingle, not a line. The grain lives on a 960 x 480 grid - THREE times the
	// map's - so the zoom tier's texels each have their own, and the base map's texel (the tier's middle one)
	// reads the very same grain as the tier does there: the two can never disagree
	var _jx = floor(_u * 960), _jy = floor(_v * 480);
	var _hj = ((_jx * 73856093) ^ (_jy * 19349663) ^ (_ps.o1 * 83492791)) & $7fffffff;
	_hj = ((_hj ^ (_hj >> 13)) * 48271) mod 2147483647;
	var _moi  = _mraw + _ps.mshift + ((_hj mod 1000) / 1000 - .5) * .08;
	// ...and ALTITUDE COOLS (his pick): high ground is colder - tundra on the flanks, snow on the crowns, whatever the latitude
	var _tmp = clamp(_lf * .85 + _det * .15 + _ps.theat + (((_hj div 1000) mod 1000) / 1000 - .5) * .05 - max(0, _h) * .3, 0, 1);

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
		// THE KINDS (his pick, 2026-09-17: more of them): 21 savanna (warm, between the desert and the grass), 22 taiga
		// (cold and wet: the conifer belt below the tundra), 23 badlands (high and bone dry), 24 dunes (low, hot, bone
		// dry), 25 coral shallows (the warm seas' shallows) - beside the old
		if (_e < _ps.sea - .05)      _b = 0;
		else if (_e < _ps.sea)       _b = (_e > _ps.sea - .028 && _tmp > .30) ? ((_tmp > .62 && _moi > .30) ? 25 : 11) : 1;
		else {
			if (_h > .34)            _b = (_tmp < .45) ? 10 : 9;
			else if (_tmp < .12)     _b = 14;
			else if (_tmp < .20)     _b = 8;
			else if (_tmp < .34)     _b = 7;
			else if (_tmp < .46 && _moi > .46) _b = 22;
			else if (_moi > .62 && _tmp > .45 && _e < _ps.sea + .07) _b = 12;
			else if (_moi < .18)     _b = (_tmp > .55 && _h > .16) ? 23 : ((_tmp > .60 && _h < .08 && _moi < .12) ? 24 : 3);
			else if (_moi < .40 && _tmp > .60) _b = (_moi >= .28) ? 21 : 3;
			else if (_moi > .60 && _tmp > .55) _b = 6;
			else if (_moi > .48)     _b = 5;
			else                     _b = 4;
			if (_e < _ps.sea + .012) _b = 2;
		}
		if ((_b <= 1 || _b == 11 || _b == 25) && _tmp < .16) _b = 8;

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
	_ps.ob = _b;
}
