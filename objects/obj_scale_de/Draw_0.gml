/// DE's Draw, line for line (view_xview / view_yview are 0 here)
if (!variable_global_exists("game_started") || !g.game_started) exit;
if (y > room_height + 7) exit;   // DE: visible = false past the floor

// sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);
draw_sprite_part_ext(sprite_index, 1, 0, 0, sprite_width * clamp(perc, 0, 1), sprite_height, x, y, 1, 1,
	merge_colour_smooth(cprev, cnext, (income_track - prevxp) / (maxxp - prevxp)), 1);
draw_sprite_ext(spr_scale_bracket, 0, x - 1, y - 2, 1, 1, 0, c_white, 1);
draw_sprite_ext(spr_scale_bracket, 0, x + sprite_width, y - 2, 1, 1, 0, c_white, 1);
var xx = floor(scale_min);
var rep = 0;
var image, c, mm, ts, ys;
repeat (segments) {
	x_ = (sprite_width * clamp((xx - scale_min) / (scale_max - scale_min), 0, 1));
	if (x_ > 0)
	if (x_ < sprite_width) {
		// alpha
		mm = 2; if (xx == maxxp) mm = 4;
		if (x_ > swdiv)  alpha = ((sprite_width - x_) / swdiv) * mm;
		if (x_ <= swdiv) alpha = (x_ / swdiv) * mm;
		// bracket
		image = 0; if (xx / 3 == floor(xx / 3)) image = 1;
		c = c_white; if (xx == maxxp || xx == 308) { c = merge_colour_smooth(c_dkgray, cnext, clamp(alpha, 0, 1)); image = 2; }
		draw_sprite_ext(spr_scale_bracket, image, x + x_, y - 2, 1, 1, 0, c, 1);
		// text
		if (image == 1 || image == 2) {
			draw_set_font(fnt);
			draw_set_alpha(alpha);
			draw_set_color(c_white);
			if (xx == maxxp) draw_set_color(cnext);
			draw_set_halign(fa_center);
			ts = lerp(.6, 1.1, x_ / sprite_width);   // DE: rm_standard's taper
			ys = lerp(2, -2, x_ / sprite_width);
			// the exponent alone (his call: DE read "e20", never "1.00 xx")
			draw_text_transformed(x + x_, y - 9 + ys, "e" + string(xx), ts, ts, 0);
		}
	}
	xx += segment_scale;
	rep++;
}
// segment correction
if (x_ < sprite_width) segments++;
if (x_ - segment_scale > sprite_width) segments -= 1;
segments = clamp_min(segments, 1);
////////////////// FLAG (DE: g.flagxp, the run before's mark)
xx = (variable_global_exists("rebirth") && g.rebirth.prev_profit >= arb(1)) ? g.rebirth.prev_profit : 0;
x_ = (sprite_width * clamp((xx - scale_min) / (scale_max - scale_min), 0, 1));
// alpha
mm = 2; if (xx == maxxp) mm = 4;
if (x_ > swdiv)  alpha = ((sprite_width - x_) / swdiv) * mm;
if (x_ <= swdiv) alpha = (x_ / swdiv) * mm;
if (xx > 0) {
	if (income_track <  xx) draw_sprite_ext(spr_rebirthflag, 0, x + x_, y + 4, 1, 1, 0, c_white, alpha);
	if (income_track >= xx) draw_sprite_ext(spr_rebirthflag, 1, x + x_, y + 4, 1, 1, 0, c_white, alpha);
}
// rebirth room (RX: the overlay)
if (instance_exists(syst_rebirth) && syst_rebirth.open) {
	var a = syst_rebirth.alpha;
	draw_sprite_ext(spr_pixel_1x1, 0, 0, y + sprite_height + 2, room_width, 12, 0, c_black, .8 * a);
	draw_set_font(fnt);
	draw_set_alpha(a);
	draw_set_color(c_hred);
	draw_set_halign(fa_left);
	draw_text(5, y + sprite_height + 4, "U X" + string(lv));
	draw_set_color(cnext);
	draw_set_halign(fa_right);
	draw_text(room_width - 4, y + sprite_height + 4, "X10 at e" + string(maxxp));
}
// the comparison tag (goes with the loser)
if (SCALE_COMPARE) {
	draw_set_font(fnt);
	draw_set_alpha(.45);
	draw_set_color(c_white);
	draw_set_halign(fa_right);
	draw_text(x - 4, y - 2, "de");
}
draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
