/// @description planet_get(seed, [hint]) -> the world for this seed,
/// from a small cache (planet_config().keep worlds), begun if new. The
/// caller steps it (planet_gen_step) until ready, then planet_draw
/// bakes and draws it. A world is pure data from its seed, so the same
/// seed is the same world whenever it is asked for again.
function planet_get(_seed, _hint = undefined) {
	if (!variable_global_exists("planet_cache")) g.planet_cache = [];
	var _c = g.planet_cache;
	for (var _i = 0; _i < array_length(_c); _i++)
		if (_c[_i].seed == _seed) {
			// most recently used to the front
			var _pn = _c[_i];
			array_delete(_c, _i, 1);
			array_insert(_c, 0, _pn);
			return _pn;
		}
	var _pn = planet_gen_begin(_seed, _hint);
	array_insert(_c, 0, _pn);
	while (array_length(_c) > planet_config().keep) {
		var _old = array_pop(_c);
		if (surface_exists(_old.tsurf)) surface_free(_old.tsurf);
		if (buffer_exists(_old[$ "tbuf"] ?? -1)) buffer_delete(_old.tbuf); if (buffer_exists(_old[$ "cbuf"] ?? -1)) buffer_delete(_old.cbuf); if (buffer_exists(_old[$ "hbuf"] ?? -1)) buffer_delete(_old.hbuf);   // (the kept sheets' buffers - q213)
		if (surface_exists(_old.csurf)) surface_free(_old.csurf);
		if (surface_exists(_old.hsurf)) surface_free(_old.hsurf);
	}
	return _pn;
}
