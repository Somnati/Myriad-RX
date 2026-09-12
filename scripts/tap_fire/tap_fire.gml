/// @description tap_fire(count, x, y, [effects]) - pay for `count` taps
/// at once (Myriad DE's give_click(feed)). THE ONE PAYOUT: the press
/// path and the hold path both arrive here, so a tap is worth the same
/// whichever produced it, and there is one place to change when the
/// next layer lands.
///
/// ⚖️ THE COUNT IS THE WHOLE POINT, and it is DE's answer to "what
/// happens when the tap rate passes the frame rate". A game running at
/// 60fps can fire at most 60 discrete taps a second, so at a rate of
/// 1000 a per-tap loop is either wrong (940 taps silently lost, the tap
/// stat and the profit both understated) or ruinous (a thousand arb
/// packs, floats and particle bursts a second). DE instead banks
/// FRACTIONAL taps at rate/60 a frame and hands the whole integer part
/// to one call. So:
///   - the rate is exact at any value, on any machine, at any fps
///   - the arb math packs ONCE per frame instead of once per tap
///   - the frame rate never enters the economy at all
/// obj_clicker owns the accumulator; this owns what a batch is worth.
///
/// `effects` rations the ceremony, never the money - see the caller.
/// @arg [hold]  true = this batch came from the HOLD rather than from a
///              press. Outside the money room a held tap goes SILENT
///              (his ask): the tap still pays everywhere, but a rate
///              ticking away under a settings page or a stats table is
///              a noise you did not ask for and cannot see the source
///              of. The press keeps its sound in every room - that one
///              is feedback that your input landed.
/// @arg [stat]  false = this batch is NOT taps. The puck's bounces pay
///              profit and roll crits exactly like a tap, but a bounce
///              is not something you tapped and must not inflate the
///              lifetime counter or the crit RATE derived against it.
///              DE expressed this by sniffing the caller's identity
///              (give_click's `is_cube`); saying it at the call site is
///              the same law, declared instead of inferred.
function tap_fire(_n, _x, _y, _fx = true, _hold = false, _stat = true) {
	if (_n < 1) return;
	if (!variable_global_exists("click_gps")) return;

	// ---- THE CRITICAL TAP (DE's give_click, base values kept) ----
	// 5% of taps pay a RANDOM multiple between 1.5x and 5x. The
	// randomness is the point: a fixed multiplier reads as a bigger
	// number, a rolled one reads as luck. do_scale rather than do_multi
	// because the factor is a fractional REAL - arb() cannot represent
	// sub-1 values and arb(1.5) would pack malformed (the house rule).
	// Upgrades ride result-side: chance and payout are both ADDED to the
	// base roll rather than replacing it, so the DE values stay the
	// floor and an upgrade reads as a bonus on top of them.
	//
	// ONE ROLL FOR THE WHOLE BATCH, which is DE's law and not an
	// approximation of it: the expected payout is identical to rolling
	// each tap separately (5% of N taps either way), it just arrives in
	// larger, rarer lumps as the rate climbs. That is the right feel for
	// a hold - a stream of tiny crits would read as a flat rate.
	// THE OVERCHARGER takes every counted tap (DE: xp_add x fingers on
	// the press, hp refilled) - before the payout, since the payout is
	// what it multiplies
	if (_stat) overcharge_tap(_n);

	var _ub   = upgrade_bonus_live();
	var _rate = (g.click_crit + _ub.crit_rate) * luck_mod();   // luck leans the crit (DE)
	var _pay  = do_multi(g.click_gps, arb(_n));
	var _crit = false;
	var _cx   = 1;
	if (_rate > 0 && roll_perc(_rate)) {
		_crit = true;
		_cx   = random_range(g.click_critx_min, g.click_critx_max) + _ub.crit_multi;
		_pay  = do_scale(_pay, _cx);
		// DE's accounting, verbatim: a single tap that crits is one
		// crit; a BATCH that crits is credited its expected share, so
		// the lifetime crit RATE stays honest against total_taps
		// instead of reading 100% the moment a hold starts landing.
		// ...against total_taps, so a batch that does not count as taps
		// must not count as crits either - the lifetime crit RATE is
		// derived from the pair and would climb past 100% otherwise
		if (_stat) {
			if (_n == 1) g.total_crits += 1;
			else         g.total_crits += max(1, floor(_n * _rate / 100));
		}
	}

	give_profit(_pay);
	if (_stat) g.total_taps += _n;

	// THE CREDIT ROLL (DE's give_click): a small chance per tap pulls a
	// few credits from the dropper's pool - refused by credit_drop while
	// its cooldown runs, so a hot streak cannot drain it. The chance is
	// scaled by the batch rather than rolled N times: same expectation,
	// one roll, and the cooldown is the real limiter either way.
	// THE MONEY ROOM IS THE ONLY ROOM WITH A CEREMONY (his call). The
	// tap pays everywhere; it only PERFORMS here. Outside it the motes
	// would fly across a settings page and the floats would land on a
	// table of numbers, so both are off and the profit goes straight to
	// the counter.
	var _show = _fx && in_room(rm_clicker);

	if (variable_global_exists("credit_tap_chance"))
	if (roll_perc(g.credit_tap_chance * _n * (1 + _ub.credit_luck / 100) * luck_mod()))
		credit_drop(_x, _y, -1, _show ? 8 : 0);

	// THE SOUND plays in every room - it is the feedback that the tap
	// landed, and a silent tap reads as a broken button. Only the
	// visuals are the money room's. A crit having its own sound is the
	// one place this port deliberately ADDS rather than matches: DE's
	// crit is silent, and the moment wanted one.
	// A HELD TAP IS SILENT OUTSIDE THE MONEY ROOM (his ask). _show is
	// already "are we in the clicker", so this reuses it rather than
	// asking the room a second question.
	if (_fx && (!_hold || _show)) {
		// both are the player's choice now (settings > audio). The crit
		// keeps its haptic: it is the one tap you want to FEEL differently.
		if (_crit) { sfx_play("crit"); vibrate(30, 3); }
		else         sfx_play("tap");
		// ⚖️ THE POINTER'S SQUISH IS THE TAP'S, and it goes with the sound
		// (his ask, 2026-09-10): a held tap in another room plays nothing
		// and shows nothing, so the arrow squashing there was feedback
		// for an event that was not performing. It kicks here, inside the
		// same gate as the sound, and never under an overlay - the tapper
		// keeps paying through settings or statistics, but a pointer
		// bouncing over a settings page is noise on a screen that is not
		// about tapping.
		// ...and only for a tap that IS the pointer's: the puck's bounces
		// pay through here too (puck_pay, _stat false - they are not
		// counted as taps), and the arrow was flinching at every wall
		// (his report, 2026-09-10)
		// ...and only HELD taps: the press itself already kicked the
		// arrow in obj_cursor's Step (a click is a click, everywhere)
		if (_stat && _hold && ui_overlay() == noone) cursor_kick();
	}

	if (!_show) {
		// STRAIGHT INTO THE COUNTER. give_profit registers every earn as
		// "in flight" so the header can withhold it until the motes
		// carrying it land - and with no motes spawning, that hold would
		// never be released and the counter would sit frozen below the
		// real balance forever. Releasing it here is the same line
		// offline_replay uses for the same reason: nothing is carrying
		// this profit, so nothing should be waiting on it.
		g.profit_flight = (g.profit_flight > _pay)
			? do_subtract(g.profit_flight, _pay) : 0;
		return _pay;
	}

	// ---- THE FLOAT ----
	// fnt_outline: a float lands on top of the visualiser, which is the
	// busiest thing on screen, and the outline is what keeps it
	// readable there.
	// A CRIT LOOKS DIFFERENT, DE's way: its own colour, a bumped scale
	// and hp_ * 2. Gold is already the game's word for money and the
	// size only has to be noticeable, not loud; the extra dwell is what
	// actually sells it, because a number you get to read is a number
	// you remember.
	var _fstr = "+" + crunch_arb(_pay);
	if (_crit) _fstr += "  x" + string_format(_cx, 1, 1);
	// a batch says how many taps it was: without it a hold looks like
	// one enormous tap rather than the rate it actually is
	if (_n > 1) _fstr += "  " + string(_n) + "x";
	var _col = g.profit_color;
	if (_crit) _col = c_gold;
	// TAP NUMBERS, DE's taptextformat (settings > readouts): at the
	// tap, one big figure in the middle of the room (DE's centre: half
	// across, two-fifths down), or none at all
	var _tt = variable_global_exists("tap_text") ? g.tap_text : 0;
	if (_tt != 2) {
		var _flx = _x, _fly = _y - 4;   // (_fx is the argument - the effects flag)
		if (_tt == 1) { _flx = room_width * .5; _fly = room_height / 2.5; }
		var _f = float_text(_flx, _fly, _fstr, _col, fnt_outline);
		if (_tt == 1) _f.scale_ = _crit ? 1.6 : 1.25;
		if (_crit) {
			if (_tt != 1) _f.scale_ = 1.3;
			_f.life   = 60;   // DE doubles the float's hp on a crit
			_f.life_  = 60;   // life_ is the rise's clock too - move both or
			                  // the float drifts as if it were already old
		}
	}

	// THE SPIT: bezier profit bits fly from the tap to the counter. The
	// count is the techdemo's law - a tiny tap spits exactly as many
	// bits as it earned (so the first taps read as "one profit, one
	// mote"), and once the number outgrows counting it settles into a
	// 2-7 burst. target omitted on purpose: bezier_bits already owns the
	// counter's seat as its default, so the two earners cannot aim at
	// different places. The burst CARRIES this tap's profit - the
	// counter holds it back until the motes land.
	var _bn = round(random_range(2, 7));
	if (arb(15) >= _pay) _bn = clamp(unarb(_pay), 1, 7);
	if (_crit) _bn = min(12, _bn + 4);   // a crit throws a fatter handful
	bezier_bits(_x, _y, _bn, _col, undefined, undefined, 0, _pay);

	// THE TAP EFFECT (syst_tapfx - the [fx] chip in the money room
	// picks): only a performed tap, so it sits here
	tapfx_fire(_x, _y, _crit, _n);
	return _pay;   // (the puck's throw ledger reads it - see puck_pay)
}
