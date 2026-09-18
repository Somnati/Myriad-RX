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
			// THE GALAXY'S WORD, LATE (bug hunt 5, 2026-09-18): a world begun before the chart stood (a saved trip's
			// region, at boot) took the biome's hint alone; the first ask that carries the galaxy's ring / plateau lays
			// them on - always before any rows or sheets (the plateau pass reads plateau_ask at the bake; the ring is
			// draw-time), so the world is the same world it would have been
			if (!is_undefined(_hint) && !(_pn[$ "hint_gal"] ?? false) && !is_undefined(_hint[$ "ring"])) {
				_pn.ring = _hint.ring;
				_pn.plateau_ask = (_hint[$ "plateau"] ?? false);
				_pn.hint_gal = true;
			}
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
