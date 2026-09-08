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

	// ⚖️ MEASURED AGAINST THE WATERMARK, NOT AGAINST THE PILE. Taking
	// the percentage of what you hold RIGHT NOW reads like the same
	// rule and behaves nothing like it: every purchase lowers the pile,
	// which lowers the reserve, which frees a little more. It is a
	// geometric series, and autobuy's one-second pulse walks it to
	// zero - datafiles/reserve_twin.py measures 60 pulses leaving 0.2%
	// of the reserve the player was promised. A reserve you can drain
	// by spending is not a reserve.
	//
	// The watermark only rises (give_profit), so spending cannot move
	// the floor. Everything the derived version was FOR still holds:
	// nothing is accumulated, the slider still releases the whole lot
	// the instant it drops, and there is no second pile to migrate at
	// rebirth - only a high point to reset with the run.
	var _res = do_scale(g.autom.lock_peak, _p / 100);
	// a watermark of zero is a real 0, not a packed arb, and do_subtract
	// is only safe between packed values - this is the state straight
	// after a rebirth, before the first earning has set a high point
	if (!(_res >= arb(1))) return g.profit;
	if (!(g.profit > _res)) return 0;   // the pile IS the reserve, or under it
	return do_subtract(g.profit, _res);
}
