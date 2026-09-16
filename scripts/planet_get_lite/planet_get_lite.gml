/// @description planet_get_lite(seed, [hint]) -> the world at postage-stamp size (48x24), built and baked on the spot, cached by seed
/// THE STAR SYSTEM'S MINI WORLDS (the tech demo's, ported 2026-09-16):
/// the SAME generation the orbit view runs - every roll identical, the
/// maps 48x24 - so what you see on approach is the world you will
/// orbit. A stamp is a thousand samples and three thousand texels: one
/// call builds it whole (planet_gen_step, planet_bake), no slicing.
/// Its own cache (g.planet_lite_c, twenty kept) beside planet_get's.
function planet_get_lite(_seed, _hint = undefined) {
	if (!variable_global_exists("planet_lite_c")) g.planet_lite_c = [];
	var _c = g.planet_lite_c;
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i].seed == _seed) return _c[_i];
	var _pn = planet_gen_begin(_seed, _hint, 48, 24);
	planet_gen_step(_pn, _pn.th);
	planet_bake(_pn);
	array_insert(_c, 0, _pn);
	while (array_length(_c) > 20) {
		var _old = array_pop(_c);
		if (surface_exists(_old.tsurf)) surface_free(_old.tsurf);
		if (surface_exists(_old.csurf)) surface_free(_old.csurf);
		if (surface_exists(_old[$ "hsurf"] ?? -1)) surface_free(_old.hsurf);
	}
	return _pn;
}
