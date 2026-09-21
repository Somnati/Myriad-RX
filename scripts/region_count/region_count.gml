/// @description region_count(dest) -> how many regions the world has (q287 / q294): its territories' count - 0 until the world stands (the ticks skip it then). Reads the planet CACHE alone (planet_peek): it never begins a world
function region_count(_d) {
	if (!is_struct(_d)) return 0;
	var _pn = planet_peek(_d.seed);
	if (!is_struct(_pn)) return 0;
	var _t = _pn[$ "terr"];
	return is_struct(_t) ? _t.n : 0;
}
