/// @description draw_ui_back(x, y, w, h);
/// @param x
/// @param y
/// @param w
/// @param h
/// THE BACK BUTTON, one shape for every menu screen that has one
/// (saves, settings, statistics, services, the gamepad bench). It was
/// five separate copies of nearly the same chrome - three hand-drawn at
/// .8 fill, two riding draw_ui_button's secondary tier at .65 - so the
/// same control looked different depending on which screen you were
/// standing in.
///
/// THE FILL IS FULLY OPAQUE (2026-09-07, his call). Back is the one
/// control that must never be hard to find: a translucent face let the
/// content behind it read through, and on a busy screen that is exactly
/// when you most want out. Everything else stays as it was - the steel
/// frame, the centred smallcaps label, the house seat at
/// (room_width - 62, header bottom).
///
/// DRAW ONLY. Hit tests stay with the owner (the region pattern), so
/// the rectangle passed here must match the owner's rectangle exactly.
/// Assumes draw_set_font(fnt); the label seat is draw_ui_button's, so
/// the two line up when they sit side by side.
function draw_ui_back(_x, _y, _w, _h) {
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _h, 0, c_black, 1);
	draw_px_rect(_x, _y, _w, _h, rgb(170, 190, 230), .9);

	// centering enforced both ways, draw_ui_button's note: valign is set
	// explicitly (a stray fa_middle from another widget floated labels
	// off-centre) and the +1 compensates the sprite font's trailing
	// glyph space, which string_width counts and fa_center then halves
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(.9);
	draw_text(_x + (_w div 2) + 1, _y + (_h - 7) div 2, "back");

	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
