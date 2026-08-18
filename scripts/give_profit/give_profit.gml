/// @description give_profit(amount) - THE one site profit is earned
/// (Myriad DE's give_gold). Dials pay through it, taps pay through it,
/// and every future source must too: it is the single place a lifetime
/// total can be trusted, and the single place the save gets marked.
function give_profit(_amt) {
	if (!(_amt >= arb(1))) return;
	g.profit       = do_add(g.profit, _amt);
	g.total_profit = do_add(g.total_profit, _amt);
	save_mark_dirty();
}
