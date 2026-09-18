/// @description planet_volcanoes(pn) - VOLCANOES (his ask, 2026-09-17): cones with craters on the land, some live with a lava vent and flows down a flank, a plume of smoke round every live one
/// A terra world has none two times in five, else one or two; a lava
/// world two to five, every one live; a barren world one or two, all
/// dead. VERY LARGE (his call): nine to sixteen texels across, a third to
/// a half of the relief tall, a stratovolcano's concave flank. Hashed off the seed - nothing rolled. A cone is a lift by
/// ground distance (a texel narrows toward the poles): the flank a curve
/// to the rim, the crater a bowl inside it, the vent a pit; the biome law
/// runs again on the lifted texels (rock and snow on a tall cone's
/// shoulders), then the crater takes basalt (17), a live vent lava (18 -
/// the palette's emissive slot, so it glows by night) and one to three
/// FLOWS of lava walk downhill from it. The cone's lift joins rlift, so
/// the gullies and the fluvial carve work its flanks. THE PLUME (his ask):
/// round each live vent a RING of smoke - hollow over the crater - in the cloud map's GREEN
/// (pn.csmk; the bake writes it) - sh_planet reads that channel in the
/// GROUND's frame, so the wind that carries the clouds never carries a
/// plume off its vent. Once a world, from planet_bake after the ranges
/// and before the rivers. The walkers are methods of one struct (a GML
/// function literal cannot see the locals round it).
function planet_volcanoes(_pn) {
	if (_pn[$ "volcanoes"] ?? false) return;
	_pn.volcanoes = true;
	if (_pn.kind == "gas") return;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th;
	if (is_undefined(_pn[$ "csmk"])) _pn.csmk = array_create(_n, 0);
	if (is_undefined(_pn[$ "rlift"])) _pn.rlift = array_create(_n, 0);
	var _c = {
		tw : _tw, th : _th, el : _pn.elev, bm : _pn.biome, dt : _pn.det, mo : _pn.moi, ps : _pn.smp, seed : _pn.seed, sea : _pn.sea,
		sc : _tw / 320, lift : array_create(_n, 0), rl : _pn.rlift, smk : _pn.csmk, vent : array_create(_n, 0),
		h : function(_k) { return (hash_mix(seed, 30000 + _k) mod 10000) / 10000; },
		// the cone: a lift by ground distance - the flank to the rim, the crater's bowl inside, the vent's pit
		cone : function(_x, _y, _rad, _hgt, _live) {
			var _cl = max(.2, sin(pi * (_y + .5) / th)), _r = ceil(_rad), _rx = min(tw div 2, ceil(_rad / _cl));
			var _rc = _rad * .22, _rv = _rad * .09;
			for (var _dy = -_r; _dy <= _r; _dy++) {
				var _yy = _y + _dy;
				if (_yy < 0 || _yy >= th) continue;
				for (var _dx = -_rx; _dx <= _rx; _dx++) {
					var _xx = (((_x + _dx) mod tw) + tw) mod tw, _i = _xx + _yy * tw;
					var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy);
					if (_d > _rad) continue;
					var _l = _hgt * power(1 - _d / _rad, 1.7);   // (a stratovolcano's flank: concave - steep at the summit, easing to the plain)
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
		// the plume: a disc of smoke round the vent in the cloud map's green, thick inside, ragged at the rim
		plume : function(_x, _y, _rad) {
			var _cl = max(.2, sin(pi * (_y + .5) / th)), _r = ceil(_rad), _rx = min(tw div 2, ceil(_rad / _cl));
			for (var _dy = -_r; _dy <= _r; _dy++) {
				var _yy = _y + _dy;
				if (_yy < 0 || _yy >= th) continue;
				for (var _dx = -_rx; _dx <= _rx; _dx++) {
					var _xx = (((_x + _dx) mod tw) + tw) mod tw, _i = _xx + _yy * tw;
					var _d = sqrt(_dx * _dx * _cl * _cl + _dy * _dy) / _rad;
					if (_d > 1) continue;
					// A RING (his ask, 2026-09-17): hollow over the crater, full round it, fading at the edge
					var _a = clamp((_d - .22) / .2, 0, 1) * (1 - clamp((_d - .72) / .28, 0, 1));
					_a *= .85 + .3 * dt[_i];   // (ragged)
					if (_d > .78 && dt[_i] < .35) _a *= .5;
					if (_a > smk[_i]) smk[_i] = min(1, _a);
				}
			}
		},
	};
	// how many, and of what temper
	var _arch = _pn.arch, _hv = hash_mix(_pn.seed, 31001) mod 100, _nv = 0, _all_live = false, _none_live = false;
	if (_arch == "lava")        { _nv = 2 + (_hv mod 4); _all_live = true; }
	else if (_arch == "barren") { _nv = 1 + (_hv mod 2); _none_live = true; }
	else                        { _nv = (_hv < 40) ? 0 : ((_hv < 80) ? 1 : 2); }
	var _el = _c.el, _sea = _c.sea, _sc = _c.sc, _pole = _th * .10;
	var _vents = [];
	for (var _k = 0; _k < _nv; _k++) {
		var _b = 100 * _k, _x = -1, _y = -1;
		for (var _t = 0; _t < 40 && _x < 0; _t++) {
			var _cx = floor(_c.h(_b + _t * 2) * _tw), _cy = floor((_pole + (_th - 2 * _pole) * _c.h(_b + _t * 2 + 1)));
			if (_el[_cx + _cy * _tw] >= _sea + .02) { _x = _cx; _y = _cy; }
		}
		if (_x < 0) continue;
		var _live = _all_live || (!_none_live && _c.h(_b + 90) < .6);
		var _rad = (9 + 7 * _c.h(_b + 91)) * _sc, _hgt = .34 + .16 * _c.h(_b + 92);   // (VERY LARGE - his verdict on the first cut; a mountain in a volcano's shape)
		_c.cone(_x, _y, _rad, _hgt, _live);
		array_push(_vents, [_x, _y, _live, _rad, _b]);
	}
	// into the heights (the cone's lift joins rlift for the gullies and the carve), the biome law again under it
	var _lift = _c.lift, _rl = _c.rl, _bm = _c.bm, _dt = _c.dt, _mo = _c.mo, _ps = _c.ps;
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
	for (var _k = 0; _k < array_length(_vents); _k++) { var _vt = _vents[_k]; if (_vt[2]) _c.plume(_vt[0], _vt[1], _vt[3] * .9); }   // (the ring sits on the cone's shoulders)
}
