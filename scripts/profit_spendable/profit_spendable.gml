/// @description profit_spendable();
/// What of the profit pile can actually be SPENT: everything except the
/// reserve. THE ONE READER - every affordability test in the game goes
/// through this, so there is one definition of "can I afford it".
///
/// ⚖️ THE RESERVE IS DERIVED, NOT ACCUMULATED (his call), and that is a
/// correction. The first version added a slice of every earning into a
/// stored g.profit_lock, which held money back exactly as intended and
/// then had NO WAY OUT: lowering the slider changed what future
/// earnings did and left everything already locked sitting there
/// forever. A control you can only turn one way is a trap.
///
/// So the reserve is simply a percentage OF WHAT YOU HOLD, worked out
/// fresh every read:
///     spendable = profit x (1 - pct/100)
/// Move the slider down and the money is spendable that instant. There
/// is no second variable, nothing to migrate at rebirth, nothing to
/// save, and nothing that can drift out of step with the pile it is a
/// fraction of.
///
/// WHAT THAT COSTS, stated plainly: a ratio floor can always be spent
/// against. Spending lowers the pile, which lowers the reserve, which
/// frees a little more - so the reserve is not a vault, it is a brake.
/// That is the honest trade for being able to open it, and it is the
/// right one here: the reserve exists so autobuy cannot eat the pile
/// rebirth is calculated from, and a brake does that job.
function profit_spendable() {
	if (!variable_global_exists("autom")) return g.profit;
	var _p = clamp(g.autom.lock_pct, 0, 90);
	if (_p <= 0) return g.profit;
	if (!(g.profit >= arb(1))) return 0;
	return do_scale(g.profit, (100 - _p) / 100);
}
