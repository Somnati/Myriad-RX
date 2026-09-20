/// @description debug_scenario(sm, pick, pi) -> the home world's index after the rebuild - THE DEBUG HOME (DEBUG_HOME; his ask 2026-09-18: "all planet types near me so I don't have to go hunt"; his roster 2026-09-19: lava / desert / rocky / two living / two gas), applied ONCE, here, on the kept objects - the generators know nothing of it
/// The home system (starsystem_get's kept struct, re-typed in place; the
/// rolls stand, only kind / clim / size move): a DESERT (the "dust" family,
/// a rock at clim .27) on the next planet inward from home, else outward;
/// a LAVA world (clim .10) on the innermost still free; a GAS GIANT on the
/// outermost still free - each only where the system lacks the kind; the
/// home world and the desert marked plateau (the galaxy's word, carried by
/// exped_planet_hint into planet_plateaus: a plateau on its biggest river,
/// the canyon). THE NEIGHBOURHOOD: of the eight nearest stars the kinds
/// missing (red giant, white dwarf, pulsar, black hole) go to the second
/// nearest onward (the nearest stays a plain sun), with the sizes, colours
/// and classes the kinds pass would have hashed; their kept systems, if
/// any, are forgotten so they regenerate as the great ones they are now.
/// Props live for the session (the chart is rebuilt each boot), so this
/// runs on every galaxy_home of a fresh chart. Deletable whole. q212
function debug_scenario(_sm, _pick, _pi) {
	var _st = _sm.stars[_pick], _sys = starsystem_get(_st.seed, _st.props), _pl = _sys.planets, _npl = array_length(_pl);
	// THE ROSTER (his call, 2026-09-19): seven worlds, inner to outer - LAVA, DESERT, ROCKY, LIVING (the home), LIVING, GAS,
	// GAS. The kept list is rebuilt to that shape: the home world's own struct rides into slot 3 (its seed, colour and
	// orbit phase - so its terrain, its regions and its name stay), the other existing structs fill the slots in order
	// and are re-typed, the rest are made by the generator's own per-child law (seed, a hashed phase and pace). Orbits
	// by the generator's gap law, scaled to the star's reach; the star itself untouched
	var _home = (_pi >= 0 && _pi < _npl) ? _pl[_pi] : undefined;
	var _others = [];
	for (var _i = 0; _i < _npl; _i++) if (_i != _pi) array_push(_others, _pl[_i]);
	var _kinds = ["rock", "rock", "rock", "rock", "rock", "gas", "gas"], _clims = [.10, .27, .72, .50, .50, .5, .5];
	var _new = [], _oi = 0, _k2 = _npl;
	for (var _s = 0; _s < 7; _s++) {
		var _p;
		if (_s == 3 && is_struct(_home)) _p = _home;
		else if (_oi < array_length(_others)) _p = _others[_oi++];
		else {
			// a made world: the per-child seed law, a hashed phase, the generator's pace law
			var _sd = (_st.seed ^ ((_k2 + 1) * 2654435761)) & $7fffffff; _k2++;
			_p = { seed : _sd, orbit : 0, kind : "rock", clim : .5, size : 3.5, col : make_colour_hsv(hash_mix(_sd, 3) mod 256, 120, 200),
			       ang : hash_mix(_sd, 5) mod 360, spd : 0, has_ring : false, moon_n : 1 };
		}
		_p.kind = _kinds[_s];
		if (_s != 3) _p.clim = _clims[_s];   // (the home keeps its own temperate climate)
		if (_p.kind == "gas") { _p.size = 5 + 3 * ((hash_mix(_p.seed, 9) mod 1000) / 1000); _p.moon_n = max(_p[$ "moon_n"] ?? 2, 2); _p.has_ring = ((hash_mix(_p.seed, 11) mod 100) < 55); }
		else { _p.size = clamp(_p[$ "size"] ?? 3.5, 2.5, 4.6); if (_s == 0) _p.moon_n = 0; }
		// THE SECOND GRASS-AND-WATER WORLD must land as living or ocean under galaxy_world_biome's hash (the home is forced living
		// there): walk the per-child seeds until one does
		if (_s == 4) { var _try = 0; while ((hash_mix(_p.seed & $7fffffff, 77) mod 100) >= 60 && _try < 40) { _p.seed = (_st.seed ^ ((_k2 + 1) * 2654435761)) & $7fffffff; _k2++; _try++; } }
		array_push(_new, _p);
	}
	// the orbits: the generator's gap law from its first ring, scaled to the star's reach
	var _skd0 = _sys.star[$ "skind"] ?? "main", _great = (_skd0 == "giant" || _skd0 == "hole");
	var _r = _great ? 96 : 34, _rmax = _great ? 210 : 112;
	for (var _s = 0; _s < 7; _s++) { _r += 13.5 * (1 + .14 * _s); _new[_s].orbit = _r; }
	if (_r > _rmax) { var _sc = _rmax / _r; for (var _s = 0; _s < 7; _s++) _new[_s].orbit *= _sc; }
	for (var _s = 0; _s < 7; _s++) { var _q = _new[_s]; if (_q.spd == 0) _q.spd = (.5 + 1.1 * ((hash_mix(_q.seed, 7) mod 1000) / 1000)) / _q.orbit * (((hash_mix(_q.seed, 8) mod 2) == 0) ? 1 : -1) / 600; }
	_new[3].plateau = true; _new[1].plateau = true;   // (the canyon on the home and on the desert)
	_sys.planets = _new;
	var _pi_new = 3;
	// the neighbourhood
	var _hx = _st.x, _hy = _st.y, _near = [];
	for (var _i = 0; _i < _sm.count; _i++) { if (_i == _pick) continue; var _st2 = _sm.stars[_i]; var _dd = point_distance(_hx, _hy, _st2.x, _st2.y); if (_dd < 400) array_push(_near, { i : _i, d : _dd }); }
	array_sort(_near, function(_a, _b) { return _a.d - _b.d; });
	var _have = { giant : false, dwarf : false, pulsar : false, hole : false, brown : false, chroma : false, swell : false, proto : false };
	for (var _k = 0; _k < min(8, array_length(_near)); _k++) { var _sk = _sm.stars[_near[_k].i].props[$ "skind"] ?? "main"; if (_sk != "main") _have[$ _sk] = true; }
	var _want = ["giant", "dwarf", "pulsar", "hole", "brown", "chroma", "swell", "proto"], _w = 0, _k = 1;   // (+ the new kinds - q253)
	while (_w < array_length(_want) && _k < array_length(_near)) {
		var _kind = _want[_w];
		if (_have[$ _kind]) { _w++; continue; }
		var _pp = _sm.stars[_near[_k].i].props, _ss = _sm.stars[_near[_k].i].seed;
		_k++;
		if ((_pp[$ "skind"] ?? "main") != "main") continue;
		var _h1 = (hash_mix(_ss, 4061) mod 1000) / 1000, _h2 = (hash_mix(_ss, 4062) mod 1000) / 1000;
		if (_kind == "giant") {
			// the giant's palette rolled here too (q267; it was forced orange - "the colored giants are still red"): yellow / orange / red / the carbon ruby
			_pp.skind = "giant"; _pp.size = 3.0 + 1.6 * _h1;
			if (_h2 < .28)      { _pp.color = merge_colour(_pp.color, rgb(255, 218, 130), .78); _pp.stellar_class = "G III"; }
			else if (_h2 < .58) { _pp.color = merge_colour(_pp.color, rgb(255, 150, 70),  .76); _pp.stellar_class = "K III"; }
			else if (_h2 < .86) { _pp.color = merge_colour(_pp.color, rgb(255, 100, 58),  .78); _pp.stellar_class = "M III"; }
			else                { _pp.color = merge_colour(_pp.color, rgb(215, 42, 46),   .86); _pp.stellar_class = "C"; }
		}
		else if (_kind == "dwarf")  { _pp.skind = "dwarf";  _pp.size = .35 + .2 * _h1;  _pp.color = merge_colour(_pp.color, rgb(205, 218, 255), .8); _pp.stellar_class = "DA"; }
		else if (_kind == "pulsar") { _pp.skind = "pulsar"; _pp.size = .30 + .12 * _h1; _pp.color = merge_colour(_pp.color, rgb(235, 240, 255), .85); _pp.stellar_class = "PSR"; _pp.spin = .7 + 1.7 * _h2; _pp.tilt = 20 + 50 * _h1; }
		else if (_kind == "hole")   { _pp.skind = "hole"; _pp.hole = true; _pp.size = 1.5 + 1.1 * _h1; _pp.color = merge_colour(_pp.color, (_h2 < .5) ? rgb(175, 205, 255) : rgb(255, 195, 130), .65); _pp.stellar_class = "BH"; }
		else if (_kind == "brown")  { _pp.skind = "brown"; _pp.size = .45 + .25 * _h1; _pp.color = merge_colour(_pp.color, rgb(160, 68, 80), .86); _pp.stellar_class = "L"; }
		else if (_kind == "chroma") { _pp.skind = "chroma"; _pp.size = 1.2 + .6 * _h1; _pp.color = merge_colour(_pp.color, c_white, .82); _pp.stellar_class = "Ch"; }
		else if (_kind == "swell")  { _pp.skind = "swell"; _pp.size = 1.6 + 1.0 * _h1; _pp.color = merge_colour(_pp.color, rgb(255, 150, 70), .60); _pp.stellar_class = "Sw"; _pp.period = 1200 + 4200 * _h2; }
		else                        { _pp.skind = "proto"; _pp.size = .9 + .6 * _h1; _pp.color = merge_colour(_pp.color, rgb(255, 150, 90), .72); _pp.stellar_class = "T Tau"; }
		starsystem_forget(_ss);
		_have[$ _kind] = true; _w++;
	}
	return _pi_new;
}
