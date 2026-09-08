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
	if (_pay > 0) {
		g.credits = (g.credits >= arb(1)) ? do_add(g.credits, arb(_pay)) : arb(_pay);
		g.total_credits = (g.total_credits >= arb(1))
			? do_add(g.total_credits, arb(_pay)) : arb(_pay);
	}
	update_dials();
	save_mark_dirty();
	play_sound_ext(snd_softclick, .85, .95, .5, 1);
	return _pay;
}
