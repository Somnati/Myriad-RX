/// @description region_ready(dest) -> true once the world's territories stand (q287): regions may be asked for and cached; before that region_get hands out a stand-in it does not keep
function region_ready(_d) {
	if (!is_struct(_d)) return false;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	return is_struct(_pn) && is_struct(_pn[$ "terr"]);
}
