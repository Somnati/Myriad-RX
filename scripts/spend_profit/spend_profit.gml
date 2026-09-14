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
	if (!(profit_spendable() >= _cost)) return false;
	var _before = g.profit;
	g.profit = do_subtract(g.profit, _cost);
	rebirth_spent(_before, g.profit);   // the fed profit follows in proportion (2026-09-13)
	// ⚖️ THE HOLD-BACK GIVES WAY FIRST (his report, 2026-09-13: an autobuy
	// "shoots my profit all the way down to 0 no matter how much i have
	// till the profit bits are consumed"). The header withholds what is
	// still riding motes (g.profit_flight) - money already banked, still
	// on its way to the counter. A spend that leaves less in the pile than
	// was in the air made pile - flight negative, which the arb reads as
	// 0, and the counter sat at nothing until every mote landed. The
	// spend is taken from the airborne money first: the counter then
	// never shows less than what is left, and climbs to it as the motes
	// arrive, instead of dropping through the floor and climbing back
	if (variable_global_exists("profit_flight") && g.profit_flight >= arb(1))
		g.profit_flight = (g.profit_flight > _cost) ? do_subtract(g.profit_flight, _cost) : 0;
	save_mark_dirty();
	return true;
}
