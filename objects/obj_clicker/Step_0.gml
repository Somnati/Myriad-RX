// the press decay (feedback only)
pop = max(0, pop - .08 * delta);

// arbitrated region pattern: a tap the menu, a popup or any clickable
// widget already claimed is not ours
if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (mouse_y < tap_y0 || mouse_y > tap_y1) exit;
// never tap THROUGH the dial drawer, docked or out: it asks the drawer
// where its face is this frame rather than duplicating the geometry
if (instance_exists(syst_dials))
	if (mouse_x >= syst_dials.face) exit;
if (!variable_global_exists("click_gps")) exit;

// THE TAP: pay what update_click derived, count it, and say so.
// DE rolls a crit here (and drops credits, and spawns bezier profit
// particles that the counter waits on) - each of those re-enters at
// this one site as its layer gets rebuilt.
give_profit(g.click_gps);
g.total_taps++;
pop = 1;

float_text(mouse_x, mouse_y - 4, "+" + crunch_arb(g.click_gps), c_gold);
play_sound_ext(snd_click, .95, 1.15, .35, 1);

// THE SPIT: bezier profit bits fly from the tap to the counter. The
// count is the techdemo's law - a tiny tap spits exactly as many bits
// as it earned (so the first taps read as "one profit, one mote"),
// and once the number outgrows counting it settles into a 2-7 burst.
// tic 0 = back-to-back, the tap's rapid-fire style.
var _n = round(random_range(2, 7));
if (arb(15) >= g.click_gps) _n = clamp(unarb(g.click_gps), 1, 7);
bezier_bits(mouse_x, mouse_y, _n, c_gold, BEZ_X, BEZ_Y, 0);
