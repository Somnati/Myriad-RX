/// DE's three layers: the base (frame 4) in a dark cut of the profit
/// colour, the shine (frame 5) in the profit colour, the icon (frame 0)
/// white - plus the pooled amount beside it, so the pile is legible
/// before it is tapped.
if (x <= x1 + .5) exit;   // fully parked: nothing to draw

var _pc = g.profit_color;
var _b  = merge_colour(_pc, c_black, .55);
var _s  = merge_colour(_pc, c_white, .15 + .15 * dsin(pt));
draw_sprite_ext(sprite_index, 4, x, y, 1, 1, 0, _b, 1);
draw_sprite_ext(sprite_index, 5, x, y, 1, 1, 0, _s, 1);
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// the collect flourish: a brief bloom where the pile was
if (flash > 0) {
	var _gw = sprite_get_width(spr_vis_glow_soft);
	draw_sprite_ext(spr_vis_glow_soft, 0, x + 7, y + 8, 48 / _gw, 48 / _gw, 0,
		_pc, .5 * flash / 20);
}

// the amount, right of the button, in the profit colour
if (g.offline_pool >= arb(1)) {
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(_pc);
	draw_set_alpha(.9);
	draw_text(x + sprite_get_width(sprite_index) + 4, y + 4, "+" + crunch_arb(g.offline_pool));
	draw_set_alpha(1);
	draw_set_color(c_white);
}
