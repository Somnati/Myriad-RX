/// @description galaxy_world(star, pi) -> a board world { seed, name, biome, tier, dist, rate, star, pl } for a planet on the star map, or undefined (a gas world, a bad index)
/// THE STAR MAP AS THE BOARD (his ask, 2026-09-16: "so I can click another
/// planet... all planets should work like the current world"): the
/// planet's own seed (everything downstream keys off it: regions, quests,
/// memory, leaders, the villain, rivals), its biome (galaxy_world_biome),
/// its TIER by how far its star sits from home (a neighbour is tier 1, the
/// far rim tier 8; a sibling of the home world tier 2), the flight and
/// the rate by the tier as the old deal had them, its name the star's
/// with a numeral. The home world itself comes back as the board has it.
function galaxy_world(_star, _pi) {
	static _rom = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"];
	var _sm = starmap_get();
	if (_star < 0 || _star >= _sm.count) return undefined;
	var _st = _sm.stars[_star];
	var _sys = starsystem_generate(_st.seed, _st.props);
	if (_pi < 0 || _pi >= array_length(_sys.planets)) return undefined;
	var _pl = _sys.planets[_pi];
	var _b = galaxy_world_biome(_pl);
	if (_b < 0) return undefined;
	var _hm = galaxy_home(), _hs = _sm.stars[_hm.star];
	var _tier;
	if (_star == _hm.star) _tier = (_pi == _hm.planet) ? 1 : 2;
	else _tier = clamp(1 + floor(point_distance(_hs.x, _hs.y, _st.x, _st.y) / _sm.gal_r * 6), 1, 8);
	if (_star == _hm.star && _pi == _hm.planet) _b = 1;   // (the home world is the living one the board promised)
	return { seed : _pl.seed, name : star_name(_star) + " " + _rom[clamp(_pi, 0, 7)], biome : _b, tier : _tier,
	         dist : EXPED_DIST0 * power(2, _tier - 1), rate : 60 * _tier + 40 * (_b == 2), star : _star, pl : _pi };
}
