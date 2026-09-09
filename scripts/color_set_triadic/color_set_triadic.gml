/// @description color_set_triadic(c, dir) - one third of the way round
/// the wheel from c, keeping its saturation and value.
/// @param c
/// @param dir  1 = forward (+120 deg), 0 = back (-120)
///
/// Myriad DE's colour_set_triadic, ported for obj_draw_pertap - which
/// tints its label a triad off g.profit_color, so the "per tap" caption
/// relates to the profit colour without being it. Spelled the house way
/// (color_*, beside color_set_comp and color_set_random) rather than
/// DE's British original; the maths is unchanged.
function color_set_triadic(argument0, argument1) {
	var _p = lerp(0, 360, colour_get_hue(argument0) / 255);
	if (argument1 == 1) _p += 360 / 3;
	if (argument1 == 0) _p -= 360 / 3;
	if (_p < 0)   _p += 360;
	if (_p > 360) _p -= 360;

	return make_colour_hsv(lerp(0, 255, _p / 360),
		c_sat(argument0), c_val(argument0));
}
