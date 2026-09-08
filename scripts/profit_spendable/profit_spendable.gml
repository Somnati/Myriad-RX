/// @description profit_spendable();
/// What of the profit pile can actually be SPENT: everything except the
/// reserve. THE ONE READER - every affordability test in the game goes
/// through this, so there is one definition of "can I afford it".
///
/// THE RESERVE IS NOT A SECOND CURRENCY, and that decision is the whole
/// design. g.profit_lock is a PORTION OF g.profit, not a pile beside
/// it. So:
///   - rebirth_calc, the header, the statistics, the offline report and
///     every future reader of "profit held" keep working untouched,
///     because the reserve is already inside the number they read. That
///     is the answer to "does it get added into main profit when
///     rebirth is calculated" - it never left, so there is nothing to
///     add back and nothing that can be forgotten.
///   - only the SPEND sites change, and they all change here.
/// A second variable would have needed folding in at rebirth, in the
/// counter, in the away report, in the rebirth bar's fill, and in
/// everything not yet written - and the first one anybody forgot would
/// be a silent loss of the player's savings.
///
/// A RELATIVE FLOOR COULD NOT HAVE DONE THIS. "never spend below 20% of
/// profit" sounds equivalent and is not: spending lowers the balance,
/// which lowers the floor, so the pile drains asymptotically to nothing.
/// A reserve has to be an accumulated AMOUNT, which is why it is a
/// number rather than a percentage.
function profit_spendable() {
	if (!variable_global_exists("profit_lock")) return g.profit;
	if (!(g.profit_lock >= arb(1)))  return g.profit;
	if (!(g.profit > g.profit_lock)) return 0;
	return do_subtract(g.profit, g.profit_lock);
}
