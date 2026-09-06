/// @description float_text(x, y, text, color, [font]);
/// @param x
/// @param y
/// @param text
/// @param color
/// @param [font] optional font override (e.g. g.font_outline for the
///        tap floats); -1 = whatever font the room left set
/// @param [depth] optional depth override, for a float that belongs to
///        something ABOVE the normal float band - the header's gain pop
///        has to clear the header itself. -9999 = use the band.
/// spawns one floating text: pops in, tilts, drifts up with decaying
/// speed, fades out with a shrink. rebuilt from myriad's obj_float with
/// the myriad-specific plumbing stripped (float_count depth chains,
/// clicker flags, shadow toggles). color arrives as ONE color; the
/// two-tone gradient (lighter top, hue-shifted bottom) that gave the
/// old floats their look is derived here. returns the instance.
function float_text(_x, _y, _str, _col, _font = -1, _depth = -9999) {
	// THE FLOAT BAND, -100 down to -131. Above room content (0+) and
	// above the dial drawer (-20), so feedback lands on top of whatever
	// you tapped; still BEHIND the menu blur layer (-500), so an open
	// menu frosts the floats along with everything else.
	// ⚖️ EACH FLOAT TAKES ITS OWN DEPTH within that band, newest on top.
	// They all shared -100, and GameMaker gives no defined order between
	// instances at the SAME depth - overlapping floats could swap places
	// frame to frame. Myriad DE solved this with a float_count depth
	// chain and the port dropped it (his audit, 2026-09-06). The band is
	// 32 deep, which is far more floats than can ever be alive at once,
	// and it reaches nowhere near the next system up (obj_menu2_bck at
	// -450).
	if (!variable_global_exists("float_seq")) g.float_seq = 0;
	g.float_seq = (g.float_seq + 1) mod 32;
	var _dp = (_depth != -9999) ? _depth : (-100 - g.float_seq);
	var _o = instance_create_depth(_x, _y, _dp, obj_float);
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
