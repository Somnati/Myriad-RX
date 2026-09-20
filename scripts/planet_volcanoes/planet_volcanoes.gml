/// @description planet_volcanoes(pn) - VOLCANOES (his ask, 2026-09-17): cones with craters on the land, some live with a lava vent and flows down a flank; the live vents out as pn.vents for the shader's plumes
/// A terra world has none two times in five, else one or two; a lava
/// world two to five, every one live; a barren world one or two, all
/// dead. Its size procedural (his call): a stratovolcano two in three -
/// five to nine texels across, .42-.60 tall, a steep concave flank - else
/// a shield, ten to sixteen across, .26-.36 tall, an easy one. Hashed off the seed - nothing rolled. A cone is a lift by
/// ground distance (a texel narrows toward the poles): the flank a curve
/// to the rim, the crater a bowl inside it, the vent a pit; the biome law
/// runs again on the lifted texels (rock and snow on a tall cone's
/// shoulders), then the crater's floor takes basalt (17), a live vent lava (18 -
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
		sc : _tw / 320, lift : array_create(_n, 0), rl : _pn.rlift, vent : array_create(_n, 0), fr : array_create(_n, 0),   // (fr: the lift as a share of its cone's height - the repaint reads it; q271)
		h : function(_k) { return (hash_mix(seed, 30000 + _k) mod 10000) / 10000; },
		// the cone: a lift by ground distance - the flank to the rim, the crater's bowl inside, the vent's pit
		cone : function(_x, _y, _rad, _hgt, _live, _stp) {   // (stp: the flank's exponent - the steeper, the more the height sits at the summit)
			var _cl = max(.2, sin(pi * (_y + .5) / th)), _r = ceil(_rad), _rx = min(tw div 2, ceil(_rad / _cl));
			var _rc = max(1.8, _rad * .26), _rv = max(1.2, _rad * .12);   // (the crater and the pool a few texels across - a one-texel pool drew as a square at the tier; q271)
			var _rf = max(_rv, _rc * .5);   // THE FLOOR (q277): the basalt's reach (the pool's at least); the walls between it and the rim keep the summit's rock
			var _lrim = _hgt * power(1 - _rc / _rad, _stp);   // the rim's lift: the flank's at the crater's edge
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
					el[_i] = lerp(el[_i], _base, power(1 - _d / _rad, 1.8) * .7);   // (the levelling tight to the summit and never whole - the old .6 laid a flat disc round every cone: "a circle of sand"; q271)
					var _l = _hgt * power(1 - _d / _rad, _stp);   // (a stratovolcano's flank: concave - steep at the summit, easing to the plain; a shield's gentler)
					// THE CRATER, A TRUE BOWL (q277; his screenshot: a light spot in the middle of every crater): the old profile kept the
					// flank's rise inside the crater and sank a bowl from it - the centre stood ABOVE the rim. The rim is the flank's
					// height at the crater's edge and the floor sits below it, lowest at the centre (.22 of the cone's height down)
					if (_d < _rc) _l = _lrim - _hgt * .22 * (1 - (_d / _rc) * (_d / _rc));
					_l *= .9 + .2 * dt[_i];
					if (_l > lift[_i]) { lift[_i] = _l; fr[_i] = max(fr[_i], (_d < _rc) ? 1 : (_l / max(.001, _hgt))); }   // (the crater IS the summit: cmask 1 there - q277)
					// the crater's codes (q277): 2 the live vent's pool, 1 the floor (basalt), 4 the WALLS (the summit's rock, lit; a sink
					// for the drainage like the rest - every reader asks vmask > 0)
					if (_d < _rc) {
						var _vc = (_d < _rv) ? (_live ? 2 : 1) : ((_d < _rf) ? 1 : 4);
						if (vent[_i] == 0 || vent[_i] == 4 || (vent[_i] == 1 && _vc == 2)) vent[_i] = _vc;   // (pool over floor over wall where two cones meet - not max(); q281)
					}
				}
			}
		},
		// a flow of lava: from the pool straight to the crater's rim in a hashed direction (lava across the floor and over
		// the wall), then downhill from just outside it, the lowest neighbour each step, a few texels - never back into
		// the floor or the pool. (q281: since the crater is a true bowl the floor is the lowest ground, and a walker that
		// began at the pool wandered the floor and never left)
		flow : function(_x, _y, _len, _salt, _rc) {
			var _cl = max(.2, sin(pi * (_y + .5) / th)), _a = h(_salt) * 360;
			var _cx = _x, _cy = _y, _rs = ceil(_rc) + 1;
			for (var _q = 1; _q <= _rs; _q++) {
				var _qx = (((_x + round(dcos(_a) * _q / _cl)) mod tw) + tw) mod tw, _qy = clamp(_y - round(dsin(_a) * _q), 0, th - 1), _qi = _qx + _qy * tw;
				if (vent[_qi] == 1 || vent[_qi] == 4 || (vent[_qi] == 0 && _q == _rs)) vent[_qi] = 3;
				_cx = _qx; _cy = _qy;
			}
			for (var _s = 0; _s < _len; _s++) {
				var _bi = -1, _bv = 9;
				for (var _dy = -1; _dy <= 1; _dy++) { var _ny = _cy + _dy; if (_ny < 0 || _ny >= th) continue;
					for (var _dx = -1; _dx <= 1; _dx++) { if (_dx == 0 && _dy == 0) continue;
						var _ni = (((_cx + _dx) mod tw) + tw) mod tw + _ny * tw;
						var _v = el[_ni] + (h(_salt + _s * 9 + _dx * 3 + _dy) - .5) * .02;   // (a grain of chance in the way it turns; the cone is in the heights by now)
						if (_v < _bv && vent[_ni] != 1 && vent[_ni] != 2 && vent[_ni] != 3) { _bv = _v; _bi = _ni; } } }   // (never the pool, the floor nor a flow laid; a wall it may cross - q281)
				if (_bi < 0) break;
				if (el[_bi] < sea) break;   // (it stops at the water)
				_cx = _bi mod tw; _cy = _bi div tw;
				vent[_bi] = 3;   // (3 a flow - over the wall, down the flank)
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
	// THE HOTSPOT CHAIN (q248, the temper's hotspot): the volcanoes in a ROW - the plate slid over one plume - each a step
	// along one heading from the last, shrinking, only the LAST alive (the plume is under it now); the first sits as ever
	var _ttv = _pn[$ "tt"], _chain = is_struct(_ttv) && _ttv.hotspot && _arch != "lava";
	if (_chain) { _nv = max(_nv, 4 + (hash_mix(_pn.seed, 31009) mod 2)); _all_live = false; _none_live = true; }
	var _chx = -1, _chy = -1, _chd = (hash_mix(_pn.seed, 31010) mod 360), _chstep = (9 + 3 * ((hash_mix(_pn.seed, 31011) mod 1000) / 1000)) * _sc;
	// THE PRE-CONE HEIGHTS (q272 / q277): the tier runs the biome law on the heights, and a cone's lower flank keeps the
	// map's pre-volcano paint (the repaint below takes the summit only) - so the tier reads THESE there, the heights that
	// paint was decided on. Copied BEFORE the levelling (q277; his screenshot: a brown disc the footprint's size on a
	// snowy range, on the tier alone - the levelling had lowered the footprint toward the perimeter's mean, the tier's
	// law read it warmer, and the caps (10) went to rock (9); the map kept its white)
	var _elp = array_create(_n, 0);
	for (var _i = 0; _i < _n; _i++) _elp[_i] = _el[_i];
	_pn.elevp = _elp;
	for (var _k = 0; _k < _nv; _k++) {
		var _b = 100 * _k, _x = -1, _y = -1, _best = -1;
		if (_chain && _k > 0 && _chx >= 0) {
			// the next of the chain: a step along the heading (ground metric), on land
			var _ccl = max(.2, sin(pi * (_chy + .5) / _th));
			var _nx = (((round(_chx + dcos(_chd) * _chstep / _ccl)) mod _tw) + _tw) mod _tw, _ny = clamp(round(_chy - dsin(_chd) * _chstep), 2, _th - 3);
			if (_el[_nx + _ny * _tw] >= _sea + .01) { _x = _nx; _y = _ny; }
		}
		if (_x < 0)
		// THE SITE (his ask, 2026-09-17: "make sure a volcano spawns in mountain regions"): forty hashed tries on land off the
		// poles; a try on a range's SHOULDER (the skeleton's lift between a hair and a crest) scores high, level ground
		// scores high; the best wins. A world without ranges takes the levellest land
		for (var _t = 0; _t < 40; _t++) {
			var _cx = floor(_c.h(_b + _t * 2) * _tw), _cy = floor((_pole + (_th - 2 * _pole) * _c.h(_b + _t * 2 + 1)));
			var _ci = _cx + _cy * _tw;
			if (_el[_ci] < _sea + .02) continue;
			var _lf = _rl[_ci], _near = (_lf > .02 && _lf < .32) ? 1 : 0;   // (ON the range, not just its shoulder - his ask, q271: "more naturally integrated with mountainous regions")
			var _hi2 = -9, _lo2 = 9;
			for (var _dy = -3; _dy <= 3; _dy += 3) for (var _dx = -3; _dx <= 3; _dx += 3) { var _ny = clamp(_cy + _dy, 0, _th - 1), _nx = ((_cx + _dx) mod _tw + _tw) mod _tw; var _ev = _el[_nx + _ny * _tw]; _hi2 = max(_hi2, _ev); _lo2 = min(_lo2, _ev); }
			var _sc2 = _near * 3 + (_near ? 0 : clamp(1 - (_hi2 - _lo2) / .12, 0, 1));   // (a range site outranks every level plain; level ground only breaks ties among the plains)
			if (_sc2 > _best) { _best = _sc2; _x = _cx; _y = _cy; }
		}
		if (_x < 0) continue;
		var _live = _all_live || (!_none_live && _c.h(_b + 90) < .6);
		if (_chain) { _live = (_k == _nv - 1); _chx = _x; _chy = _y; }   // (the chain: the last one smokes)
		// THE SIZE, PROCEDURAL (his ask, 2026-09-17: "tighter and taller... or at least procedural"): a STRATOVOLCANO two
		// times in three - tight and tall, five to nine texels across, .42-.60 of the relief, a steep concave flank -
		// else a SHIELD, broad and low, ten to sixteen across, .26-.36 tall, an easy flank
		var _strato = (_c.h(_b + 93) < .67);
		var _rad = (_strato ? (5 + 4 * _c.h(_b + 91)) : (10 + 6 * _c.h(_b + 91))) * _sc;
		var _hgt = _strato ? (.42 + .18 * _c.h(_b + 92)) : (.26 + .10 * _c.h(_b + 92));
		if (_chain) { var _age = 1 - _k / max(1, _nv - 1); _rad *= .7 + .5 * (1 - _age) ; _hgt *= .55 + .45 * (1 - _age); }   // (the chain: the old ones worn down, the young one whole)
		_c.cone(_x, _y, _rad, _hgt, _live, _strato ? 2.0 : 1.3);
		array_push(_vents, [_x, _y, _live, _rad, _b]);
	}
	// into the heights (the cone's lift joins rlift for the gullies and the carve), the biome law again under it
	var _lift = _c.lift, _bm = _c.bm, _dt = _c.dt, _mo = _c.mo, _ps = _c.ps, _fr = _c.fr;   // (_rl is the site loop's, above)
	_pn.cmask = _fr;   // (the lift as a share of the cone's height, 1 in the crater - the tier's hand-over reads it; q272 / q277)
	for (var _i = 0; _i < _n; _i++) {
		if (_lift[_i] <= 0) continue;
		_el[_i] = max(_el[_i] + _lift[_i], _sea + ((_c.vent[_i] > 0) ? .03 : .004));   // (a crater's floor well above the tide - at sea + .004 the tier's law read it as shallows, the cyan "lava"; q271)
		_rl[_i] = max(_rl[_i], _lift[_i]);
		// THE FLANK KEEPS ITS GROUND (q271): the biome law repaints only where the cone stands tall - the upper .35 of its
		// lift (a stratovolcano's upper 40% of its radius; VOLCANO_BARE) - so the lower flank runs on in the grass or the
		// forest it rose from, and a cone on a range is a peak of the range. planet_lod_step hands over at the same mark
		if (_fr[_i] < VOLCANO_BARE) continue;
		_ps.oe = _el[_i]; _ps.od = _dt[_i]; _ps.om = _mo[_i];
		planet_biome(_ps, ((_i mod _tw) + .5) / _tw, ((_i div _tw) + .5) / _th);
		// A CONE IS ROCK (q276 / q277; his screenshots: the law read the lifted flank as sand and beach - "a circle of dirt"):
		// the summit takes the world's ROCK PEAK colour (9 - not the tundra's grey-green 7), and the law's snow and cap
		// (8 / 10) where it says so
		_bm[_i] = (_ps.ob == 8 || _ps.ob == 9 || _ps.ob == 10) ? _ps.ob : 9;
	}
	// the flows, then the crater's basalt, the vent's lava (or a dead vent's rock), the plumes
	for (var _k = 0; _k < array_length(_vents); _k++) {
		var _vt = _vents[_k];
		if (_vt[2]) { var _nf = 1 + (hash_mix(_pn.seed, 31500 + _k) mod 3); for (var _f = 0; _f < _nf; _f++) _c.flow(_vt[0], _vt[1], round(_vt[3] * (.8 + .9 * _c.h(_vt[4] + 50 + _f))), _vt[4] + 60 + _f * 200, max(1.8, _vt[3] * .26)); }   // (the crater's reach, as cone() had it - q281)
	}
	var _vent = _c.vent;
	for (var _i = 0; _i < _n; _i++) {
		if (_vent[_i] == 0 || _el[_i] < _sea) continue;
		if (_vent[_i] == 2 || _vent[_i] == 3) _bm[_i] = 18;   // lava: the live vent, the flows
		else if (_vent[_i] == 1) _bm[_i] = 17;                 // basalt: the crater's floor, a dead vent (the walls, 4, keep the summit's rock - q277)
	}
	// THE PLUMES are the shader's now (2026-09-17, "higher quality plumes"): the live vents go to planet_draw as
	// directions on the sphere with the plume's angular radius - sh_planet draws each as a ring of turning, billowing
	// smoke in the ground's frame, at any zoom, and throws its shadow on the ground
	var _pl = [];
	for (var _k = 0; _k < array_length(_vents); _k++) {
		var _vt = _vents[_k];
		if (!_vt[2]) continue;
		// THE SHADER'S FRAME (his report, live test 2026-09-18: "the plume is in random places"): a texel's longitude is
		// (u - .5) x 2 pi in sh_planet (to_tex: u = atan(z, x) / 2 pi + .5) - the same law the regions' spots use
		// (__spot_dir, u = lon / 360 + .5). The vents went out at u x 2 pi: every plume half a turn from its cone
		var _vu = (_vt[0] + .5) / _tw, _vv = (_vt[1] + .5) / _th, _vsl = sin(_vv * pi), _vlon = (_vu - .5) * 2 * pi;
		array_push(_pl, [_vsl * cos(_vlon), cos(_vv * pi), _vsl * sin(_vlon), _vt[3] * .62 * 2 * pi / _tw]);   // (the ring's reach: .62 of the cone, in radians)
	}
	_pn.vents = _pl;
	_pn.vmask = _vent;   // (kept: planet_rivers treats the craters and flows as sinks - no river climbs the cone into the crater, no lake fills it; his report 2026-09-17)
}
