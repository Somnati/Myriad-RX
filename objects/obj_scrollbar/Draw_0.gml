/// the bar: a dim track and the thumb over it.
/// `col` is the owner's to set - the menu drawer tints it to the room
/// you are currently in, so the bar carries the same identity colour as
/// the row it is sitting beside. Owners that leave it white get exactly
/// what this always looked like.

draw_sprite_ext(spr_pixel_1x1, 0, x, y, sprite_width * balpha, sh, 0,
	c_black, .4 * balpha);
draw_sprite_ext(spr_pixel_1x1, 0, x, y + bar_y, sprite_width * balpha,
	bar_height, 0, col, 1 * balpha);
