if (!unfold_has("timebank")) exit;   // (the unfold: not yet arrived)
if (!__live()) exit;

var _tb = g.timebank;
draw_set_font(fnt);
draw_set_valign(fa_top);

var _pulse = .55 + .3 * dsin(current_time * .35);
draw_sprite_ext(spr_pixel_1x1, 0, cx0, cy0, cw, ch, 0, c_black, .85);
draw_px_rect(cx0, cy0, cw, ch, c_gold, _pulse);
draw_set_halign(fa_center);
draw_set_color(merge_colour(c_gold, c_white, .35));
draw_set_alpha(.95);
draw_text(cx0 + cw * .5, cy0 + 2, "x" + string(_tb.spd) + " - "
	+ ((_tb.bank >= 1) ? crunch_time_long(_tb.bank * 60) : "0s"));
draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
