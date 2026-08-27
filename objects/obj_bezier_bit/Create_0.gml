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
tx = 48; ty = 12;         // target (bezier_bits sets it, then aim())
t = 0;                    // curve progress 0..1
spd = random_range(.0083, .0167); // Myriad's random_range(.01,.02)/1.2
rot = random(360);
rot_spd = random_range(-10, 10);
size = 1;
pop_t = -1;               // >= 0 = the arrival bloom phase

p0x = x; p0y = y;         // start (aim() stamps them)
cx = x; cy = y;           // the one control point

// ---- the LOOK rides the SETTINGS pick now (round 7, his ask -
// settings > gameplay > particles): 0 standard = the glowing tiny
// square (the round-5 placeholder he liked, restored), 1 circle =
// Myriad's spr_part_profit tinted a hue-variant of the currency
// color (the original's make_colour_hsv recipe), 2 coin = the trio
// with a slow frame roll (coin_image_speed), 3 munny = the orb ----
look = variable_global_exists("part_style") ? clamp(g.part_style, 0, 3) : 0;
lookspr = spr_part_profit;
frame = 0;
fspd = 0;
lookscale = 1;                    // munny/coin drew at 1.5x (draw_part)
tint = c_white;
if (look == 2) {
	lookspr = choose(spr_coin, spr_coin_silver, spr_coin_gold);
	frame = choose(0, 1, 2);
	fspd = random_range(0, .05);
	lookscale = 1.5;
}
if (look == 3) {
	lookspr = spr_munny;
	frame = choose(0, 1, 2);
	lookscale = 1.5;
}

// aim(): bake the curve + the tint once start/target/col are final
aim = function() {
	p0x = x;
	p0y = y;
	cx = random(room_width);
	cy = y + random_range(-50, 100); // the original's throw, mostly down
	// short paths fly quicker: Myriad's 300/dist mod, floored at 1
	spd *= max(1, 300 / max(1, point_distance(p0x, p0y, tx, ty)));
	// the circle wears the currency's hue at a rolled sat/val
	// (Myriad's exact blend); coins + munny keep their own art white
	if (look == 1) tint = make_colour_hsv(colour_get_hue(col),
		round(random_range(75, 255)), round(random_range(75, 255)));
};

// population bookkeeping (bezier_bits caps spawns off this counter)
if (!variable_global_exists("bez_n")) g.bez_n = 0;
g.bez_n += 1;
