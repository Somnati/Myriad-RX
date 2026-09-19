/// @description planet_signature(pn) - THE SIGNATURE (q248; his ask for variety: "what makes a world memorable"): one landmark a world, the temper's pick (pn.tt.sig) - 1 an IMPACT SEA (a crater the size of a country, its floor under the sea, a ring of rim islands), 2 a CALDERA (a great shield with a bowl - a lake once the rivers run), 3 a RIFT (a long trough with shoulders; lakes chain along it), 4 a MEGA-CANYON (a long terraced gorge on high ground), 5 an INLAND SEA (a basin let under the sea), 6 a SALT FLAT (a basin levelled, white - biome 13 held), 7 an ICE SHEET (a raised sheet near a pole, glacier held)
/// Once a world, from planet_bake after the craters and before the rivers (a caldera fills, a rift chains its lakes).
/// The held biomes (salt, ice) go on pn.sigmask; planet_bake lays them over the map at the end (the passes after this
/// one re-run the biome law where they touch) and the zoom tier reads the mask too. The stamps (a map under a hundred
/// wide) take only the great features (the impact sea, the inland sea, the ice sheet) - the fine ones need the texels
function planet_signature(_pn) {
	if (_pn[$ "signature"] ?? false) return;
	_pn.signature = true;
	var _tt = _pn[$ "tt"];
	if (_pn.kind == "gas" || !is_struct(_tt) || _tt.sig == 0) return;
	var _sig = _tt.sig;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _sc = _tw / 320, _sea = _pn.sea, _arch = _pn.arch;
	var _el = _pn.elev, _bm = _pn.biome, _dt = _pn.det, _mo = _pn.moi, _ps = _pn.smp;
	var _small = (_tw < 100);
	// the fits: a sea to fill needs a sea; a salt flat wants a dry world or a barren one; an ice sheet a cool one
	if ((_sig == 1 || _sig == 5) && _sea <= 0) _sig = 3;
	if (_sig == 6 && _arch == "lava") _sig = 4;
	if (_sig == 7 && _pn.clim < .40) _sig = (_sea > 0) ? 5 : 3;
	if (_sig == 2 && _arch == "lava") _sig = 1;
	if (_small && (_sig == 2 || _sig == 3 || _sig == 4 || _sig == 6)) return;
	if (!is_array(_pn[$ "sigmask"])) _pn.sigmask = array_create(_n, 0);
	var _sm = _pn.sigmask, _touch = array_create(_n, 0);
	// THE SITE: forty hashed tries for land off the poles (a rift or a canyon wants high ground; an ice sheet a pole's skirt)
	var _x = -1, _y = -1;
	var _ymin = .12, _ymax = .88;
	if (_sig == 7) { if (_tt.sigv < .5) { _ymin = .06; _ymax = .22; } else { _ymin = .78; _ymax = .94; } }
	for (var _t = 0; _t < 40 && _x < 0; _t++) {
		var _cx = floor(((hash_mix(_pn.seed, 5300 + _t * 2) mod 10000) / 10000) * _tw), _cy = floor(_th * (_ymin + (_ymax - _ymin) * ((hash_mix(_pn.seed, 5301 + _t * 2) mod 10000) / 10000)));
		var _ci = _cx + _cy * _tw, _e = _el[_ci];
		if (_sig == 1 || _sig == 5 || _sig == 6 || _sig == 2) { if (_e < _sea + .02) continue; }
		else if (_sig == 3) { if (_e < _sea + .04) continue; }
		else if (_sig == 4) { if (_e < _sea + .14) continue; }
		else if (_sig == 7) { if (_e < _sea) continue; }
		_x = _cx; _y = _cy;
	}
	if (_x < 0) return;
	var _h = _tt.sigh, _cl = max(.2, sin(pi * (_y + .5) / _th));
	// ---- the round ones: a blob round the site, ground distance ÷ cos lat, the change by d = distance / R ----
	if (_sig == 1 || _sig == 2 || _sig == 5 || _sig == 6 || _sig == 7) {
		var _R = ((_sig == 1) ? (26 + 14 * _h) : ((_sig == 2) ? (15 + 10 * _h) : ((_sig == 5) ? (14 + 10 * _h) : ((_sig == 6) ? (12 + 8 * _h) : (20 + 12 * _h))))) * _sc;
		var _reach = (_sig == 1) ? 1.7 : 1.15;
		var _r = ceil(_R * _reach), _rx = min(_tw div 2, ceil(_R * _reach / _cl));
		// the region's mean height (the levelled base)
		var _bs = 0, _bn = 0;
		for (var _dy = -_r; _dy <= _r; _dy += 2) { var _yy = _y + _dy; if (_yy < 0 || _yy >= _th) continue;
			for (var _dx = -_rx; _dx <= _rx; _dx += 2) { var _xx = (((_x + _dx) mod _tw) + _tw) mod _tw; if (sqrt(_dx * _dx * _cl * _cl + _dy * _dy) > _R) continue; _bs += _el[_xx + _yy * _tw]; _bn++; } }
		var _base = _bs / max(1, _bn);
		for (var _dy = -_r; _dy <= _r; _dy++) { var _yy = _y + _dy; if (_yy < 0 || _yy >= _th) continue;
			for (var _dx = -_rx; _dx <= _rx; _dx++) {
				var _xx = (((_x + _dx) mod _tw) + _tw) mod _tw, _i = _xx + _yy * _tw;
				var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy) / _R;
				if (_d > _reach) continue;
				var _wob = 1 + .10 * (planet_vn3(_pn.seed + 5400, (_xx + .5) / _tw, (_yy + .5) / _th, 6) - .5);   // (the edge wobbles a little)
				_d /= _wob;
				var _e = _el[_i], _g = .92 + .16 * _dt[_i];
				if (_sig == 1) {
					// THE IMPACT SEA: the floor under the sea, the wall climbing from half the radius, a rim lip that stands as a ring of islands, an apron
					if (_d <= 1) { _e = lerp(_e, _base, power(1 - _d, .5)); _e = min(_e, (_sea - .05) + (_base + .04 - (_sea - .05)) * sstep(_d, .55, 1.0)); }
					_e += .055 * exp(-sqr((_d - 1) / .09)) * _g;
					if (_d > 1) _e += .02 * sqr(1 - (_d - 1) / .7) * (.6 + .8 * _dt[_i]);
				} else if (_sig == 2) {
					// THE CALDERA: a great shield, a deep bowl in its crown (the rivers' flood makes it a lake)
					if (_d <= 1) { _e += .30 * power(1 - _d, 1.2) * _g; if (_d < .30) _e -= .22 * power(1 - _d / .30, .6); }
				} else if (_sig == 5) {
					// THE INLAND SEA: a basin let under the sea, a soft shore
					if (_d <= 1) _e = min(_e, lerp(_sea - .045, _e, sstep(_d, .55, 1.0)));
				} else if (_sig == 6) {
					// THE SALT FLAT: the basin levelled a hair over the sea, the white held
					if (_d <= 1) { var _lvl = max(_sea + .006, .06); _e = lerp(_e, _lvl, power(1 - _d, .5)); if (_d < .85 && _e >= _sea) _sm[_i] = 13; }
				} else {
					// THE ICE SHEET: raised toward the middle, the glacier held over it
					if (_d <= 1 && _e >= _sea) { _e += .06 * power(1 - _d, .7); if (_d < .92) _sm[_i] = 14; }
				}
				if (_e != _el[_i]) { _el[_i] = max(_e, .002); _touch[_i] = 1; }
				else if (_sm[_i] > 0) _touch[_i] = 1;
			}
		}
	} else {
		// ---- the long ones: a walk from the site along a heading that bends a little; the trough a rift's, the gorge a canyon's ----
		var _len = round(((_sig == 3) ? (50 + 40 * _h) : (35 + 30 * _h)) * _sc), _hd = _tt.siga, _cv = (_tt.sigu - .5) * 1.4;
		var _wid = ((_sig == 3) ? 2.6 : 1.6) * _sc, _reach2 = (_sig == 3) ? 2.4 : 1.6;
		var _px = _x + .5, _py = _y + .5;
		var _floors = [];
		for (var _s = 0; _s < _len; _s++) {
			var _clw = max(.2, sin(pi * clamp(_py, .5, _th - .5) / _th));
			_px += dcos(_hd) / _clw; _py -= dsin(_hd); _hd += _cv + (planet_vn3(_pn.seed + 5500, frac(_px / _tw + 1), clamp(_py / _th, 0, 1), 7) - .5) * 6;
			if (_py < _th * .08 || _py > _th * .92) break;
			var _ix0 = (((floor(_px)) mod _tw) + _tw) mod _tw, _iy0 = clamp(floor(_py), 0, _th - 1), _i0 = _ix0 + _iy0 * _tw;
			if (_el[_i0] < _sea - .005) break;   // (it ran into the sea)
			if (_sig == 4 && _el[_i0] < _sea + .08) break;   // (a canyon stays on the high ground)
			var _rr = ceil(_wid * _reach2), _rxx = min(_tw div 2, ceil(_wid * _reach2 / _clw));
			for (var _dy = -_rr; _dy <= _rr; _dy++) { var _yy = _iy0 + _dy; if (_yy < 0 || _yy >= _th) continue;
				for (var _dx = -_rxx; _dx <= _rxx; _dx++) {
					var _xx = (((_ix0 + _dx) mod _tw) + _tw) mod _tw, _i = _xx + _yy * _tw;
					var _d = sqrt(_dx * _dx * _clw * _clw + _dy * _dy) / _wid;
					if (_d > _reach2) continue;
					var _e = _el[_i];
					if (_sig == 3) {
						// THE RIFT: the trough dropped, the shoulders lifted either side - a graben
						if (_d <= 1) _e = min(_e, _el[_i] - .085 * (1 - _d * _d));
						else _e += .028 * sqr(1 - (_d - 1) / 1.4) * (.7 + .6 * _dt[_i]);
						_e = max(_e, _sea + .004);
					} else {
						// THE MEGA-CANYON: the terraced convex wall from the floor to the rim (planet_plateaus' law), deep
						if (_d <= 1) {
							var _s3 = power(_d, .55) * 3, _tr = (floor(_s3) + power(frac(_s3), 3.5)) / 3;
							var _fl = max(_sea + .012, _el[_i] - .17);
							_e = min(_e, _fl + (_el[_i] - _fl) * _tr);
						}
					}
					if (_e != _el[_i]) { _el[_i] = max(_e, .002); _touch[_i] = 1; }
				}
			}
		}
	}
	// the biome law again on the touched, then the held kinds over it
	for (var _i = 0; _i < _n; _i++) {
		if (_touch[_i] == 0) continue;
		_ps.oe = _el[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		_bm[_i] = _ps.ob;
		if (_sm[_i] > 0 && _el[_i] >= _sea) _bm[_i] = _sm[_i];
	}
}
