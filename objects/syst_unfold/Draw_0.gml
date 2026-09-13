/// black, and the one word. The word breathes while it waits and goes
/// with the veil once the tap lands (it fades faster than the black,
/// so the room does not surface with a label still floating on it).
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, veil);

var _wa = veil * veil * (armed ? (.55 + .35 * abs(dsin(pt))) : 1)
	* clamp((wt - .5) / .9, 0, 1);   // the arrival
if (_wa > .003) {
	draw_set_font(fnt_large);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_set_alpha(_wa);
	draw_text_transformed(room_width * .5, room_height * .5, "tap", 2, 2, 0);
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	draw_set_font(fnt);
}
