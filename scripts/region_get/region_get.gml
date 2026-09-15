/// @description region_get(dest, [ri]) -> the world's region ri (built on first ask, cached by seed and index)
/// Up to EXPED_REGIONS a world (his call, 2026-09-15: three, lv +0 / +2 /
/// +4 over the world's). g.regions holds them for the session; they
/// regenerate identically from the seed, so nothing is saved.
function region_get(_d, _ri = 0) {
	if (!variable_global_exists("regions")) g.regions = {};
	_ri = clamp(_ri, 0, EXPED_REGIONS - 1);
	var _k = string(_d.seed) + ":" + string(_ri);
	if (!is_struct(g.regions[$ _k])) g.regions[$ _k] = region_gen((_d.seed ^ (_ri * 2654435761)) & $7fffffff, _d.biome, exped_world_lv(_d) + 2 * _ri, _ri);
	return g.regions[$ _k];
}
