/// @description puck_pay(frac, mult, x, y) - pay for one puck bounce.
/// @param frac  0..1, how fast the puck was at impact
/// @param mult  1 for a bounce, PUCK_CATCH for a mid-air catch
/// @param x
/// @param y
///
/// ⚖️ THE PUCK IS DENOMINATED IN YOUR OWN TAPPING. This is the single
/// most important decision in the whole toy and it is Myriad DE's: a
/// bounce is worth a MULTIPLE OF YOUR TAP RATE, never a number of its
/// own. The consequences are worth spelling out, because they are why
/// there is no puck balance curve anywhere in this project:
///
///   - it can never be tuned wrong relative to the rest of the game,
///     because it has no independent scale to be wrong on
///   - it stays exactly as relevant at 1e40 as at 1e2
///   - every upgrade that touches tapping touches the puck for free,
///     and none of them can double-dip, because the rate is read once
///   - a slow bounce is worth less than a fast one, but never worth
///     nothing, so a dying throw still pays out its last few hits
///
/// DE read g.max_cycle_tps - the run's PEAK tps, a watermark that has
/// to be stored, saved and reset at rebirth. tap_rate() is the same
/// quantity with no state: it already carries every upgrade, it cannot
/// drift out of step with the tapper, and there is nothing to reset. It
/// is also honest in a way the watermark was not - the watermark could
/// be inflated once by a burst of mashing and then paid out forever.
///
/// BOUNCES ARE NOT TAPS. tap_fire's `_stat` argument is false here, so
/// a bounce pays profit and rolls crits exactly like a tap but never
/// touches the lifetime tap counter. DE did this by sniffing the
/// caller's identity (`is_cube`); declaring it at the call site is the
/// same law said out loud.
function puck_pay(_frac, _mult, _x, _y) {
	var _rate = max(1, tap_rate());
	var _lo = _rate * PUCK_PAY_MIN;
	var _hi = _rate * PUCK_PAY_MAX;
	var _n  = max(1, round(lerp(_lo, _hi, clamp(_frac, 0, 1)) * _mult));

	// the money room is the only room with a ceremony (tap_fire's rule,
	// and the puck only exists there anyway) - so the bits it fires
	// carry the bounce's profit to the header counter like every other
	// payout in the game. DE burst generic sparks that meant nothing;
	// these are the profit, visibly arriving.
	// ⚖️ _fx TRUE MEANS THIS BOUNCE ALSO PLAYS THE TAP SOUND, under the
	// puck's own impact voice. That is deliberate and it is DE's - two
	// layers read as one richer hit, and the alternative costs more than
	// it saves: _fx false would also kill the bits and the float, which
	// are the entire reason to route a bounce through tap_fire instead
	// of give_profit. If it ever sounds crowded, the tapper's sound has
	// a "none" option and that is the honest lever.
	var _paid = tap_fire(_n, _x, _y, true, true, false);
	// the throw's ledger (DE's cur_profit): what this throw has earned,
	// for the bounce tracker's "profit" line
	if (instance_exists(obj_puck))
		obj_puck.cur_profit = (obj_puck.cur_profit >= arb(1))
			? do_add(obj_puck.cur_profit, _paid) : _paid;
}
