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
// upgrades ride the tap result-side too: chance and payout are both
// ADDED to the base roll rather than replacing it, so the DE values
// stay the floor and an upgrade reads as a bonus on top of them
var _ub   = upgrade_bonus_live();
var _rate = g.click_crit + _ub.crit_rate;
var _pay  = g.click_gps;
var _crit = false;
var _cx   = 1;
if (_rate > 0 && roll_perc(_rate)) {
	_crit = true;
	_cx   = random_range(g.click_critx_min, g.click_critx_max) + _ub.crit_multi;
	_pay  = do_scale(_pay, _cx);
	g.total_crits++;
}

give_profit(_pay);
g.total_taps++;

// THE CREDIT ROLL (DE's give_click): a small chance per tap pulls a
// few credits from the dropper's pool - refused by credit_drop while
// its cooldown runs, so a hot streak can't drain it
// THE MONEY ROOM IS THE ONLY ROOM WITH A CEREMONY (his call). The tap
// pays everywhere; it only PERFORMS here. Outside it the motes would
// fly across a settings page and the floats would land on a table of
// numbers, so both are off and the profit goes straight to the counter.
var _show = in_room(rm_clicker);

if (variable_global_exists("credit_tap_chance"))
if (roll_perc(g.credit_tap_chance * (1 + _ub.credit_luck / 100)))
	credit_drop(mouse_x, mouse_y, -1, _show ? 8 : 0);
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
if (!_show) {
	// STRAIGHT INTO THE COUNTER. give_profit registers every earn as
	// "in flight" so the header can withhold it until the motes
	// carrying it land - and with no motes spawning, that hold would
	// never be released and the counter would sit frozen below the real
	// balance forever. Releasing it here is the same line offline_replay
	// uses for the same reason: nothing is carrying this profit, so
	// nothing should be waiting on it.
	g.profit_flight = (g.profit_flight > _pay)
		? do_subtract(g.profit_flight, _pay) : 0;
	if (_crit) play_sound_ext(snd_orb, .95, 1.05, .5, 3);
	else       tap_sound_play();
	exit;
}

var _fstr = "+" + crunch_arb(_pay);
if (_crit) _fstr += "  x" + string_format(_cx, 1, 1);
// A CRIT IS GOLD, A LITTLE BIGGER, AND HANGS ABOUT (his correction -
// DE's crit = 2 branch: its own colour, a bumped scale and hp_ * 2).
// The first cut blended toward aqua at 1.75 scale, which read as a
// different KIND of event rather than a lucky one. Gold is already the
// game's word for money and the size only has to be noticeable, not
// loud; the extra dwell is what actually sells it, because a number you
// get to read is a number you remember.
var _f = float_text(mouse_x, mouse_y - 4, _fstr,
	_crit ? c_gold : g.profit_color, fnt_outline);
if (_crit) {
	_f.scale_ = 1.3;
	_f.life   = 60;   // DE doubles the float's hp on a crit
	_f.life_  = 60;   // life_ is the rise's clock too - move both or the
	                  // float drifts as if it were already old
}

// snd_orb was sitting unused in the project (only a tour comment named
// it). The crit is the moment that wanted a sound of its own, and the
// haptic goes to 3 - DE's own crit is silent, so this is the one place
// the port deliberately adds rather than matches.
// The SOUND plays in every room - it is the feedback that the tap
// landed, and a silent tap reads as a broken button. Only the visuals
// are the money room's.
if (_crit) play_sound_ext(snd_orb, .95, 1.05, .5, 3);
else       tap_sound_play();   // settings > audio > tap sound

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
	_crit ? c_gold : g.profit_color,
	undefined, undefined, 0, _pay);
