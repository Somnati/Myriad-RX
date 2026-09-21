/// @description planet_peek(seed) -> the world's struct if the cache holds it, else undefined - NOTHING BEGUN (q294): the ticks ask after every world on the board every second; planet_get would begin one per ask and evict the last (33 worlds, eight kept: 32 begun a frame, 2.4 gb - his profile)
function planet_peek(_seed) {
	if (!variable_global_exists("planet_cache")) return undefined;
	var _c = g.planet_cache;
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i].seed == _seed) return _c[_i];
	return undefined;
}
