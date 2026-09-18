/// @description planet_craters(pn) - IMPACT CRATERS (his pick, 2026-09-18: "1" of the terrain list; "I'd like for it to have crater depths"): bowls with DEPTH cut into the land, a raised rim, an apron of ejecta, a central peak in the big ones; the airless worlds' floors dark (the maria)
/// A barren world wears many (seven to fourteen, one of them a basin), a
/// lava world a few, a living world an old one or two - shallow, soft,
/// rimless nearly, no dark floor (the weather has had them). Sizes on a
/// power law: mostly small, the odd big one. Hashed off the seed. A crater
/// is cut by GROUND distance (a texel narrows toward the poles) on a
/// LEVELLED base (the mean height round its rim, the volcanoes' law - it
/// sits flat on a slope, not tilted): the floor FLAT at base - depth,
/// the wall climbing from half the radius to the rim, the rim a lip
/// above the plain, the ejecta easing out to 1.8 radii, a central peak
/// past nine texels across; the depth grows with the radius (a ten-texel
/// crater a range's height deep). The biome law runs again on the cut
/// texels (rock on the rims), and on an airless world the floor takes
/// basalt (17) through pn.vmask - the tier's overlay carries it, and no
/// river runs in; a living world's crater keeps its biome and may fill
/// as a lake (planet_rivers' flood). Once a world, from planet_bake after
/// the volcanoes and before the rivers (so pn.elev0 - the tier's biome
/// heights - has them)
function planet_craters(_pn) {
	if (_pn[$ "craters"] ?? false) return;
	_pn.craters = true;
	if (_pn.kind == "gas") return;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _sc = _tw / 320;
	var _arch = _pn.arch, _hc = hash_mix(_pn.seed, 32001) mod 100;
	var _nc = 0, _dark = false;
	if (_arch == "barren")     { _nc = 7 + (_hc mod 8); _dark = true; }
	else if (_arch == "lava")  { _nc = 2 + (_hc mod 4); _dark = true; }
	else                       { _nc = (_hc < 45) ? 0 : ((_hc < 80) ? 1 : 2); }
	if (_nc == 0) return;
	var _el = _pn.elev, _bm = _pn.biome, _dt = _pn.det, _mo = _pn.moi, _ps = _pn.smp, _sea = _pn.sea;
	if (is_undefined(_pn[$ "vmask"])) _pn.vmask = array_create(_n, 0);
	var _vm = _pn.vmask, _touch = array_create(_n, 0);
	var _old = !_dark;   // (a living world's craters are old: shallow and soft)
	var _pole = _th * .06;
	for (var _k = 0; _k < _nc; _k++) {
		var _b = 200 * _k;
		// THE SITE: a few hashed tries on land off the poles (an airless world is all land)
		var _x = -1, _y = -1;
		for (var _t = 0; _t < 10; _t++) {
			var _cx = floor(((hash_mix(_pn.seed, 32100 + _b + _t * 2) mod 10000) / 10000) * _tw);
			var _cy = floor(_pole + (_th - 2 * _pole) * ((hash_mix(_pn.seed, 32101 + _b + _t * 2) mod 10000) / 10000));
			if (_el[_cx + _cy * _tw] < _sea + .01) continue;
			_x = _cx; _y = _cy; break;
		}
		if (_x < 0) continue;
		// THE SIZE: a power law - mostly small, the odd big one; the first of an airless world's is its basin
		var _u = (hash_mix(_pn.seed, 32150 + _b) mod 10000) / 10000;
		var _rad = ((_dark && _k == 0) ? (12 + 6 * _u) : (2.2 + 8 * power(_u, 2.4))) * _sc;
		var _rt = _rad / _sc;
		var _D = (.06 + .012 * _rt) * (_old ? .4 : 1);            // THE DEPTH (his ask): a ten-texel crater a range's height deep
		var _Rh = _D * (_old ? .25 : .42);                          // the rim's lip
		var _peak = (_rt > 9) ? _D * .45 : 0;                       // a central peak in the big ones
		var _cl = max(.2, sin(pi * (_y + .5) / _th));
		var _reach = _old ? 1.15 : 1.8;                             // (the ejecta's apron; an old crater keeps none)
		var _r = ceil(_rad * _reach), _rx = min(_tw div 2, ceil(_rad * _reach / _cl));
		// THE LEVELLED BASE: the mean height round the rim
		var _bs = 0, _bn = 0;
		for (var _a = 0; _a < 16; _a++) {
			var _px = (((_x + round(dcos(_a * 22.5) * _rad / _cl)) mod _tw) + _tw) mod _tw, _py = clamp(_y + round(dsin(_a * 22.5) * _rad), 0, _th - 1);
			_bs += _el[_px + _py * _tw]; _bn++;
		}
		var _base = _bs / max(1, _bn);
		for (var _dy = -_r; _dy <= _r; _dy++) {
			var _yy = _y + _dy;
			if (_yy < 0 || _yy >= _th) continue;
			for (var _dx = -_rx; _dx <= _rx; _dx++) {
				var _xx = (((_x + _dx) mod _tw) + _tw) mod _tw, _i = _xx + _yy * _tw;
				var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy) / _rad;
				if (_d > _reach) continue;
				var _g = .92 + .16 * _dt[_i], _e = _el[_i];
				if (_d <= 1) {
					// inside: levelled to the base (wholly at the centre, not at the rim), then the bowl - a flat floor, the
					// wall from half the radius up to the rim - the peak, and the rim's lip
					_e = lerp(_e, _base, power(1 - _d, .6));
					var _floor = 1 - sstep(_d, .5, 1.0);
					_e -= _D * _floor * _g;
					_e += _peak * clamp(1 - _d / .18, 0, 1);
					_e += _Rh * exp(-sqr((_d - 1) / .14)) * _g;
					if (_dark && _d < .62) _vm[_i] = max(_vm[_i], 1);   // (the floor: basalt, no river)
				} else {
					// outside: the rim's lip fading, the ejecta's apron out to the reach
					var _o = (_d - 1) / (_reach - 1);
					_e += _Rh * exp(-sqr((_d - 1) / .14)) * _g;
					_e += _Rh * .35 * sqr(1 - _o) * (.6 + .8 * _dt[_i]) * (_old ? 0 : 1);
				}
				_el[_i] = max(_e, .002);
				_touch[_i] = 1;
			}
		}
	}
	// the biome law again under the cut, then the airless floors' basalt
	for (var _i = 0; _i < _n; _i++) {
		if (_touch[_i] == 0) continue;
		_ps.oe = _el[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		_bm[_i] = _ps.ob;
		if (_dark && _vm[_i] == 1 && _el[_i] >= _sea) _bm[_i] = 17;
	}
}
