/// @description float_text(x, y, text, color, [font]);
/// @param x
/// @param y
/// @param text
/// @param color
/// @param [font] optional font override (e.g. g.font_outline for the
///        tap floats); -1 = whatever font the room left set
/// spawns one floating text: pops in, tilts, drifts up with decaying
/// speed, fades out with a shrink. rebuilt from myriad's obj_float with
/// the myriad-specific plumbing stripped (float_count depth chains,
/// clicker flags, shadow toggles). color arrives as ONE color; the
/// two-tone gradient (lighter top, hue-shifted bottom) that gave the
/// old floats their look is derived here. returns the instance.
function float_text(_x, _y, _str, _col, _font = -1) {
	// depth -100: above room content (0+), still BEHIND the menu blur
	// layer (-500), so open menus frost the floats with everything else
	var _o = instance_create_depth(_x, _y, -100, obj_float);
	with (_o) {
		fnt_use = _font;
		if (_font != -1) draw_set_font(_font); // measure in OUR font
		text = string(_str);
		// two-tone gradient: top drifts toward a desaturated bright
		// version, bottom toward a hue-shifted saturated one
		var _h2 = c_hue(_col) + 30;
		if (_h2 > 255) _h2 -= 255;
		c_top = merge_colour(_col, c_hsv(c_hue(_col), c_sat(_col) / 1.5, 255), .2);
		c_bot = merge_colour(_col, c_hsv(_h2, c_sat(_col) * 1.5, 255), .5);
		sw = string_width(text);
		sh2 = string_height(text);
		if (_font != -1) draw_set_font(fnt); // hand the state back
	}
	return _o;
}
