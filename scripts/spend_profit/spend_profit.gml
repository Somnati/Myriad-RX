/// @description spend_profit(cost);
/// @param cost   a packed arb
/// Pay for something in profit. Returns true if it landed.
/// THE ONE PLACE profit leaves the balance, so it is the one place a
/// sink can be audited, and the one place the save gets marked for a
/// purchase. Refuses rather than going negative - the arb library does
/// not do negative numbers, and a subtract past zero is not an
/// overdraft there, it is a hang.
function spend_profit(_cost) {
	if (!(_cost >= arb(1))) return true;   // free is always affordable
	if (!(g.profit >= _cost)) return false;
	g.profit = do_subtract(g.profit, _cost);
	save_mark_dirty();
	return true;
}
