/// one currency bit on a bezier (the Myriad DE obj_bezier_profit
/// port, rebuilt lean - same BEHAVIOR, none of the item-sprite zoo):
/// spat from a payout, it swoops along a random quadratic bezier to
/// the room's counter, shrinking as it closes, and blooms a tiny glow
/// on arrival (the original spawned obj_eff_exporise; the bloom is
/// folded into this object's last phase). spawn through bezier_bits()
/// - it sets start/target/color, jitters both ends, and honors the
/// population cap. the CURVE is the original's recipe: p0 = start,
/// p1 = one random control thrown across the room's width at a height
/// off the start (the lazy outward swoop; Myriad biased downward),
/// p2 = the target; progress accelerates 1.5x over the flight and
/// scales inversely with path length (Myriad's 300/dist mod) so short
/// hops never crawl.

depth = -90; // above room content; the floats (-100) stay on top

col = c_seagreen;         // currency tint (resin default)
amt = 0;                  // the profit this mote is carrying home
swing = -1;               // curve width: -1 = Myriad's throw, else px (aim())
spdm = 1;                 // pace multiplier on the per-step advance (aim())
tx = 48; ty = 12;         // target (bezier_bits sets it, then aim())
t = 0;                    // curve progress 0..1
spd = random_range(.0083, .0167); // Myriad's random_range(.01,.02)/1.2

// THE CURVE IS HIS BEZIER LIBRARY, not a local reimplementation.
// bezier_create seeds the instance-scope curve state (_zero is the
// progress, _zero_adj the per-step advance); aim() pushes the points,
// bezier_approach walks it and bezier_get_x/y evaluate it. Using the
// library also hands us its path-length speed mod for free - the
// clamp_min(300/_point_dist,1) inside bezier_approach is exactly the
// "short hops never crawl" rule this object used to do by hand.
bezier_create(spd);
rot = random(360);
rot_spd = random_range(-10, 10);
size = 1;
pop_t = -1;               // >= 0 = the arrival bloom phase
mbx = x; mby = y;         // where it was LAST DRAWN - the motion blur's sweep (Draw)

p0x = x; p0y = y;         // start (aim() stamps them)
cx = x; cy = y;           // the one control point

// ---- the LOOK is a bit_config id, stamped by the emitter from its
// lane's settings pick (2026-09-10, per-lane; round 7's single
// g.part_style before that): "glow" = the glowing tiny square (the
// round-5 placeholder he liked), "plain" = the same square with no
// halo and no arrival bloom, "circle" = Myriad's spr_part_profit
// tinted a hue-variant of the currency color (the original's
// make_colour_hsv recipe), "coin" = the trio with a slow frame roll
// (coin_image_speed), "munny" = the orb. The sprite/frame set-up
// lives in aim(), because the emitter sets look AFTER create ----
look = "glow";
lookspr = spr_part_profit;
frame = 0;
fspd = 0;
lookscale = 1;                    // munny/coin drew at 1.5x (draw_part)
tint = c_white;

// aim(): bake the curve + the look once start/target/col/look are final
aim = function() {
	if (look == "coin") {
		lookspr = choose(spr_coin, spr_coin_silver, spr_coin_gold);
		frame = choose(0, 1, 2);
		fspd = random_range(0, .05);
		lookscale = 1.5;
	}
	if (look == "munny") {
		lookspr = spr_munny;
		frame = choose(0, 1, 2);
		lookscale = 1.5;
	}
	p0x = x;
	p0y = y;
	// THE MOTE PATH (settings > visuals, DE's part_grav three ways): a
	// caller that named its own swing keeps it (the tile fountain); the
	// default throw takes the setting - Myriad's swoop, a bow, or dead
	// straight
	if (swing < 0 && variable_global_exists("mote_arc") && g.mote_arc != 0)
		swing = (g.mote_arc == 1) ? 14 : 0;
	if (swing < 0) {
		cx = random(room_width);
		cy = y + random_range(-50, 100); // the original's throw, mostly down
	} else {
		// NEARLY STRAIGHT (his ask for the tile fountain: "a subtle
		// curve but nearly straight"): the control is the midpoint of
		// the flight, pushed off the line by up to swing px SIDEWAYS -
		// perpendicular to the flight, so the bend is a bow and never
		// a detour, whatever direction the mote is headed
		var _d = point_direction(p0x, p0y, tx, ty) + 90;
		var _k = random_range(-swing, swing);
		cx = (p0x + tx) * .5 + lengthdir_x(_k, _d);
		cy = (p0y + ty) * .5 + lengthdir_y(_k, _d);
	}
	// the pace: bezier_create rolled Myriad's advance already, so the
	// multiplier lands on top of it (and on the library's own short-hop
	// mod, which a tight curve earns - a room-wide throw made the path
	// long, and the path length is what that mod reads)
	if (spdm != 1) {
		_zero_adj_ *= spdm;
		_zero_adj = _zero_adj_;
	}
	// the three points: start, the thrown control, the counter.
	// bezier_set_point also accumulates _point_dist, which is what
	// bezier_approach's own speed mod reads - so the short-hop rule
	// comes from the library rather than being applied here.
	bezier_set_point(p0x, p0y);
	bezier_set_point(cx, cy);
	bezier_set_point(tx, ty);
	// the circle wears the currency's hue at a rolled sat/val
	// (Myriad's exact blend); coins + munny keep their own art white
	if (look == "circle") tint = make_colour_hsv(colour_get_hue(col),
		round(random_range(75, 255)), round(random_range(75, 255)));
};

// population bookkeeping (bezier_bits caps spawns off this counter)
if (!variable_global_exists("bez_n")) g.bez_n = 0;
g.bez_n += 1;
