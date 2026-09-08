/// @description upgrade_sell_value(slot);
/// @param slot
/// WHAT SELLING THIS SLOT PAYS, in credits. Every slot has one - an
/// untouched offer included, which is why the sell button no longer
/// says "discard".
///
/// DE'S SHAPE, RX'S ARITHMETIC. Myriad DE rolls a sell price with the
/// upgrade and stores it (roll_upgrade):
///
///     u_sell = ceil(base/5 + max_tiers * (base/10))
///
/// - a floor, plus a term per tier. RX keeps that skeleton and changes
/// what the per-tier term counts:
///
///     sell = SELL_BACK x ( the stake + every tier actually bought )
///
/// The floor is the roll's stake instead of a fifth of base, and the
/// per-tier term counts tiers you BOUGHT rather than tiers the offer
/// happens to allow, priced on the same accelerating curve they were
/// bought on.
///
/// WHY THAT IS AN IMPROVEMENT AND NOT JUST A CHANGE. DE's number is
/// fixed at roll time, so a slot you levelled eight times sells for
/// exactly what it sold for untouched: every credit you invested
/// evaporates, and "sell before you commit" is always right. Ours
/// scales with the commitment, so selling is a decision about whether
/// the slot is still the best use of itself rather than a punishment
/// for having used it.
///
/// AND IT CANNOT BE FARMED. Both terms are quoted off the UN-INFLATED
/// base (see upgrade_inflation), and SELL_BACK is well under 1, so the
/// payout is strictly less than what went in - for every rarity, every
/// depth, and every moment in a run. That matters more than it sounds:
/// the player sees the roll before deciding to sell, so an average that
/// merely leans negative is not enough. The MAXIMUM has to.
function upgrade_sell_value(_slot) {
	upgrade_init();
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return 0;
	if (upgrade_entry(_s.id) == -1) return 0;

	// the stake: what was put on the table to have this offer at all
	var _paid = UPG_ROLL_COST * upgrade_diff_mult();
	// plus every tier bought, on the curve it was bought on
	for (var _t = 0; _t < _s.tier; _t++) _paid += upgrade_price_base(_slot, _t);

	// NO FLOOR. An offer with nothing paid into it is worth nothing, and
	// with a free roll that is most offers - putting a 1-credit floor
	// under it would turn "roll, sell, repeat" into a credit printer
	// again, one credit at a time and forever. The row says so: the
	// button reads `discard` at zero rather than quoting a price of 0.
	return floor(_paid * UPG_SELL_BACK);
}
