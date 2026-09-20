/// @description region_count(dest) -> how many regions the world has (q287): its territories' count - 0 until the world stands (the ticks skip it then), 3 for a stamp that never got territories
function region_count(_d) {
	if (!is_struct(_d)) return 0;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (!is_struct(_pn)) return 0;
	var _t = _pn[$ "terr"];
	if (is_struct(_t)) return _t.n;
	if (_pn.kind == "gas") return 0;
	return 0;
}
