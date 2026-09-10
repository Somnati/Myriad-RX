/// DE's draw, plus the ring: the black ground disc, the coloured disc
/// at the wiggle's radius, the ring filling clockwise from twelve as
/// the next level nears, then "X3" in fnt_outline over all of it,
/// popping on a level-up.

if (alpha <= 0) exit;
var _txt = "x" + string(overcharge_multi());
draw_set_font(fnt_outline);
var _tw = string_width(_txt);
var _cx = x + _tw * .5;
var _cy = y;

// the ground, then the charge disc (DE: des_size 4, the wiggle's rd)
draw_set_alpha(alpha / 1.5);
draw_circle_colour(_cx, _cy, OC_DISC_R, c_black, c_black, false);
draw_set_alpha(alpha);
var _cc = merge_colour(col, c_black, .5);
if (rd > .5) draw_circle_colour(_cx, _cy, rd, _cc, _cc, false);

// the ring - his circular bar, the level's colour, a dim track under it
var _rr = OC_RING_R;
draw_arc(_cx, _cy, _rr, 2, 1, merge_colour(col, c_black, .75), .55 * alpha);
draw_arc(_cx, _cy, _rr, 2, fperc, col, .95 * alpha);

// the level-up bloom
if (flash > 0) {
	var _gw = sprite_get_width(spr_vis_glow_soft);
	draw_sprite_ext(spr_vis_glow_soft, 0, _cx, _cy, 40 / _gw, 40 / _gw, 0, col, .6 * flash * alpha);
}

// the figure
draw_set_alpha(alpha * talpha);
draw_set_color(col);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text_transformed(_cx - _tw * .5 * tsize, _cy + 1, _txt, tsize, tsize, 0);

draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt);
