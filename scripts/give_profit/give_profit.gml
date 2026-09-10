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
	// ⚖️ THE OFFLINE PILE (DE's offline_gold, his ask 2026-09-10): while
	// offline_replay is replaying an absence, what the dials pay goes
	// into g.offline_pool instead of the pile, and sits there until the
	// button in the money room is tapped. It still counts as earned -
	// total_profit takes it now - but nothing else about the pile
	// (the reserve's watermark, the counter's hold-back) moves until
	// the tap, because until the tap it has not been received.
	if (variable_global_exists("offline_pooling") && g.offline_pooling) {
		g.offline_pool = do_add(g.offline_pool, _amt);
		g.total_profit = do_add(g.total_profit, _amt);
		save_mark_dirty();
		return;
	}
	g.profit       = do_add(g.profit, _amt);

	// THE RESERVE'S WATERMARK. Nothing is taken here - the reserve is
	// still fully DERIVED, which is what lets the slider let go again -
	// but it is measured against the highest pile you have held rather
	// than the pile you hold this instant, and this is where that high
	// point is noticed. Earning is the only thing that may raise it;
	// spending must not lower it, or the floor walks down with every
	// purchase (see profit_spendable, and reserve_twin.py).
	if (variable_global_exists("autom"))
	if (g.profit > g.autom.lock_peak) g.autom.lock_peak = g.profit;
	g.profit_flight = do_add(g.profit_flight, _amt);
	g.total_profit = do_add(g.total_profit, _amt);
	save_mark_dirty();
}
