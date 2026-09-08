if (n <= 0) exit;

// One loop, one sprite, no state changes inside it. spr_pixel_1x1
// stretched is the house primitive, and here it is literally what the
// effect is: a pixel.
for (var _i = 0; _i < n; _i++) {
	var _s = p[_i];
	var _c = _s.sc;
	// the last few frames fade instead of vanishing. DE pops them out
	// of existence mid-air, which you notice on the long-lived ones.
	var _a = min(1, _s.hp / 12);
	draw_sprite_ext(spr_pixel_1x1, 0, _s.x - _c * .5, _s.y - _c * .5,
		_c, _c, 0, _s.col, _a);
}
draw_set_alpha(1);
