/// @description planet_gen_step(pn, [rows]) -> true once the maps are
/// complete. Samples `rows` more rows of the world's equirect map
/// (planet_texel for terrain, the puffs + belts for cloud cover). Spread
/// over frames by the caller so a world arrives without a hitch.
function planet_gen_step(_pn, _rows = undefined, _until = infinity) {   // (until: a get_timer deadline the row's texels answer to - q294: a row is 44 ms of noise, a "millisecond a frame" builder hitched by the row)
	if (_pn.row >= _pn.th) return true;
	if (is_undefined(_rows)) _rows = planet_config().rows_per_step;
	var _ps = _pn.smp, _ctx = _ps.ctx;
	var _tw = _pn.tw, _th = _pn.th;
	repeat (_rows) {
		if (_pn.row >= _th) break;
		var _ty = _pn.row;
		var _vv2 = (_ty + .5) / _th;
		var _sl  = sin(_vv2 * pi);
		var _py  = cos(_vv2 * pi);
		for (var _tx = (_pn[$ "col"] ?? 0); _tx < _tw; _tx++) {
			if ((_tx & 7) == 7 && get_timer() >= _until) { _pn.col = _tx; return false; }   // (the row picks up here next call)
			var _uu2 = (_tx + .5) / _tw;
			var _lon = _uu2 * 2 * pi;
			var _px  = _sl * cos(_lon);
			var _pz  = _sl * sin(_lon);
			var _i2 = _tx + _ty * _tw;
			planet_texel(_ps, _uu2, _vv2);
			_pn.elev[_i2]  = _ps.oe;
			_pn.biome[_i2] = _ps.ob;
			if (is_array(_pn[$ "gcol"])) _pn.gcol[_i2] = _ps.oc;   // (a giant's colour map - q236)
			_pn.det[_i2] = _ps.od; _pn.moi[_i2] = _ps.om;   // (the fields, kept - the zoom tier interpolates them, 2026-09-17)
			// clouds at this texel, by the world's REGIME (planet_gen_begin, 2026-09-17): the puffs, then the belts
			var _creg = _pn[$ "creg"] ?? 0, _crp = _pn[$ "cregp"];
			var _a = 0;
			var _bd = 99;
			if (_creg == 0 || _creg == 3) {
				for (var _k = 0; _k < array_length(_pn.cbl); _k++) {
					if (_creg == 3 && (_k mod 3) != 0) continue;   // (a front world keeps a third of its puffs)
					var _cb = _pn.cbl[_k];
					var _dd2 = point_distance_3d(_px, _py, _pz, _cb.x, _cb.y, _cb.z) - _cb.r;
					if (_dd2 < _bd) _bd = _dd2;
				}
			} else if (_creg == 1) {
				var _spl = _crp.puffs;
				for (var _k = 0; _k < array_length(_spl); _k++) {
					var _cb = _spl[_k];
					var _dd2 = point_distance_3d(_px, _py, _pz, _cb.x, _cb.y, _cb.z) - _cb.r;
					if (_dd2 < _bd) _bd = _dd2;
				}
			}
			if (_bd < -.05)   _a = 1;
			else if (_bd < 0) _a = .55;
			// the wisp: noise tears the puffs into weather (2026-09-15); a scattered sky is torn harder
			var _wisp = _ctx.fbm3(_px * 4.5, _py * 4.5, _pz * 4.5, _ps.o4 + 911, 2);
			var _wt0 = (_creg == 1) ? .44 : .38;
			if (_a > 0) { if (_wisp < _wt0) _a = 0; else if (_wisp < _wt0 + .09) _a = min(_a, .55); }
			var _wrp = (_ctx.fbm3(_px * 2.1, _py * 2.1, _pz * 2.1, _ps.o4, 2) - .5) * .16;
			var _bv = 0;
			if (_creg == 0 || _pn.kind == "gas") {
				for (var _k = 0; _k < array_length(_pn.belts); _k++) {
					var _db = abs(_vv2 + _wrp - _pn.belts[_k].v) / _pn.belts[_k].w;
					if (_db < 1) _bv = max(_bv, 1 - _db);
				}
				if (_bv > 0) {
					_bv *= _ctx.fbm3(_px * 3.4, _py * 3.4, _pz * 3.4, _ps.o4 + 517, 2);
					if (_bv > .40) _a = max(_a, 1);
					else if (_bv > .27) _a = max(_a, .55);
				}
			} else if (_creg == 2) {
				// STREAKED: thin belts, each torn along its length by a noise stretched east-west (long shreds, not puffs)
				var _sts = _crp.streaks;
				for (var _k = 0; _k < array_length(_sts); _k++) {
					var _db = abs(_vv2 + _wrp * .5 - _sts[_k].v) / _sts[_k].w;
					if (_db < 1) _bv = max(_bv, 1 - _db);
				}
				if (_bv > 0) {
					_bv *= _ctx.fbm3(_px * 1.3, _py * 9.0, _pz * 1.3, _ps.o4 + 517, 2) * 1.15;
					if (_bv > .40) _a = max(_a, 1);
					else if (_bv > .24) _a = max(_a, .55);
				}
			} else if (_creg == 3) {
				// FRONTS: a band about a great circle over a window of it - full at its leading edge, thinning behind, a
				// CLEAR WAKE behind that where nothing else may sit
				var _frs = _crp.fronts;
				for (var _k = 0; _k < array_length(_frs); _k++) {
					var _f = _frs[_k];
					var _dn = (_px * _f.ax[0] + _py * _f.ax[1] + _pz * _f.ax[2]) - _f.c;
					var _sg = (_px * _f.bx[0] + _py * _f.bx[1] + _pz * _f.bx[2]);
					if (_sg < 1 - _f.span) continue;
					var _dnw = _dn + _wrp * .4;
					if (_dnw >= 0 && _dnw < _f.w) { var _fb = 1 - _dnw / _f.w; _bv = max(_bv, _fb); _a = max(_a, (_fb > .5) ? 1 : .55); }
					else if (_dnw < 0 && _dnw > -_f.w * .9) { _a = 0; _bd = 99; }   // (the wake)
				}
				if (_bv > 0) { var _fn = _ctx.fbm3(_px * 3.4, _py * 3.4, _pz * 3.4, _ps.o4 + 517, 2); if (_fn < .3) _a = min(_a, .55); }
			}
			if (_pn.kind == "gas") _a = min(_a, .55);
			else if (_pn.dry)      _a = (_a > 0 && _wisp > .52) ? .55 : 0;   // a dry world keeps a few thin wisps (his ask: every world shows clouds)
			else if (_pn.wet < .3) _a = min(_a, .55);
			_pn.carr[_i2] = _a;
			// THE THICKNESS (the cloud relief, 2026-09-17, his ask: "a depth pass like the mountains so clouds
			// don't look flat"): a SMOOTH field the shader marches against - how deep inside the puff (its
			// distance field), the wisp's body, the belt's; a thin texel half. The coverage above stays hard
			var _t = 0;
			if (_a > 0) {
				if (_bd < 0) _t = max(_t, clamp(-_bd / .12, 0, 1));
				_t = max(_t, clamp((_wisp - .40) / .3, 0, 1) * .7);
				if (_bv > .27) _t = max(_t, clamp((_bv - .27) / .35, 0, 1));
				_t = max(_t, .08);
				if (_a < 1) _t *= .5;
			}
			_pn.cthk[_i2] = _t;
		}
		_pn.col = 0;
		_pn.row += 1;
	}
	return (_pn.row >= _th);
}
