/// @description upgrade_sell(slot);
/// @param slot
/// Sell the slot back for part of what went into it and leave it empty.
/// Returns the credits paid (0 = nothing happened).
///
/// Selling is a plain DELETION here, and that is the whole payoff of
/// deriving the bonuses: there is no accumulator to unwind, so a sale
/// cannot leave a residue behind the way it could if the effect had
/// been added into a global at purchase time.
function upgrade_sell(_slot) {
	upgrade_init();
	if (_slot < 0 || _slot >= upgrade_slots()) return 0;
	if (!is_struct(g.upg.slot[_slot])) return 0;

	var _pay = upgrade_sell_value(_slot);
	g.upg.slot[_slot] = -1;

	// THE PAYOUT GOES THROUGH THE DROPPER, at the pointer. DE's sale is
	// `drop_credits(mouse_x, mouse_y, acost, 20, -1)` - the credits are
	// not just added, they FLY from where you were looking to the credit
	// panel, which is the same ceremony a tap drop gets. Routing it
	// through credit_drop rather than adding to g.credits by hand also
	// means the sale is counted, banked and saved by the one script that
	// already knows how to do all three.
	// The mote cap is DE's 20 rather than a tap's 8: a sale is a bigger
	// event and should look like one.
	if (_pay > 0) credit_drop(mouse_x, mouse_y, _pay, 20);
	// ...and the offer meter takes a share of the refund (DE's sale:
	// get_sub_sec_inf(acost, 1/2, .02))
	upgrade_meter_feed(_pay * .5 * (1 + .02 * (_pay - 1)));

	update_dials();
	save_mark_dirty();
	play_sound_ext(snd_softclick, .85, .95, .5, 1);
	return _pay;
}
