/// @description upgrade_roll_cost();
/// What it costs in credits to roll an offer into an empty slot.
///
/// WHY ROLLING COSTS ANYTHING AT ALL. It used to be free, and free
/// rolling breaks two things at once. It makes rarity meaningless -
/// there is no reason to keep a common when the button is right there -
/// so the whole ladder collapses into "reroll until ultimate". And the
/// moment an unwanted offer can be SOLD rather than discarded, free
/// rolling is a credit printer: roll, sell, repeat, forever.
///
/// A stake fixes both at once. The roll is the gamble, this is what you
/// put on the table, and the sell price is the recovery - which is
/// exactly why upgrade_sell_value can never pay out more than went in.
///
/// It rides upgrade_inflation like every other price, so rolling does
/// not quietly become free again as a run matures.
function upgrade_roll_cost() {
	if (UPG_ROLL_COST <= 0) return 0;   // free, and the callers all know it
	return max(1, round(UPG_ROLL_COST * upgrade_diff_mult() * upgrade_inflation()));
}
