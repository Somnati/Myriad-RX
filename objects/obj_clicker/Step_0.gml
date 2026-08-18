// the press decay (feedback only)
pop = max(0, pop - .08 * delta);

// arbitrated region pattern: a tap the menu, a popup or any clickable
// widget already claimed is not ours
if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (mouse_y < tap_y0 || mouse_y > tap_y1) exit;
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
