/// @description draw_ui_button(x, y, w, h, label, col, [enabled], [primary], [lx], [ly])
/// @param x
/// @param y
/// @param w
/// @param h
/// @param label
/// @param col
/// @param [enabled]
/// @param [primary]
/// @param [lx]
/// @param [ly]
/// the ONE button chrome (ui overhaul, tiers 1 + 3): black fill, 1px
/// frame, centered label. primary = the one thing a row is FOR (buy,
/// fix, install) and draws at full strength; secondary (nav tabs,
/// back, view toggles) is the same shape a step dimmer, so the primary
/// action is unambiguous. enabled=false grays the face (locked /
/// unaffordable). DRAW ONLY - hit tests stay with the owner (region
/// pattern), so the rectangle here must match the owner's rectangle
/// exactly. assumes draw_set_font(fnt).
/// lx/ly (2026-07-13): optional STATIC label anchor. an ANIMATED
/// button (titlescreen's hover bounce) passes its resting rect's
/// label point here, so the sprite-font glyphs stay pixel-pinned
/// while the chrome dances - re-centering on an oscillating rect
/// made the text shimmer across pixel boundaries (his report).
function draw_ui_button(_x, _y, _w, _h, _label, _col, _enabled = true, _primary = true, _lx = undefined, _ly = undefined) {
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _h, 0,
		c_black, _primary ? .8 : .65);
	draw_px_rect(_x, _y, _w, _h, _col,
		!_enabled ? .25 : (_primary ? .85 : .45));

	// centering enforced BOTH ways: valign is set explicitly (a stray
	// fa_middle from another widget was floating labels off-center),
	// and the +1 compensates the sprite font's trailing glyph space
	// (string_width includes it, so fa_center sits a pixel left)
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(!_enabled ? c_gray
		: merge_colour(_col, c_white, _primary ? .4 : .25));
	draw_set_alpha(_primary ? .95 : .85);
	draw_text(_lx ?? (_x + (_w div 2) + 1), _ly ?? (_y + (_h - 7) div 2), _label);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}
