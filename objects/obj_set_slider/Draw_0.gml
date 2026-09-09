// par_slider's draw, replicated (NOT pair) so the readout can carry
// the suffix ("80%", "120 fps") - the parent draws a bare number

// ⚖️ EVERY ALPHA HERE RIDES image_alpha (2026-09-09). The settings
// overlay dissolves its rows through a shader, and a widget drawing in
// its own event is never inside that - image_alpha is how a chaperoning
// screen fades one. Toggles and radios have no Draw and honour it for
// free; this one paints by hand, so it has to say so. It is 1 unless
// something is deliberately fading the widget, so nothing else changes.
var _ia = image_alpha;

draw_sprite_ext(spr_pixel_1x1, 0, xmin + 1, y + (ww / 2) - ceil(bh / 2) + 1,
	xmax - xmin + ww - 1, bh, 0, c0, abar * _ia);
if (tfiller) draw_sprite_ext(spr_pixel_1x1, 0, xmin + 1,
	y + (ww / 2) - ceil(bh / 2) + 1, (xx - xmin) + (ww / 2), bh, 0, cbar, abar * _ia);

// the knob: ONE solid frame, scale-eased between the inset (7/9) and
// full size while grabbed (round 26 - the old img frame-swap made
// the track margin around the knob POP back in when a drag settled)
var _ks = (7 + 2 * gsc) / 9;
var _ko = 9 * (1 - _ks) * .5;
draw_sprite_ext(sprite_index, 2, x1 + 1 + _ko, y1 + 1 + _ko, _ks, _ks,
	0, c1, _ia);

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(_ia);
draw_text(xmax + ww + 5, y + 1, string(val) + suffix);
draw_set_alpha(1);
