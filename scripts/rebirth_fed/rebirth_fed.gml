/// @description rebirth_fed() -> THE FED PROFIT: what a rebirth counts
/// (his design, 2026-09-13). A mirror of the pile that grows AS YOU
/// EARN - every gain lands in it times the cheat shop's "unit growth"
/// row at that moment (rebirth_feed) - and shrinks in proportion when
/// you spend (rebirth_spent), so with the row at 100 it IS the pile,
/// and with the row moved it is the pile as it would have been had the
/// row been there all along. That is the whole point: the row cannot
/// be cranked to the max the second before a rebirth, because the
/// growth was paid out earn by earn and the last second earns nothing.
/// THE NETWORTH ABILITY (DE's legendary: "rebirth factors in the profit
/// spent on generators") turns the shrink off - g.ad_networth, when the
/// deck has it. A packed arb; 0 while empty.
function rebirth_fed() {
	rebirth_init();
	return (g.rebirth.fed >= arb(1)) ? g.rebirth.fed : 0;
}
