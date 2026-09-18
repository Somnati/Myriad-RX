/// @description planet_volcanoes(pn) - VOLCANOES (his ask, 2026-09-17): cones with craters on the land, some live with a lava vent and flows down a flank; the live vents out as pn.vents for the shader's plumes
/// A terra world has none two times in five, else one or two; a lava
/// world two to five, every one live; a barren world one or two, all
/// dead. Its size procedural (his call): a stratovolcano two in three -
/// five to nine texels across, .42-.60 tall, a steep concave flank - else
/// a shield, ten to sixteen across, .26-.36 tall, an easy one. Hashed off the seed - nothing rolled. A cone is a lift by
/// ground distance (a texel narrows toward the poles): the flank a curve
/// to the rim, the crater a bowl inside it, the vent a pit; the biome law
/// runs again on the lifted texels (rock and snow on a tall cone's
/// shoulders), then the crater takes basalt (17), a live vent lava (18 -
/// the palette's emissive slot, so it glows by night) and one to three
/// FLOWS of lava walk downhill from it. The cone's lift joins rlift, so
/// the gullies and the fluvial carve work its flanks. THE PLUMES are the
/// shader's: the live vents go out as pn.vents (direction + reach) and
/// sh_planet draws a ring of turning, billowing smoke round each, in the
/// ground's frame, so the wind never carries a plume off its vent, and
/// throws its shadow. Once a world, from planet_bake after the ranges
/// and before the rivers. The walkers are methods of one struct (a GML
/// function literal cannot see the locals round it).
function planet_volcanoes(_pn) {
	if (_pn[$ "volcanoes"] ?? false) return;
	_pn.volcanoes = true;
	if (_pn.kind == "gas") return;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th;
	if (is_undefined(_pn[$ "rlift"])) _pn.rlift = array_create(_n, 0);
	var _c = {
		tw : _tw, th : _th, el : _pn.elev, bm : _pn.biome, dt : _pn.det, mo : _pn.moi, ps : _pn.smp, seed : _pn.seed, sea : _pn.sea,
		sc : _tw / 320, lift : array_create(_n, 0), rl : _pn.rlift, vent : array_create(_n, 0),
		h : function(_k) { return (hash_mix(seed, 30000 + _k) mod 10000) / 10000; },
		// the cone: a lift by ground distance - the flank to the rim, the crater's bowl inside, the vent's pit
		cone : function(_x, _y, _rad, _hgt, _live, _stp) {   // (stp: the flank's exponent - the steeper, the more the height sits at the summit)
			var _cl = max(.2, sin(pi * (_y + .5) / th)), _r = ceil(_rad), _rx = min(tw div 2, ceil(_rad / _cl));
			var _rc = _rad * .22, _rv = _rad * .09;
			// THE BASE (his report, 2026-09-17: "on the side of a mountain at an angle"): the mean height round the cone's
			// perimeter; the ground inside is levelled toward it, fully at the centre, not at all at the edge, so the
			// cone stands upright on a range's flank instead of leaning down it
			var _bs = 0, _bn = 0;
			for (var _a = 0; _a < 16; _a++) {
				var _px = (((_x + round(dcos(_a * 22.5) * _rad / _cl)) mod tw) + tw) mod tw, _py = clamp(_y + round(dsin(_a * 22.5) * _rad), 0, th - 1);
				_bs += el[_px + _py * tw]; _bn++;
			}
			var _base = max(sea + .01, _bs / max(1, _bn));
			for (var _dy = -_r; _dy <= _r; _dy++) {
				var _yy = _y + _dy;
				if (_yy < 0 || _yy >= th) continue;
				for (var _dx = -_rx; _dx <= _rx; _dx++) {
					var _xx = (((_x + _dx) mod tw) + tw) mod tw, _i = _xx + _yy * tw;
					var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy);
					if (_d > _rad) continue;
					el[_i] = lerp(el[_i], _base, power(1 - _d / _rad, .6));
					var _l = _hgt * power(1 - _d / _rad, _stp);   // (a stratovolcano's flank: concave - steep at the summit, easing to the plain; a shield's gentler)
					if (_d < _rc) _l -= _hgt * .38 * (1 - (_d / _rc) * (_d / _rc));   // (the crater's bowl: the rim stands, the floor sinks)
					_l *= .9 + .2 * dt[_i];
					if (_l > lift[_i]) lift[_i] = _l;
					if (_d < _rc) vent[_i] = max(vent[_i], (_d < _rv) ? (_live ? 2 : 1) : 1);   // (2 the vent, 1 the crater's floor)
				}
			}
		},
		// a flow of lava: from the vent downhill, the lowest neighbour each step, a few texels
		flow : function(_x, _y, _len, _salt) {
			var _cx = _x, _cy = _y;
			for (var _s = 0; _s < _len; _s++) {
				var _bi = -1, _bv = 9;
				for (var _dy = -1; _dy <= 1; _dy++) { var _ny = _cy + _dy; if (_ny < 0 || _ny >= th) continue;
					for (var _dx = -1; _dx <= 1; _dx++) { if (_dx == 0 && _dy == 0) continue;
						var _ni = (((_cx + _dx) mod tw) + tw) mod tw + _ny * tw;
						var _v = el[_ni] + (h(_salt + _s * 9 + _dx * 3 + _dy) - .5) * .02;   // (a grain of chance in the way it turns; the cone is in the heights by now)
						if (_v < _bv && vent[_ni] < 2) { _bv = _v; _bi = _ni; } } }
				if (_bi < 0) break;
				if (el[_bi] < sea) break;   // (it stops at the water)
				_cx = _bi mod tw; _cy = _bi div tw;
				if (vent[_bi] < 2) vent[_bi] = 3;   // (3 a flow)
			}
		},
	};
	// how many, and of what temper
	var _arch = _pn.arch, _hv = hash_mix(_pn.seed, 31001) mod 100, _nv = 0, _all_live = false, _none_live = false;
	if (_arch == "lava")        { _nv = 2 + (_hv mod 4); _all_live = true; }
	else if (_arch == "barren") { _nv = 1 + (_hv mod 2); _none_live = true; }
	else                        { _nv = (_hv < 40) ? 0 : ((_hv < 80) ? 1 : 2); }
	if (VOLCANO_ALL) _nv = max(1, _nv);   // (debug: at least one on every world - his ask 2026-09-17)
	var _el = _c.el, _sea = _c.sea, _sc = _c.sc, _pole = _th * .10, _rl = _c.rl;
	var _vents = [];
	for (var _k = 0; _k < _nv; _k++) {
		var _b = 100 * _k, _x = -1, _y = -1, _best = -1;
		// THE SITE (his ask, 2026-09-17: "make sure a volcano spawns in mountain regions"): forty hashed tries on land off the
		// poles; a try on a range's SHOULDER (the skeleton's lift between a hair and a crest) scores high, level ground
		// scores high; the best wins. A world without ranges takes the levellest land
		for (var _t = 0; _t < 40; _t++) {
			var _cx = floor(_c.h(_b + _t * 2) * _tw), _cy = floor((_pole + (_th - 2 * _pole) * _c.h(_b + _t * 2 + 1)));
			var _ci = _cx + _cy * _tw;
			if (_el[_ci] < _sea + .02) continue;
			var _lf = _rl[_ci], _near = (_lf > .006 && _lf < .12) ? 1 : 0;
			var _hi2 = -9, _lo2 = 9;
			for (var _dy = -3; _dy <= 3; _dy += 3) for (var _dx = -3; _dx <= 3; _dx += 3) { var _ny = clamp(_cy + _dy, 0, _th - 1), _nx = ((_cx + _dx) mod _tw + _tw) mod _tw; var _ev = _el[_nx + _ny * _tw]; _hi2 = max(_hi2, _ev); _lo2 = min(_lo2, _ev); }
			var _sc2 = _near * 2 + clamp(1 - (_hi2 - _lo2) / .12, 0, 1);
			if (_sc2 > _best) { _best = _sc2; _x = _cx; _y = _cy; }
		}
		if (_x < 0) continue;
		var _live = _all_live || (!_none_live && _c.h(_b + 90) < .6);
		// THE SIZE, PROCEDURAL (his ask, 2026-09-17: "tighter and taller... or at least procedural"): a STRATOVOLCANO two
		// times in three - tight and tall, five to nine texels across, .42-.60 of the relief, a steep concave flank -
		// else a SHIELD, broad and low, ten to sixteen across, .26-.36 tall, an easy flank
		var _strato = (_c.h(_b + 93) < .67);
		var _rad = (_strato ? (5 + 4 * _c.h(_b + 91)) : (10 + 6 * _c.h(_b + 91))) * _sc;
		var _hgt = _strato ? (.42 + .18 * _c.h(_b + 92)) : (.26 + .10 * _c.h(_b + 92));
		_c.cone(_x, _y, _rad, _hgt, _live, _strato ? 2.0 : 1.3);
		array_push(_vents, [_x, _y, _live, _rad, _b]);
	}
	// into the heights (the cone's lift joins rlift for the gullies and the carve), the biome law again under it
	var _lift = _c.lift, _bm = _c.bm, _dt = _c.dt, _mo = _c.mo, _ps = _c.ps;   // (_rl is the site loop's, above)
	for (var _i = 0; _i < _n; _i++) {
		if (_lift[_i] <= 0) continue;
		_el[_i] = max(_el[_i] + _lift[_i], _sea + .004);
		_rl[_i] = max(_rl[_i], _lift[_i]);
		_ps.oe = _el[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		_bm[_i] = _ps.ob;
	}
	// the flows, then the crater's basalt, the vent's lava (or a dead vent's rock), the plumes
	for (var _k = 0; _k < array_length(_vents); _k++) {
		var _vt = _vents[_k];
		if (_vt[2]) { var _nf = 1 + (hash_mix(_pn.seed, 31500 + _k) mod 3); for (var _f = 0; _f < _nf; _f++) _c.flow(_vt[0], _vt[1], round(_vt[3] * (.8 + .9 * _c.h(_vt[4] + 50 + _f))), _vt[4] + 60 + _f * 200); }
	}
	var _vent = _c.vent;
	for (var _i = 0; _i < _n; _i++) {
		if (_vent[_i] == 0 || _el[_i] < _sea) continue;
		if (_vent[_i] == 2 || _vent[_i] == 3) _bm[_i] = 18;   // lava: the live vent, the flows
		else _bm[_i] = 17;                                     // basalt: the crater's floor, a dead vent
	}
	// THE PLUMES are the shader's now (2026-09-17, "higher quality plumes"): the live vents go to planet_draw as
	// directions on the sphere with the plume's angular radius - sh_planet draws each as a ring of turning, billowing
	// smoke in the ground's frame, at any zoom, and throws its shadow on the ground
	var _pl = [];
	for (var _k = 0; _k < array_length(_vents); _k++) {
		var _vt = _vents[_k];
		if (!_vt[2]) continue;
		var _vu = (_vt[0] + .5) / _tw, _vv = (_vt[1] + .5) / _th, _vsl = sin(_vv * pi);
		array_push(_pl, [_vsl * cos(_vu * 2 * pi), cos(_vv * pi), _vsl * sin(_vu * 2 * pi), _vt[3] * .62 * 2 * pi / _tw]);   // (the ring's reach: .62 of the cone, in radians)
	}
	_pn.vents = _pl;
	_pn.vmask = _vent;   // (kept: planet_rivers treats the craters and flows as sinks - no river climbs the cone into the crater, no lake fills it; his report 2026-09-17)
}
