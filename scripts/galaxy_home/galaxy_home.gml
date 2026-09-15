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
	var _rom = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"];
	g.galaxy_home_c = { seed : _sm.seed, star : _pick, sys : _sys, planet : _pi, planet_seed : _sys.planets[_pi].seed,
	                  name : star_name(_pick) + " " + _rom[clamp(_pi, 0, 7)] };
	return g.galaxy_home_c;
}
