/// @description planet_get_lite(seed, [hint]) -> the world at postage-stamp size (48x24), built and baked on the spot, cached by seed
/// THE STAR SYSTEM'S MINI WORLDS (the tech demo's, ported 2026-09-16):
/// the SAME generation the orbit view runs - every roll identical, the
/// maps 48x24 - so what you see on approach is the world you will
/// orbit. A stamp is a thousand samples and three thousand texels: one
/// call builds it whole (planet_gen_step, planet_bake), no slicing.
/// Its own cache (g.planet_lite_c, twenty kept) beside planet_get's.
/// whole = false (q201; his report: a hitch on [star system] - eight
/// stamps built whole in one frame, a quarter second): BEGIN only - the
/// world comes back with its rows unbuilt (row < th, no textures) for the
/// caller to step a slice a frame (planet_gen_step, then planet_bake with
/// a deadline; planet_lite_ready tells when); a whole request finishes a
/// half-built one from the cache before handing it over
function planet_get_lite(_seed, _hint = undefined, _whole = true) {
	if (!variable_global_exists("planet_lite_c")) g.planet_lite_c = [];
	var _c = g.planet_lite_c;
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i].seed == _seed) {
		var _h = _c[_i];
		if (_whole && !planet_lite_ready(_h)) planet_build_step(_h);   // (finished whole - the one builder's step, q225)
		return _h;
	}
	var _pn = planet_gen_begin(_seed, _hint, 48, 24);
	if (_whole) planet_build_step(_pn);   // (whole, in one call)
	array_insert(_c, 0, _pn);
	while (array_length(_c) > 20) {
		var _old = array_pop(_c);
		if (surface_exists(_old.tsurf)) surface_free(_old.tsurf);
		if (buffer_exists(_old[$ "tbuf"] ?? -1)) buffer_delete(_old.tbuf); if (buffer_exists(_old[$ "cbuf"] ?? -1)) buffer_delete(_old.cbuf); if (buffer_exists(_old[$ "hbuf"] ?? -1)) buffer_delete(_old.hbuf);   // (the kept sheets' buffers - q213)
		if (surface_exists(_old.csurf)) surface_free(_old.csurf);
		if (surface_exists(_old[$ "hsurf"] ?? -1)) surface_free(_old.hsurf);
	}
	return _pn;
}
