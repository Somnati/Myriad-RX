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

// ---- THE SWEEP (motion blur, his ask 2026-09-10 - the puck's law on
// a sprite) ----
// Where the mote was last drawn to where it is, over a fixed 1/60
// shutter (this frame's travel / delta, so a 144hz monitor blurs as
// much as a 60hz one), drawn K times at K instants along it. A sprite
// cannot average hits the way the raycast does, so each copy carries
// .3 + .7/K alpha: one copy is the plain mote, six copies are a
// streak that stays legible where they do not overlap and stacks to
// solid where they do. K is one copy per mote-width of travel, six at
// most; a mote that has not moved a pixel draws once, as it always
// did. Clamped to 14px so a spawn or a cull is never a streak.
var _mb  = variable_global_exists("motion_blur") ? g.motion_blur : true;
var _sdt = max(delta, .05);
var _bx = _mb ? (x - mbx) / _sdt : 0;
var _by = _mb ? (y - mby) / _sdt : 0;
var _bl = point_distance(0, 0, _bx, _by);
if (_bl > 14) { _bx *= 14 / _bl; _by *= 14 / _bl; _bl = 14; }
mbx = x; mby = y;   // this frame's seat, for the next frame's sweep

if (look == "glow" || look == "plain") {
	// the standard square, verbatim from round 5 - PLAIN is the same
	// square without its halo (his second style, 2026-09-10: "one like
	// it is now and another without the glow")
	if (look == "glow")
		draw_sprite_ext(spr_vis_glow_soft, 0, x, y, .15 * size, .15 * size, 0,
			col, .35);
	// spr_pixel_2x2 exists for exactly this: a square whose ORIGIN IS
	// ITS CENTRE, so it spins in place and sits dead centre in its
	// glow. spr_pixel_1x1's origin is its top-left, which made
	// draw_sprite_ext swing the mote around its own halo at every
	// angle but zero. Reach for the centred one whenever something
	// rotates or has to line up with a glow (his call).
	var _s = max(1, 2.5 * size);
	var _K = (_bl < .75) ? 1 : clamp(ceil(_bl / max(1.5, _s * .8)), 2, 6);
	var _a = (.3 + .7 / _K) * .95;
	var _c = merge_colour(col, c_white, .45);
	for (var _i = 0; _i < _K; _i++) {
		var _f = (_i + .5) / _K;                    // 0 = a shutter ago, 1 = now
		draw_sprite_ext(spr_pixel_2x2, 0, x - _bx * (1 - _f), y - _by * (1 - _f),
			_s * .5, _s * .5, rot, _c, _a);
	}
	exit;
}

// the sprite looks (circle / coin / munny): the same sweep, one copy
// per sprite-width of travel
var _sw = max(2, sprite_get_width(lookspr) * lookscale * size);
var _K2 = (_bl < .75) ? 1 : clamp(ceil(_bl / (_sw * .6)), 2, 6);
var _a2 = .3 + .7 / _K2;
for (var _i = 0; _i < _K2; _i++) {
	var _f = (_i + .5) / _K2;
	draw_sprite_ext(lookspr, frame, x - _bx * (1 - _f), y - _by * (1 - _f),
		lookscale * size, lookscale * size, rot, tint, _a2);
}
