/// @description tap_rate() - taps a second while the button is HELD
/// (Myriad DE's get_tps). The hold is not a second tap button, it is a
/// RATE, and this is the one place that rate is decided.
///
/// DE's sources, in DE's order: a base that certain screens and the
/// fast-tapper ability grant, upgrade points, a gear percentage, a goal
/// multiplier, then the ability multipliers, then gear again as a flat
/// add. RX has upgrades today; the rest re-enter HERE, result-side, as
/// those layers land - which is why the empty seats are named below
/// instead of left to be rediscovered from DE months from now.
///
/// ⚖️ NOT FLOORED, unlike DE's. DE returns a whole number because what
/// read it was a display, but the consumer that matters is obj_clicker's
/// accumulator, which adds rate/60 every frame - a perfectly fractional
/// quantity. Flooring there throws away every gain smaller than one
/// whole tap a second, so a +5% upgrade on a base of 8 would do exactly
/// nothing. The readout floors it at the draw, which is where flooring
/// belongs.
function tap_rate() {
	var _r = TAP_HOLD_BASE;

	// ---- UPGRADES, RESULT-SIDE ----
	// The adapter contract: multiply what was derived, never the inputs.
	var _ub = upgrade_bonus_live();
	if (_ub.tap_rate > 0) _r *= 1 + _ub.tap_rate / 100;

	// SEATS NOT BUILT YET. DE has all three and every one of them
	// multiplies the result rather than moving the base:
	//   abilities  fast tapper I / II / III - a flat grant and two
	//              multipliers, drawn from the deck
	//   gear       DE's e_tps: a percentage, and then a flat add
	//   goals      DE's glv[main_taps]: 1% a level
	return max(_r, 0);
}
