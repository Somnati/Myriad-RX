/// @description stats_hist_tick();
/// THE SAMPLING POLICY, in one place. Called bare every frame from
/// syst_production's heartbeat (persistent, so it runs in every room -
/// history keeps building while you sit in settings); it owns its own
/// one-second accumulator and decides what is worth a sample.
///
/// WHAT GETS SAMPLED is deliberately short. Every series costs a
/// permanent slice of memory and a row someone has to read, so the bar
/// is: would you watch this line move? Three qualify - the fleet's
/// output, what a tap pays, and what you are holding. Adding a fourth
/// is one line here plus one stats_v2_spark row.
///
/// ONE SECOND is the resolution, and 120 samples the window, so a
/// graph is always exactly the last two minutes. A long stall (a
/// blocking file dialog, a breakpoint, a suspend) must not fire a
/// burst of catch-up samples into that window - the accumulator RESETS
/// rather than carrying its debt forward, which costs a few samples of
/// history and keeps the axis honest about being one-per-second.
function stats_hist_tick() {
	if (!variable_global_exists("hist_acc")) g.hist_acc = 1;

	var _dt = delta_time / 1000000;
	g.hist_acc -= _dt;
	if (g.hist_acc > 0) return;
	// carry a small remainder so the rate does not drift, but never a
	// debt worth more than one tick (the stall case above)
	g.hist_acc = (g.hist_acc < -1) ? 1 : g.hist_acc + 1;

	// the fleet's per-second output, and what one tap pays - the two
	// halves of the game, on the same axis, which is the comparison the
	// syphon exists to make
	if (variable_global_exists("all_gps"))   stats_hist_push("h_ps",  g.all_gps);
	if (variable_global_exists("click_gps")) stats_hist_push("h_tap", g.click_gps);
	// and the balance itself: this is the line that shows a rebirth
	if (variable_global_exists("profit"))    stats_hist_push("h_profit", g.profit);
}
