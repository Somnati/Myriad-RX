/// @description galaxy_home() -> { seed, star, sys, planet, planet_seed, name } - where we are
/// THE HOME SYSTEM (his call, 2026-09-15: "put the current star system in
/// a random one in the galactic map as long as it has a planet that has
/// the same look as the one we are on"): a star out on the disc (not the
/// crowded core, not the rim) whose system holds a temperate rock world
/// (clim .35..65 - the living world's band); that planet's seed IS the
/// expedition board's first world (exped_board_roll), so the world you
/// walk, the sun in its sky and the star on the map are one thing.
/// Deterministic from the galaxy's seed (the candidates are rolled
/// before any nested seeded section can scramble the stream).
function galaxy_home() {
	var _sm = starmap_get();
	if (variable_global_exists("galaxy_home_c") && is_struct(g.galaxy_home_c) && g.galaxy_home_c.seed == _sm.seed) return g.galaxy_home_c;
	var _old = random_get_seed();
	random_set_seed((_sm.seed ^ 90210) & $7fffffff);
	var _cands = [];
	repeat (400) array_push(_cands, irandom(_sm.count - 1));
	rng_release(_old);
	var _pick = -1, _pi = -1, _sys = undefined;
	for (var _c = 0; _c < array_length(_cands) && _pick < 0; _c++) {
		var _si = _cands[_c];
		var _st = _sm.stars[_si];
		var _rd = point_distance(_st.x, _st.y, _sm.cx, _sm.cy) / _sm.gal_r;
		if (_rd < .25 || _rd > .85) continue;
		var _sy = starsystem_generate(_st.seed, _st.props);
		if (DEBUG_HOME && array_length(_sy.planets) < 4) continue;   // (room for the desert, the lava world and the giant beside the home - q210)
		for (var _p = 0; _p < array_length(_sy.planets); _p++) {
			var _pl = _sy.planets[_p];
			if (_pl.kind == "rock" && _pl.clim >= .35 && _pl.clim <= .65) { _pick = _si; _pi = _p; _sys = _sy; break; }
		}
	}
	if (_pick < 0) {
		// (four hundred systems without a temperate world: the first star's first rock)
		_pick = _cands[0]; _sys = starsystem_generate(_sm.stars[_pick].seed, _sm.stars[_pick].props); _pi = 0;
		for (var _p = 0; _p < array_length(_sys.planets); _p++) if (_sys.planets[_p].kind == "rock") { _pi = _p; break; }
	}
	// DEBUG_HOME (q210, his ask 2026-09-18: "all planet types near me so I don't have to go hunt"): the star's props carry the
	// home planet's index, and starsystem_generate re-types the system's other worlds round it (a desert, a lava world, a
	// giant) every time it is generated - so every reader agrees; then THE NEIGHBOURHOOD: of the eight nearest stars, the
	// kinds missing (red giant, white dwarf, pulsar, black hole) are given to the second nearest onward (the nearest stays a
	// plain sun), with the sizes, colours and classes the kinds pass would have hashed for them. Props live for the session
	// (the chart is rebuilt each boot), so the patch runs on every galaxy_home of a fresh chart
	if (DEBUG_HOME) {
		_sm.stars[_pick].props.dbg_home = _pi;
		_sys = starsystem_generate(_sm.stars[_pick].seed, _sm.stars[_pick].props);
		var _hx = _sm.stars[_pick].x, _hy = _sm.stars[_pick].y, _near = [];
		for (var _i = 0; _i < _sm.count; _i++) { if (_i == _pick) continue; var _st2 = _sm.stars[_i]; var _dd = point_distance(_hx, _hy, _st2.x, _st2.y); if (_dd < 400) array_push(_near, { i : _i, d : _dd }); }
		array_sort(_near, function(_a, _b) { return _a.d - _b.d; });
		var _have = { giant : false, dwarf : false, pulsar : false, hole : false };
		for (var _k = 0; _k < min(8, array_length(_near)); _k++) { var _sk = _sm.stars[_near[_k].i].props[$ "skind"] ?? "main"; if (_sk != "main") _have[$ _sk] = true; }
		var _want = ["giant", "dwarf", "pulsar", "hole"], _w = 0, _k = 1;
		while (_w < array_length(_want) && _k < array_length(_near)) {
			var _kind = _want[_w];
			if (_have[$ _kind]) { _w++; continue; }
			var _pp = _sm.stars[_near[_k].i].props, _ss = _sm.stars[_near[_k].i].seed;
			_k++;
			if ((_pp[$ "skind"] ?? "main") != "main") continue;
			var _h1 = (hash_mix(_ss, 4061) mod 1000) / 1000, _h2 = (hash_mix(_ss, 4062) mod 1000) / 1000;
			if (_kind == "giant")       { _pp.skind = "giant";  _pp.size = 3.0 + 1.6 * _h1; _pp.color = merge_colour(_pp.color, rgb(255, 128, 66), .72); _pp.stellar_class = "M III"; }
			else if (_kind == "dwarf")  { _pp.skind = "dwarf";  _pp.size = .35 + .2 * _h1;  _pp.color = merge_colour(_pp.color, rgb(205, 218, 255), .8); _pp.stellar_class = "DA"; }
			else if (_kind == "pulsar") { _pp.skind = "pulsar"; _pp.size = .30 + .12 * _h1; _pp.color = merge_colour(_pp.color, rgb(235, 240, 255), .85); _pp.stellar_class = "PSR"; _pp.spin = .7 + 1.7 * _h2; _pp.tilt = 20 + 50 * _h1; }
			else                        { _pp.skind = "hole"; _pp.hole = true; _pp.size = 1.5 + 1.1 * _h1; _pp.color = merge_colour(_pp.color, (_h2 < .5) ? rgb(175, 205, 255) : rgb(255, 195, 130), .65); _pp.stellar_class = "BH"; }
			_have[$ _kind] = true; _w++;
		}
	}
	var _rom = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"];
	g.galaxy_home_c = { seed : _sm.seed, star : _pick, sys : _sys, planet : _pi, planet_seed : _sys.planets[_pi].seed,
	                  name : star_name(_pick) + " " + _rom[clamp(_pi, 0, 7)] };
	return g.galaxy_home_c;
}
