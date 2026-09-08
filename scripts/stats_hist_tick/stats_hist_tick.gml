/// @description stats_hist_tick();
/// THE SAMPLING POLICY, in one place. Called bare every frame from
/// syst_production's heartbeat (persistent, so it runs in every room -
/// history keeps building while you sit in settings); it owns its own
/// one-second accumulator and decides what is worth a sample.
///
/// THREE SERIES, and only three (his call): PROFIT, REBIRTH UNITS and
/// PROFIT PER SECOND. Every series costs a permanent slice of memory, a
/// slice of the savefile and a row someone has to read, so the bar is:
/// would you watch this line move across a whole account's lifetime?
/// Those three are the account. What one tap pays was sampled here for
/// a while and dropped - it is a derived shadow of p/s and the fleet
/// level, so its line said nothing the other two were not already
/// saying.
///
/// ONE SECOND is the resolution at the fine end; past that
/// stats_hist_push halves the buffer and doubles the interval, so the
/// window grows to cover the whole account without the sample count
/// ever growing. A long stall (a blocking file dialog, a breakpoint, a
/// suspend) must not fire a burst of catch-up samples into that window
/// - the accumulator RESETS rather than carrying its debt forward,
/// which costs a few samples of history and keeps the axis honest about
/// being one-per-interval.
function stats_hist_tick() {
	if (!variable_global_exists("hist_acc")) g.hist_acc = 1;

	var _dt = delta_time / 1000000;
	g.hist_acc -= _dt;
	if (g.hist_acc > 0) return;
	// carry a small remainder so the rate does not drift, but never a
	// debt worth more than one tick (the stall case above)
	g.hist_acc = (g.hist_acc < -1) ? 1 : g.hist_acc + 1;

	// what you are holding - the line a rebirth shows up on as a cliff
	if (variable_global_exists("profit")) stats_hist_push("h_profit", g.profit);

	// the bank across every run: the one number that only ever climbs,
	// and the clearest picture of an account's whole history
	if (variable_global_exists("rebirth"))
		stats_hist_push("h_units", (g.rebirth.units >= arb(1)) ? g.rebirth.units : 0);

	// the fleet's output, which is what the profit line is the integral of
	if (variable_global_exists("all_gps")) stats_hist_push("h_ps", g.all_gps);
}
