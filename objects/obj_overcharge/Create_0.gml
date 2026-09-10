/// obj_overcharge - THE OVERCHARGER (Myriad DE's obj_click_multi, ported
/// 2026-09-10, his ask: "bring it as is with the same look/feel... fix
/// its color tiers"). Tapping charges it; every level is another x1 on
/// what a tap pays (x2, x3 ... x5, or x10 with the cap ability); stop
/// tapping and it drains back down. It sits beside the per-tap readout
/// as the "X3" in the level's colour, a small disc breathing behind the
/// figure that grows with the charge, and - his circular bar - a ring
/// round it that fills as the next level nears (draw_arc).
///
/// ⚖️ THE COLOUR TIERS, FIXED. DE coloured the level through
/// mod_get_gpscolor(lv - 1) - the rarity ladder, so x2 is white and x3
/// is green - but recomputed it on a sixty-frame throttle (pupdate) and
/// merged toward it through a second pair of variables the Draw never
/// read. So the ring wore the OLD level's colour for up to a second and
/// sometimes longer, and "white until x3" is what he saw. Here the
/// colour is vis_tier_color(lv - 1), read the moment the level changes,
/// and the ring glides from the previous colour to it over a few frames
/// (col_t) - one lerp, both ends visible in the same place.
///
/// ⚖️ THE STATE IS TWO NUMBERS, g.overcharge_lv and g.overcharge_xp,
/// seeded by create_clicker and saved with the tap; the multiplier
/// derives (overcharge_multi) and update_click folds it into click_gps
/// result-side, so the per-tap readout shows the charged figure the way
/// DE's did. tap_fire feeds it (overcharge_tap). The knobs are OC_*.
///
/// PERSISTENT, spawned once by obj_clicker (the tap surface, itself
/// persistent from the boot room): the charge drains wherever you are,
/// and it draws only in the money room.

persistent = true;
depth = -110;     // over the per-tap readout (-100 lane), under the header

hp      = 0;      // frames since the last tap counted down from OC_HOLD
alpha   = 0;      // the whole thing's presence (lv 1 = invisible)
fperc   = 0;      // eased charge, 0..1, for the disc and the ring
tsize   = 1;      // the figure's pop on a level-up
talpha  = 1;
col     = c_white;   // what draws
col_from = c_white;  // the previous level's colour (the glide's start)
col_to   = c_white;  // the current level's
col_t    = 1;        // 0..1 along the glide
prev_lv  = 1;
flash    = 0;        // a level-up bloom

// the disc's wiggle (DE's set_wiggle(.05, .96) - a spring toward the
// target that a level-up kicks)
rd  = 0;          // the disc's live radius
rdv = 0;

__col_of = function(_lv) {
	// the rarity ladder: x2 white, x3 green, x4 blue, x5 purple...
	return (_lv <= 1) ? c_white : vis_tier_color(_lv - 1);
};

__seat = function() {
	// beside the per-tap figure (obj_draw_pertap draws it at 5, 37 in
	// fnt_large and publishes text_width) - DE's placement
	if (instance_exists(obj_draw_pertap)) {
		x = 5 + obj_draw_pertap.text_width + 16;
		y = 37 + 6;
	}
};
