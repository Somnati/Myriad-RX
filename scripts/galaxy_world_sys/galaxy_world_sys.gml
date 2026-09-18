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
	_pi = clamp(_pi, 0, array_length(_sys.planets) - 1);
	_d.gw = { seed : _sm.seed, star : _star, sys : _sys, planet : _pi, planet_seed : _sys.planets[_pi].seed, name : star_name(_star) + " " + _rom[clamp(_pi, 0, 7)] };
	return _d.gw;
}
