/// the bit, in whichever LOOK the settings picked (round 7):
/// [standard] = the glowing tiny square (round 5's placeholder, his
/// favorite - soft halo under a small spinning pixel square, both
/// currency-tinted), else one of the Myriad sprites - circle (tinted
/// the currency hue-variant), spinning coin, or munny orb - shrinking
/// to nothing as it closes on the counter. the arrival phase draws
/// the bloom alone, swelling and fading where the counter sits.

if (pop_t >= 0) {
	var _f = 1 - pop_t / 10;
	// (his ask: the halo was too big on every bit - the arrival bloom
	// and the standard look's halo both come down, keeping their shape)
	draw_sprite_ext(spr_vis_glow_soft, 0, tx, ty,
		.26 * (1.4 - _f), .26 * (1.4 - _f), 0, col, .45 * _f);
	exit;
}

if (look == 0) {
	// the standard square, verbatim from round 5
	draw_sprite_ext(spr_vis_glow_soft, 0, x, y, .15 * size, .15 * size, 0,
		col, .35);
	var _s = max(1, 2.5 * size);
	draw_sprite_ext(spr_pixel_1x1, 0, x - _s * .5, y - _s * .5, _s, _s,
		rot, merge_colour(col, c_white, .45), .95);
	exit;
}

draw_sprite_ext(lookspr, frame, x, y, lookscale * size, lookscale * size,
	rot, tint, 1);
