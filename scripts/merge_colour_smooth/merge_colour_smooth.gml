/// @description merge_colour_smooth(col1, col2, amount) - Myriad DE's
/// merge (GMLscripts' merge_color_squared): components are SQUARED
/// before the lerp and rooted after, so mixes look natural instead of
/// muddy. 0 = col1, 1 = col2. The credit panel's backing uses it.
function merge_colour_smooth(_c1, _c2, _a) {
	_a = clamp(_a, 0, 1);
	var _r = sqrt(lerp(sqr(colour_get_red(_c1)),   sqr(colour_get_red(_c2)),   _a));
	var _g = sqrt(lerp(sqr(colour_get_green(_c1)), sqr(colour_get_green(_c2)), _a));
	var _b = sqrt(lerp(sqr(colour_get_blue(_c1)),  sqr(colour_get_blue(_c2)),  _a));
	return make_colour_rgb(_r, _g, _b);
}
