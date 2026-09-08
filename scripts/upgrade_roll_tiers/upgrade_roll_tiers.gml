/// @description upgrade_roll_tiers(rarity);
/// @param rarity
/// HOW MANY TIERS THIS OFFER CAN EVER TAKE - rolled once, when the
/// offer is rolled, and stored on it. This is Myriad DE's table
/// verbatim (roll_upgrade), and it is the whole reason the little dots
/// under a slot mean anything: two legendary offers of the same
/// upgrade are not the same item, because one can absorb five tiers
/// and the other four.
///
/// THIS IS ROLLED, NOT DERIVED, and that is not a violation of the
/// house law - it is part of the OFFER'S IDENTITY, exactly like the
/// rarity and the rolled value beside it. What must never be stored is
/// what an upgrade DOES; what it IS gets stored the moment it exists.
///
/// DE also lets wealth improve an offer: past a few credit thresholds
/// each roll gets an extra one-in-five shot at a bonus tier. Kept - it
/// is the only thing in DE that makes a credit balance worth something
/// while you are NOT spending it, and it gives the dots a visible
/// reason to creep up over a long run.
function upgrade_roll_tiers(_rar) {
	var _t;
	switch (clamp(floor(_rar), 0, UPG_RARITY_N - 1)) {
		case 0:  _t = choose(1, 2, 3);    break;   // common
		case 1:  _t = choose(1, 2, 3);    break;   // uncommon
		case 2:  _t = choose(1, 2, 3, 4); break;   // rare
		case 3:  _t = choose(2, 3, 4);    break;   // epic
		case 4:  _t = choose(2, 3, 4, 5); break;   // legendary
		case 5:  _t = choose(3, 4, 5, 6); break;   // elite
		case 6:  _t = choose(4, 5, 6, 7); break;   // divine
		default: _t = choose(5, 6, 7, 8); break;   // ultimate
	}

	// DE's wealth bonus, at DE's thresholds. These are DE's numbers
	// against DE's credit economy, which is a far larger one than RX
	// has today - expect to retune all four once the credit curve
	// settles.
	var _cr = (g.credits >= arb(1)) ? unarb(g.credits) : 0;
	if (_cr >  1000 && roll_perc(20)) _t += 1;
	if (_cr >  4000 && roll_perc(20)) _t += 1;
	if (_cr > 10000 && roll_perc(20)) _t += 1;
	if (_cr > 30000 && roll_perc(20)) _t += 1;

	return max(1, _t);
}
