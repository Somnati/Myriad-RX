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

	// ---- THE RESERVE (settings live in the automation room) ----
	// A slice of every earning is locked away from spending. It is
	// still profit - still in g.profit, still counted by rebirth - it
	// just cannot be spent, which is the point: autobuy would otherwise
	// eat the pile that rebirth is calculated from, and the two
	// mechanics would quietly fight each other forever.
	//
	// THE SUB-1 GUARD is not defensive noise. do_scale clamps a result
	// below 1 up to arb(1), so a 1-profit tap at 10% would lock the
	// whole thing. Below the threshold where the slice is worth a whole
	// unit, nothing is locked at all.
	if (variable_global_exists("autom"))
	if (g.autom.lock_pct > 0)
	if (_amt >= arb(ceil(100 / g.autom.lock_pct))) {
		var _lk = do_scale(_amt, g.autom.lock_pct / 100);
		g.profit_lock = (g.profit_lock >= arb(1))
			? do_add(g.profit_lock, _lk) : _lk;
	}
	g.profit_flight = do_add(g.profit_flight, _amt);
	g.total_profit = do_add(g.total_profit, _amt);
	save_mark_dirty();
}
