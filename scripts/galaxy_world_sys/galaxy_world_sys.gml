/// @description galaxy_world_sys(dest) -> { seed, star, sys, planet, planet_seed, name } the star system a board world sits in (galaxy_home's shape), cached on the world
/// A world from the star map (exped_world_open) carries star + pi; an
/// older record (a trip saved before the map) finds its world on the
/// board by seed, else it is the home world's. The sun's bearing, the
/// sky, the year and the ring / moons all read this (2026-09-16).
function galaxy_world_sys(_d) {
	static _rom = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"];
	if (is_struct(_d[$ "gw"])) return _d.gw;
	var _star = _d[$ "star"] ?? -1, _pi = _d[$ "pl"] ?? -1;
	if (_star < 0 && variable_global_exists("exped") && is_struct(g.exped)) {
		for (var _i = 0; _i < array_length(g.exped.board); _i++) { var _b = g.exped.board[_i]; if (_b.seed == _d.seed && (_b[$ "star"] ?? -1) >= 0) { _star = _b.star; _pi = _b.pl; break; } }
	}
	var _hm = galaxy_home();
	if (_star < 0 || (_star == _hm.star && _pi == _hm.planet)) { _d.gw = _hm; return _hm; }
	var _sm = starmap_get();
	_star = clamp(_star, 0, _sm.count - 1);
	var _st = _sm.stars[_star];
	var _sys = starsystem_get(_st.seed, _st.props);
	// AN EMPTY SYSTEM (q255): a protostar has no worlds (q253) - every reader downstream indexes planets[planet] (the
	// sky builder, the sun's bearing, the season, the siblings), so the record reads through a COPY of the system
	// holding one virtual world at a middling orbit (hashed phase and pace, the generator's law) - a sky with a sun
	// and no siblings, never an index into nothing. The real system object is untouched (the page draws it empty)
	if (array_length(_sys.planets) == 0) {
		var _vs = (_st.seed ^ 2654435761) & $7fffffff;
		var _virt = { seed : _vs, orbit : 60, kind : "rock", clim : .5, size : 3, col : c_gray, ang : hash_mix(_vs, 5) mod 360,
		              spd : (.5 + 1.1 * ((hash_mix(_vs, 7) mod 1000) / 1000)) / 60 * (((hash_mix(_vs, 8) mod 2) == 0) ? 1 : -1) / 600,
		              has_ring : false, moon_n : 0, virt : true };
		var _copy = {};
		var _keys = variable_struct_get_names(_sys);
		for (var _k = 0; _k < array_length(_keys); _k++) variable_struct_set(_copy, _keys[_k], variable_struct_get(_sys, _keys[_k]));
		_copy.planets = [ _virt ];
		_d.gw = { seed : _sm.seed, star : _star, sys : _copy, planet : 0, planet_seed : _vs, name : star_name(_star), empty : true };
		return _d.gw;
	}
	_pi = clamp(_pi, 0, array_length(_sys.planets) - 1);
	_d.gw = { seed : _sm.seed, star : _star, sys : _sys, planet : _pi, planet_seed : _sys.planets[_pi].seed, name : star_name(_star) + " " + _rom[clamp(_pi, 0, 7)] };
	return _d.gw;
}
