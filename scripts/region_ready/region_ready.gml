/// @description region_ready(dest) -> true once the world's territories stand (q287 / q294): regions may be asked for and kept; a trip's clock waits on it. Reads the planet CACHE alone (planet_peek): it never begins a world
function region_ready(_d) {
	if (!is_struct(_d)) return false;
	var _pn = planet_peek(_d.seed);
	return is_struct(_pn) && is_struct(_pn[$ "terr"]);
}
