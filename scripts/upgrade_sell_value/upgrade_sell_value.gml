/// @description upgrade_sell_value(slot);
/// @param slot
/// What selling this slot back pays. DE's shape: a fraction of base,
/// scaled UP by how far you levelled it - so selling a heavily invested
/// slot recovers meaningfully more than selling a fresh offer, and the
/// decision is "is this still the best use of the slot" rather than
/// "have I wasted everything".
/// Deliberately below what was paid in. A sell that broke even would
/// make every roll risk-free and the scarce slot would stop mattering.
function upgrade_sell_value(_slot) {
	upgrade_init();
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return 0;
	if (_s.tier <= 0) return 0;          // an unbought offer cost nothing
	var _e = upgrade_entry(_s.id);
	if (_e == -1) return 0;

	// sum what the tiers actually cost, then return a fraction of it -
	// derived from the same curve upgrade_cost uses, so a change there
	// can never leave the refund quoting a price that no longer exists
	var _paid = 0;
	for (var _t = 0; _t < _s.tier; _t++)
		_paid += _e.cost * upgrade_rarity_mult(_s.rar) * (1 + (0.2 + 0.1 * _t) * _t);
	_paid *= upgrade_diff_mult();
	return max(1, floor(_paid * UPG_SELL_BACK));
}
