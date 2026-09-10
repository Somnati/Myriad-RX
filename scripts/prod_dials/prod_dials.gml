/// @description prod_dials([seconds]) - the production tick: advance
/// every running dial's cycle and pay out the ones that complete
/// (Myriad DE's prod_dials).
/// IMPROVED vs DE: DE advances cycles in FRAMES (cps/60 * delta) and
/// pays at most the whole cycles that landed this frame. RX takes a
/// SECONDS BUDGET instead - called bare it uses this frame's delta,
/// but hand it 3600 and it pays an hour correctly in one call. That is
/// what lets one code path serve live play AND the offline catch-up
/// when that gets rebuilt: never fork an offline-only formula.
/// A dial pays gpc per completed cycle, and whole cycles are paid in
/// BULK (one do_scale, not a loop), so a long budget stays O(1).
function prod_dials(_secs = -1) {
	if (!variable_global_exists("dial")) return;
	if (_secs < 0) _secs = delta / 60;
	if (_secs <= 0) return;

	for (var _i = 0; _i < g.dial_total; _i++) {
		var _d = g.dial[_i];
		_d.paid = false;
		if (_d.level <= 0) continue;
		if (_d.cps <= 0) continue;

		// the cycle's visual decay rides real time, never the budget
		if (_d.glow > 0) _d.glow = max(0, _d.glow - .04 * delta);

		_d.cycle += _d.cps * _secs;
		if (_d.cycle < 1) continue;

		// a manual dial banks ONE cycle and stops until tapped again
		// (DE's rule); an autonomous one takes every whole cycle
		var _n = floor(_d.cycle);
		if (!_d.auto) _n = 1;
		_d.cycle -= _n;
		if (!_d.auto) _d.cycle = 0;

		var _pay = (_n > 1) ? do_scale(_d.gpc, _n) : _d.gpc;
		// ⚖️ THE TILE TABLE MULTIPLIES THIS (DE's update_auto, its last
		// line before the payout). RESULT-SIDE, the adapter contract:
		// the boost multiplies what was already derived and never
		// touches _d.gpc, so it cannot compound into the dial's own
		// curve or into the cost of levelling it. See tile_dial_boost.
		var _tb = tile_dial_boost();
		if (_tb > arb(1)) _pay = do_multi(_pay, _tb);
		give_profit(_pay);
		_d.paid = true;
		_d.paid_amt = _pay;   // the view's motes carry this home
		_d.glow = max(.35, _d.glow);
	}
}
