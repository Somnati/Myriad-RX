/// @description give_profit(amount) - THE one site profit is earned
/// (Myriad DE's give_gold). Dials pay through it, taps pay through it,
/// and every future source must too: it is the single place a lifetime
/// total can be trusted, and the single place the save gets marked.
/// HELD BACK ON ARRIVAL: the profit is banked here and now (that must
/// never depend on a particle surviving), but it is ALSO registered as
/// "in flight" so the counter can withhold it until the bezier motes
/// carrying it actually land. Registering at the EARN site rather than
/// counting live motes is what makes it order-proof: the hold starts
/// the instant the profit exists, whether the view spawns motes this
/// frame, next frame, or never (see obj_ui_header's heal).
function give_profit(_amt) {
	if (!(_amt >= arb(1))) return;
	g.profit       = do_add(g.profit, _amt);
	g.profit_flight = do_add(g.profit_flight, _amt);
	g.total_profit = do_add(g.total_profit, _amt);
	save_mark_dirty();
}
