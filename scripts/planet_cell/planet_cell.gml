/// @description planet_cell() -> the world's shader cell in room px (q301): a page's override (g.planet_px - the map pages set 1 round their stamps, q266), else settings > visuals' fine planet cells (1) or the config's (2)
function planet_cell() {
	var _o = g[$ "planet_px"];
	if (!is_undefined(_o)) return max(0, _o);
	return (g[$ "planet_fine"] ?? true) ? 1 : planet_config().px_size;
}
