// the press decay (feedback only)
pop = max(0, pop - .08 * delta);

// persistent now, so the surface re-reads whichever room it is
// standing in (rooms differ in size)
tap_y1 = room_height;

// tapping is live only inside a running game (see __live)
if (!__live()) exit;

// arbitrated region pattern: a tap the menu, a popup or any clickable
// widget already claimed is not ours
if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (mouse_y < tap_y0 || mouse_y > tap_y1) exit;
// the dial drawer claims ONLY its bars, buy buttons and docked strip
// (his rule: profit taps fire even with the dials open). It answers
// from the same rectangles its own tap handling uses, so a press on a
// bar is a UI action and a press beside it is a paid tap - never both.
if (instance_exists(syst_dials))
	if (syst_dials.__consumes(mouse_x, mouse_y)) exit;
if (!variable_global_exists("click_gps")) exit;

// THE TAP: pay what update_click derived, count it, and say so.
// DE rolls a crit here (and drops credits, and spawns bezier profit
// particles that the counter waits on) - each of those re-enters at
// this one site as its layer gets rebuilt.

// ---- THE CRITICAL TAP (DE's give_click, base values kept) ----
// 5% of taps pay a RANDOM multiple between 1.5x and 5x. The randomness
// is the point: a fixed multiplier reads as a bigger number, a rolled
// one reads as luck. do_scale rather than do_multi because the factor
// is a fractional REAL - arb() cannot represent sub-1 values and
// arb(1.5) would pack malformed (the house rule, see the save tour).
var _pay  = g.click_gps;
var _crit = false;
var _cx   = 1;
if (g.click_crit > 0 && roll_perc(g.click_crit)) {
	_crit = true;
	_cx   = random_range(g.click_critx_min, g.click_critx_max);
	_pay  = do_scale(_pay, _cx);
	g.total_crits++;
}

give_profit(_pay);
g.total_taps++;

// THE CREDIT ROLL (DE's give_click): a small chance per tap pulls a
// few credits from the dropper's pool - refused by credit_drop while
// its cooldown runs, so a hot streak can't drain it
if (variable_global_exists("credit_tap_chance"))
if (roll_perc(g.credit_tap_chance)) credit_drop(mouse_x, mouse_y, -1);
pop = 1;

// fnt_outline: float_text's own header names it as the tap floats'
// font and no caller was passing one, so they had been drawing in
// whatever font the room happened to leave set (his note 2026-09-06).
// A float lands on top of the visualiser, which is the busiest thing
// on screen - the outline is what keeps it readable there.
// A CRIT LOOKS DIFFERENT, DE's way: the float blends toward aqua and
// comes up bigger (DE scales its crit float 1.75 and speeds its rise),
// and it says the multiple it rolled - without that the number is just
// large, with it you can see you got lucky. obj_float owns scale_ and
// life as plain instance variables, so the crit dresses the float after
// float_text builds it rather than growing that signature a tail of
// optional arguments.
var _fstr = "+" + crunch_arb(_pay);
if (_crit) _fstr += "  x" + string_format(_cx, 1, 1);
var _f = float_text(mouse_x, mouse_y - 4, _fstr,
	_crit ? merge_colour(g.profit_color, c_aqua, .6) : g.profit_color,
	fnt_outline);
if (_crit) {
	_f.scale_ = 1.75;
	_f.life   = 45;
	_f.life_  = 45;   // life_ is the rise's clock too - move both or the
	                  // float drifts as if it were already old
	_f.rise  *= 1.6;
}

// snd_orb was sitting unused in the project (only a tour comment named
// it). The crit is the moment that wanted a sound of its own, and the
// haptic goes to 3 - DE's own crit is silent, so this is the one place
// the port deliberately adds rather than matches.
if (_crit) play_sound_ext(snd_orb, .95, 1.05, .5, 3);
else       play_sound_ext(snd_click, .95, 1.15, .35, 1);

// THE SPIT: bezier profit bits fly from the tap to the counter. The
// count is the techdemo's law - a tiny tap spits exactly as many bits
// as it earned (so the first taps read as "one profit, one mote"),
// and once the number outgrows counting it settles into a 2-7 burst.
// tic 0 = back-to-back, the tap's rapid-fire style.
var _n = round(random_range(2, 7));
if (arb(15) >= _pay) _n = clamp(unarb(_pay), 1, 7);
if (_crit) _n = min(12, _n + 4);   // a crit throws a fatter handful
// target omitted on purpose: bezier_bits already owns the counter's
// seat as its default, so the two earners cannot aim at different
// places - one constant, in the framework that draws them
// the burst CARRIES this tap's profit: the counter holds it back
// until the motes land (see obj_ui_header's Step)
bezier_bits(mouse_x, mouse_y, _n,
	_crit ? merge_colour(g.profit_color, c_aqua, .6) : g.profit_color,
	undefined, undefined, 0, _pay);
