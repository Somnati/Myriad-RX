if (move <= 0) exit;

draw_set_font(fnt);
var _px = x + x_;
var _c  = merge_colour_smooth(c_black, c_lavender, lerp(.2, 1, glow));

// the strip, DE's four corners verbatim: lavender-lit at the LEFT edge
// (where the icon sits) fading to black at the right, then the end-cap
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _px, y - 1, tw, 11, 0,
	_c, c_black, c_black, _c, .8);
draw_sprite_ext(spr_display_units, 1, _px + tw, y, 1, 1, 0, c_black, .8);

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_lavender);
draw_text(_px + 13, y + 1, text);
draw_sprite(spr_particon, 0, _px + 5, y + 4);

draw_set_color(c_white);
