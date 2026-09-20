/// @description region_get(dest, [ri]) -> the world's region ri (built on first ask, cached by seed and index)
/// Up to EXPED_REGIONS a world (his call, 2026-09-15: three, lv +0 / +2 /
/// +4 over the world's). g.regions holds them for the session; they
/// regenerate identically from the seed, so nothing is saved.
function region_get(_d, _ri = 0) {
	if (!variable_global_exists("regions")) g.regions = {};
	// THE TERRITORIES (q287): a world's regions are its territories - as many as the land cut into (region_count), each on
	// its seed texel, its level by its ring from the gate. Until the world stands (no territories yet) a STAND-IN is handed
	// out and not kept, so the real one is built when it can be
	// (the cache first - a hit costs nothing; the world is consulted only on a miss, or for a stand-in kept from before the
	// world stood, which is remade the moment it has territories - bug pass q293: the old stand-in was remade on EVERY ask)
	var _k0 = string(_d.seed) + ":" + string(max(0, _ri)), _hit = g.regions[$ _k0];
	if (is_struct(_hit) && !(_hit[$ "standin"] ?? false)) return _hit;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d)), _tr = is_struct(_pn) ? _pn[$ "terr"] : undefined;
	var _nr = is_struct(_tr) ? _tr.n : 0;
	if (is_struct(_hit) && _nr == 0) return _hit;   // (the stand-in, until the world stands)
	_ri = (_nr > 0) ? clamp(_ri, 0, _nr - 1) : max(0, _ri);
	var _k = string(_d.seed) + ":" + string(_ri);
	if (!is_struct(g.regions[$ _k]) || (g.regions[$ _k][$ "standin"] ?? false)) {
		var _lv = exped_world_lv(_d) + ((is_struct(_tr) && _ri < array_length(_tr.lv)) ? _tr.lv[_ri] : 2 * min(_ri, 4));
		var _rg = region_gen((_d.seed ^ (_ri * 2654435761)) & $7fffffff, _d.biome, _lv, _ri, _pn);
		if (_nr == 0) _rg.standin = true;   // (kept, marked: remade once the territories stand - never trusted for anything that persists)
		g.regions[$ _k] = _rg;
		scar_apply(_d, _ri, g.regions[$ _k]);   // THE SCARS over the generator (q260): the camp that is a settlement now, the village grown, the dead spread
	}
	return g.regions[$ _k];
}
