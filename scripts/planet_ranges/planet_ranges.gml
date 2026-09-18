/// @description planet_ranges(pn) - THE RANGE SKELETON (his ask, 2026-09-17: "real mountains have branches"): mountain ranges grown as TREES of ridge - a spine, spurs off it, sub-spurs off those - lifted into the heights, the biome law re-run under them
/// Two to five spines a world (hashed off the seed - nothing rolled),
/// each begun on high ground and walked across the map a texel at a time
/// with a wandering, slowly curving heading, ending at a length or where
/// it meets the sea. Every six to twelve texels a SPUR leaves the spine at
/// fifty to ninety degrees, alternating sides, shorter and lower, wandering
/// more; every four to six texels of a spur a SUB-SPUR leaves it, shorter
/// and lower again. Each ridge texel carries its level's height (.22 /
/// .13 / .07), tapered along its branch (a spine tallest at its middle, a
/// spur tallest at its root); the ground round each is lifted by a crest
/// profile with a foothill shoulder, the highest lift winning where they
/// meet, roughened by the detail field so no crest is a rail. The lifted
/// texels get their biome again from the kept fields (planet_biome), so
/// crowns turn to rock and snow, flanks to tundra, exactly as the noise
/// would have had them; the drainage after finds its valleys between the
/// spurs. Once a world, from planet_bake before the rivers; the zoom tier
/// reads the lifted heights like any other. The noise ridge that made the
/// ranges before is roughness now (planet_fields, .07).
/// (The walkers are methods of one struct: a GML function literal cannot
/// see the locals round it, but one inside a struct literal is bound to
/// the struct and reads its fields as its own.)
function planet_ranges(_pn) {
	if (_pn[$ "ranges"] ?? false) return;
	_pn.ranges = true;
	if (_pn.kind == "gas") return;
	var _c = {
		tw : _pn.tw, th : _pn.th, el : _pn.elev, dt : _pn.det, seed : _pn.seed, sea : _pn.sea,
		sc : _pn.tw / 320,   // (the lite worlds scale every length)
		lift : array_create(_pn.tw * _pn.th, 0),
		H : [0, .22, .13, .07], W : [0, 4.5 * _pn.tw / 320, 3 * _pn.tw / 320, 2 * _pn.tw / 320],
		h : function(_k) { return (hash_mix(seed, 20000 + _k) mod 10000) / 10000; },
		// a ridge texel: the highest lift wins; its crest profile (with a foothill shoulder) spreads over the window round it
		stamp : function(_x, _y, _lvl, _tap) {
			var _hh = H[_lvl] * _tap, _w = W[_lvl], _r = ceil(_w * 1.7);
			var _xi = floor(_x), _yi = floor(_y);
			for (var _dy = -_r; _dy <= _r; _dy++) {
				var _yy = _yi + _dy;
				if (_yy < 0 || _yy >= th) continue;
				for (var _dx = -_r; _dx <= _r; _dx++) {
					var _xx = (((_xi + _dx) mod tw) + tw) mod tw, _i = _xx + _yy * tw;
					var _d = sqrt((_xi + _dx - _x) * (_xi + _dx - _x) + (_yy - _y) * (_yy - _y)) / _w;
					if (_d > 1.7) continue;
					var _crest = power(max(0, 1 - _d), 1.6) * .8, _shoulder = power(max(0, 1 - _d / 1.7), 2) * .35;
					var _l = _hh * (_crest + _shoulder) * (.8 + .4 * dt[_i]);
					if (_l > lift[_i]) lift[_i] = _l;
				}
			}
		},
		// a branch: from (x, y) on heading hd (degrees), len texels, wandering by wob a step, curving by bias a step;
		// mid = tallest at its middle (a spine), else at its root (a spur); it ends early in the sea or near a pole;
		// returns the points [x, y, heading] it laid
		walk : function(_x, _y, _hd, _len, _wob, _bias, _lvl, _mid, _salt) {
			var _pts = [], _wet = 0;
			for (var _s = 0; _s < _len; _s++) {
				var _f = _s / max(1, _len - 1);
				var _tap = _mid ? (1 - .6 * power(abs(_f - .5) * 2, 2)) : (1 - .7 * _f);
				stamp(_x, _y, _lvl, _tap);
				array_push(_pts, [_x, _y, _hd]);
				_hd += (h(_salt + _s * 3) - .5) * 2 * _wob + _bias;
				_x += dcos(_hd); _y -= dsin(_hd);
				if (_y < th * .08 || _y >= th * .92) break;
				var _xi = ((floor(_x) mod tw) + tw) mod tw, _yi = clamp(floor(_y), 0, th - 1);
				if (el[_xi + _yi * tw] < sea - .01) { _wet++; if (_wet > 2) break; } else _wet = 0;
			}
			return _pts;
		},
	};
	var _tw = _c.tw, _th = _c.th, _sc = _c.sc, _el = _c.el;
	var _nsp = 2 + (hash_mix(_c.seed, 19001) mod 4);   // two to five spines
	for (var _r = 0; _r < _nsp; _r++) {
		var _base = 500 * _r;
		// the start: high ground, off the poles - thirty tries
		var _sx = -1, _sy = -1;
		for (var _t = 0; _t < 30 && _sx < 0; _t++) {
			var _cx = floor(_c.h(_base + _t * 2) * _tw), _cy = floor((.12 + .76 * _c.h(_base + _t * 2 + 1)) * _th);
			if (_el[_cx + _cy * _tw] >= _c.sea + .03) { _sx = _cx; _sy = _cy; }
		}
		if (_sx < 0) continue;
		var _hd = _c.h(_base + 61) * 360, _len = round((40 + 80 * _c.h(_base + 62)) * _sc), _bias = (_c.h(_base + 63) - .5) * 2.4;
		var _spine = _c.walk(_sx, _sy, _hd, _len, 12, _bias, 1, true, _base + 100);
		// the spurs, every six to twelve texels, alternating sides
		var _side = (_c.h(_base + 64) < .5) ? 1 : -1, _next = round((4 + 6 * _c.h(_base + 65)) * _sc), _k = 0;
		for (var _p = 0; _p < array_length(_spine); _p++) {
			if (_p < _next) continue;
			_next = _p + round((6 + 6 * _c.h(_base + 200 + _k)) * _sc);
			var _pt = _spine[_p], _sb = _base + 1000 + _k * 40;
			var _shd = _pt[2] + _side * (55 + 35 * _c.h(_sb)), _slen = round((8 + 14 * _c.h(_sb + 1)) * _sc);
			var _spur = _c.walk(_pt[0], _pt[1], _shd, _slen, 20, (_c.h(_sb + 2) - .5) * 3, 2, false, _sb + 3);
			// the sub-spurs, every four to six texels of the spur, alternating sides
			var _ss = (_c.h(_sb + 4) < .5) ? 1 : -1, _snext = round((3 + 3 * _c.h(_sb + 5)) * _sc), _q = 0;
			for (var _p2 = 0; _p2 < array_length(_spur); _p2++) {
				if (_p2 < _snext) continue;
				_snext = _p2 + round((4 + 2 * _c.h(_sb + 10 + _q)) * _sc);
				var _pt2 = _spur[_p2], _sb2 = _sb + 20 + _q * 4;
				var _hd3 = _pt2[2] + _ss * (50 + 40 * _c.h(_sb2)), _len3 = round((3 + 5 * _c.h(_sb2 + 1)) * _sc);
				_c.walk(_pt2[0], _pt2[1], _hd3, _len3, 25, 0, 3, false, _sb2 + 2);
				_ss = -_ss; _q++;
			}
			_side = -_side; _k++;
		}
	}
	// ---- into the heights, and the biome law again under every lift ----
	var _lift = _c.lift, _bm = _pn.biome, _dt = _pn.det, _mo = _pn.moi, _ps = _pn.smp, _n = _tw * _th;
	for (var _i = 0; _i < _n; _i++) {
		if (_lift[_i] <= 0) continue;
		_el[_i] += _lift[_i];
		_ps.oe = _el[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		_bm[_i] = _ps.ob;
	}
}
