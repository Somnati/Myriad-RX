/// @description region_col(dest, ri) -> the region's own colour (q296): its territory's seeded hue, the one the outline wears on the world - c_steelblue for a world without territories
function region_col(_d, _ri) {
	var _pn = is_struct(_d) ? planet_peek(_d.seed) : undefined;
	if (!is_struct(_pn) || !is_struct(_pn[$ "terr"]) || !is_array(_pn.terr[$ "hue"]) || _ri < 0 || _ri >= array_length(_pn.terr.hue)) return c_steelblue;
	return make_colour_hsv(_pn.terr.hue[_ri], 150, 240);
}
