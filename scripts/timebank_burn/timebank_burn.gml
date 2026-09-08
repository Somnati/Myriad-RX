/// @description timebank_burn(seconds);
/// @param seconds
/// Spend a lump of banked time AT ONCE, running it through the
/// production sim exactly as an absence would (his ask: press [10m] and
/// ten minutes happen). Returns the profit it paid, or 0.
///
/// IT DOES NOT GO THROUGH offline_replay, and that is the whole reason
/// this script exists rather than being one line. offline_replay BANKS
/// time as it replays (timebank_add - the hybrid), so burning the bank
/// through it would hand some of the bank straight back. A spend that
/// partially refunds itself is not a spend. This drives the sim lanes
/// directly instead: the same prod_dials and credit_tick that both the
/// replay and the live heartbeat drive, so a burn is by construction
/// identical to having been away that long.
///
/// NO MOTES, NO HISTORY SAMPLES. The paid flags are cleared so a burst
/// of thirteen dial payouts does not fire at once, and the in-flight
/// hold is released because nothing is carrying that profit. The
/// history graphs are deliberately NOT fed: their x axis is WALL time,
/// and a burn takes no wall time at all. The jump the next ordinary
/// sample records is the honest picture - profit really did rise
/// instantly. That is the exact opposite of the offline case, where
/// real time passed and the graph had to be told about it.
function timebank_burn(_secs) {
	timebank_init();
	_secs = floor(_secs);
	if (_secs < 1) return 0;
	if (g.timebank.bank < _secs) return 0;
	if (!variable_global_exists("dial")) return 0;

	g.timebank.bank -= _secs;

	var _before = g.profit;
	prod_dials(_secs);
	credit_tick(_secs);

	for (var _i = 0; _i < g.dial_total; _i++) g.dial[_i].paid = false;

	var _gain = (g.profit > _before) ? do_subtract(g.profit, _before) : 0;
	if (_gain > 0)
		g.profit_flight = (g.profit_flight > _gain)
			? do_subtract(g.profit_flight, _gain) : 0;

	save_mark_dirty();
	return _gain;
}
