/// @description the tap rate readout - DE's obj_draw_clickgps, properly
/// this time (his ask, 2026-09-09: "put it in the bottom left and have
/// its design resemble the one from DE").
///
/// ⚖️ IT WAS IN THE WRONG PLACE AND IT WAS HALF THE READOUT. It sat at
/// (6, 25), which as of the per-tap port is underneath obj_draw_pertap
/// - two numbers about tapping stacked on the same corner, one drawn
/// over the other. DE never had it there: it lives on the BOTTOM edge,
/// as far from the profit counter as the room allows, because it is the
/// thing you glance at while your finger is busy rather than something
/// you read.
///
/// And it said "tps 12" where DE said "TPS 12 +1.4K/S". The rate on its
/// own is a number about your finger; the rate WITH what it earns is a
/// number about the game, and that second half is the whole reason the
/// readout exists.

// THE MONEY ROOM ONLY. The tap pays everywhere, but everywhere else
// this would be a number floating over somebody's settings page.
// in_room is orientation-aware, so this covers the landscape twin.
if (!in_room(rm_clicker)) exit;
if (variable_global_exists("tps_readout") && !g.tps_readout) exit;   // settings > readouts (DE's tapgps_pos)

// DE's seat: 3px in from the left, 9 off the bottom, slid into rather
// than snapped to (its y trickles). Seeded off-screen in the Create, so
// the first appearance rises from the edge like every later one.
var _desy = room_height - 9;
if (tps_y > room_height + 8) tps_y = room_height + 8;
tps_y = trickle(tps_y, _desy, 5);

// DE fades it out whenever the rate falls to nothing, rather than
// leaving a "tps 0" sitting on screen: the readout is a thing that
// happens while you are tapping, not a permanent stat. Stats has the
// permanent version.
tps_a = trickle(tps_a, (tps >= 1) ? 1 : 0, 5);
if (tps_a <= .02) exit;

// DE smooths the SHOWN rate separately from the real one, and rebuilds
// the crunched string only when the whole number moves - crunch_arb on
// something that changes every frame is a string built sixty times a
// second to say the same thing.
tps_sm = trickle(tps_sm, tps, 5);
if (tps_i != floor(tps_sm)) {
	tps_i   = floor(tps_sm);
	// arb() cannot hold a sub-1 value, hence the floor at 1 - the fade
	// above has already decided anything under 1 is not on screen
	tps_txt = crunch_arb(arb(max(tps_i, 1)));
}

// ---- WHAT THE RATE IS EARNING (DE's `val` tail) ----
// ⚖️ THE EXPECTATION IS COMPUTED HONESTLY, which is the one place this
// does not copy DE. DE's line was
//     val = 1 + lerp(critx_min, critx_max, crit/100)
// which at the base 5% chance reports x2.67 - it lerps between the
// multiplier bounds using the CHANCE as the blend, so a rare crit reads
// as if it were happening on most taps. The true figure is
// 1 + rate x (mean multiplier - 1), about x1.11 at those numbers. RX
// pays the true one in tap_fire, and a readout that disagrees with the
// bank by 2.4x is worse than no readout.
var _ub  = upgrade_bonus_live();
var _rt  = clamp((g.click_crit + _ub.crit_rate) / 100, 0, 1);
var _mn  = (g.click_critx_min + g.click_critx_max) * .5 + _ub.crit_multi;
var _gps = do_scale(do_multi(g.click_gps, arb(max(tps_i, 1))),
	1 + _rt * max(0, _mn - 1));

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
// DE's colour: a dim white, not the profit tint. The profit counter and
// the per-tap readout both wear the money colour; a third thing wearing
// it makes the corner read as one block of numbers.
draw_set_color(merge_colour(c_white, c_black, .7));
draw_set_alpha(tps_a);
draw_text(3, tps_y, "tps " + tps_txt + " +" + crunch_arb(_gps) + "/s");
draw_set_alpha(1);
draw_set_color(c_white);
