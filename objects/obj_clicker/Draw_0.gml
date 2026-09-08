/// @description the tap rate readout (DE's obj_draw_clickgps)

// THE MONEY ROOM ONLY. The tap pays everywhere, but everywhere else
// this would be a number floating over somebody's settings page.
// in_room is orientation-aware, so this covers the landscape twin.
if (!in_room(rm_clicker)) exit;

// DE fades it out whenever the rate falls to nothing, rather than
// leaving a "tps 0" sitting on screen: the readout is a thing that
// happens while you are tapping, not a permanent stat. Stats has the
// permanent version.
var _want = 0;
if (tps >= 1) _want = 1;
tps_a = trickle(tps_a, _want, 5);
if (tps_a <= .02) exit;

// CRUNCHED, because DE's own could reach the thousands and "tps 1240"
// is a worse number to read at a glance than "tps 1.2K". arb() cannot
// hold a sub-1 value, hence the floor at 1 - the fade above has already
// decided that anything under 1 is not on screen at all.
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(g.profit_color);
draw_set_alpha(tps_a * .75);
draw_text(6, 25, "tps " + crunch_arb(arb(max(floor(tps), 1))));
draw_set_alpha(1);
