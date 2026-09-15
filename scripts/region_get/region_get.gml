/// @description region_get(dest) -> the world's region (built on first ask, cached by seed)
/// ONE region a world for now (his scope). The recommended level is the
/// world's (exped_world_lv). g.regions holds them for the session; they
/// regenerate identically from the seed, so nothing is saved.
function region_get(_d) {
	if (!variable_global_exists("regions")) g.regions = {};
	var _k = string(_d.seed);
	if (!is_struct(g.regions[$ _k])) g.regions[$ _k] = region_gen(_d.seed, _d.biome, exped_world_lv(_d));
	return g.regions[$ _k];
}
