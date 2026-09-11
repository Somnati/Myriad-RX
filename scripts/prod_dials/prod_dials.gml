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
	var _run = autom_rate("run");   // the dials' cycling: speed x the RAM throttle, 0 = every dial frozen
	// THE HAND-CRANK (his ask, 2026-09-11): with the cycling off, a dial
	// the pointer is HELD on runs at full rate for as long as it is held
	// (syst_dials publishes which one); let go and it freezes where it
	// is. Never during a replay - a hand is not there
	var _hold = (variable_global_exists("dial_hold") && !(variable_global_exists("offline_replaying") && g.offline_replaying))
		? g.dial_hold : -1;

	for (var _i = 0; _i < g.dial_total; _i++) {
		var _d = g.dial[_i];
		_d.paid = false;
		if (_d.level <= 0) continue;
		if (_d.cps <= 0) continue;

		// the cycle's visual decay rides real time, never the budget
		if (_d.glow > 0) _d.glow = max(0, _d.glow - .04 * delta);

		// THE DIALS' OWN CYCLING IS AN AUTOMATION NOW (his design,
		// 2026-09-11): autom_rate("run") is its speed x the RAM
		// throttle. ⚖️ OFF MEANS FROZEN, NOT MANUAL (his report: "turning
		// it off doesn't stop dial progress... i don't want dial progress
		// to reset, just freeze where it's at"). The first cut made every
		// dial manual with the cycling off - accruing at full rate and
		// banking a cycle, DE's autonomy-off rule - which is the opposite
		// of a machine that is switched off. Now: cycling off, the cycle
		// holds where it is; held by the pointer it runs at full rate
		// (the hand-crank); a dial with its own autonomy off (d.auto,
		// rm_automation's run column) keeps DE's manual rule
		var _cranked = (_i == _hold);
		var _rate = 0;
		if (_cranked)      _rate = 1;
		else if (_run > 0) _rate = _d.auto ? _run : 1;
		if (_rate <= 0) continue;
		var _auto = _d.auto || _cranked;
		_d.cycle += _d.cps * _secs * _rate;
		if (_d.cycle < 1) continue;

		// a manual dial banks ONE cycle and stops until tapped again
		// (DE's rule); an autonomous one takes every whole cycle
		var _n = floor(_d.cycle);
		if (!_auto) _n = 1;
		_d.cycle -= _n;
		if (!_auto) _d.cycle = 0;

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
