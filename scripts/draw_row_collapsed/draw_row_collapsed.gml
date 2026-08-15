/// @description draw_row_collapsed(x, y, w, h, label, [tag], [col])
/// @param x
/// @param y
/// @param w
/// @param h
/// @param label
/// @param [tag]
/// @param [col]
/// the dormant-row shape (ui overhaul, tier 4): empty sockets, locked
/// purchases, unowned gear all collapse into this half-height band so
/// they stop competing with live content. label sits left in muted
/// ink; tag is the single affordance or price at the right ("locked",
/// "socket offline", a cost); col tints the identity pip when the
/// sleeping thing has one. DRAW ONLY - the caller owns the grid math
/// and any hit region. assumes draw_set_font(fnt).
function draw_row_collapsed(_x, _y, _w, _h, _label, _tag = "", _col = c_gray) {
	// a quieter echo of the live zebra rows: dim band, faint top seam
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _h - 1, 0,
		merge_colour(c_black, _col, .07), .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, 1, 0,
		c_hsv(168, 149, 67), .1);

	// identity pip, embers out
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, 2, _h - 1, 0, _col, .3);

	var _ty = _y + (_h - 7) div 2;
	draw_set_halign(fa_left);
	draw_set_color(c_gray);
	draw_set_alpha(.45);
	draw_text(_x + 8, _ty, _label);
	if (_tag != "") {
		draw_set_halign(fa_right);
		draw_text(_x + _w - 8, _ty, _tag);
		draw_set_halign(fa_left);
	}
	draw_set_alpha(1);
}
