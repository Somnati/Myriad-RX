/// DE's draw (obj_click_multi), to the pixel where it can be: the black
/// ground disc at des_size, the coloured charge disc at the wiggle's
/// radius inside it, "X3" in fnt_outline left-aligned at x with the
/// discs centred under the figure, popping on a level-up. Plus the ring
/// DE's own source carries commented out - draw_ring at des_size + 2,
/// one px, clockwise from twelve - drawn live here through draw_arc
/// (his ask for the circular bar), thin enough to read as part of the
/// widget rather than a second one round it. Everything else about it
/// is DE's; the colour law is the one thing rebuilt (see the Create).

if (alpha <= 0) exit;
var _txt = "X" + string(overcharge_multi());   // DE's capital
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

// THE RING IS OFF (his pass, 2026-09-14: "verify it matches how it looked
// in DE" - DE's draw_ring is commented out in its own source; the charge
// is the disc growing, nothing else). OC_RING brings it back
if (OC_RING) {
	draw_arc(_cx, _cy, OC_RING_R, 1, 1, merge_colour(col, c_black, .8), .4 * alpha);
	draw_arc(_cx, _cy, OC_RING_R, 1, fperc, col, .95 * alpha);
}

// the figure: DE's placement - left at x, its middle two px above the
// disc's centre (DE: (y + 2) - h / 2 with fa_middle)
draw_set_alpha(alpha * talpha);
draw_set_color(col);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text_transformed(x, _cy - 1.5, _txt, tsize, tsize, 0);

draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt);
