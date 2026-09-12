/// @description draw_help_chip(x, y, col, [hot], [a]) - THE "?" CHIP:
/// the little mark after a row's name that says "tap for an
/// explainer". It was a bare glyph at 30% (his verdict, 2026-09-11:
/// "could use some polish"); now it is a 9x9 chip - a dark rounded
/// box, a one-pixel border in the row's colour, the "?" centred - that
/// brightens under the pointer so it reads as a thing you can press.
/// Draw-only (spr_pixel_1x1 stamps, safe under any shader); the
/// owner's hit test keeps its own geometry. Statistics and settings
/// share it, so the two screens' marks agree.
/// @param x      the chip's left edge (put it string_width(name) + 5 past the name)
/// @param y      the chip's top edge (row_y + 3 on a 15px row)
/// @param col    the row's colour - the border and the glyph take it
/// @param [hot]  true under the pointer: lit border, bright glyph
/// @param [a]    an overall alpha (1)
function draw_help_chip(_x, _y, _col, _hot = false, _a = 1) {
	_x = floor(_x); _y = floor(_y);
	// the box: corners knocked off so it reads round at this size
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y,     7, 9, 0, c_black, (_hot ? .9 : .75) * _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x,     _y + 1, 9, 7, 0, c_black, (_hot ? .9 : .75) * _a);
	if (_hot) draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y + 1, 7, 7, 0, _col, .12 * _a);
	// the border, one pixel, in the row's colour - the corners stay open
	var _ba = (_hot ? .9 : .38) * _a;
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y,     7, 1, 0, _col, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y + 8, 7, 1, 0, _col, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _x,     _y + 1, 1, 7, 0, _col, _ba);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 8, _y + 1, 1, 7, 0, _col, _ba);
	// the glyph, centred (the house font is 7 tall; the chip is 9)
	var _ha = draw_get_halign(), _c = draw_get_color(), _al = draw_get_alpha();
	draw_set_halign(fa_center);
	draw_set_color(_hot ? c_white : _col);
	draw_set_alpha((_hot ? .95 : .6) * _a);
	draw_text(_x + 5, _y + 1, "?");
	draw_set_halign(_ha);
	draw_set_color(_c);
	draw_set_alpha(_al);
}
