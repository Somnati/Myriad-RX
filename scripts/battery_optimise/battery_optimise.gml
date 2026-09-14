/// @description battery_optimise(away_s) - THE OPTIMISER (his idea,
/// 2026-09-11: "an unlockable ability that optimises your offline
/// throttle to make the most of what you got"). The replay runs after
/// the absence is known, so it can pick the offline rates that would
/// have made the most of the charge over EXACTLY that absence - and
/// run at those instead of the ones you left.
///
/// THE LAW. Output over an absence is min(away, charge / draw) x rate,
/// and draw is the square of the rate (battery_draw) - so the most
/// output comes when the charge lasts EXACTLY the absence: scale every
/// machine's rate by one factor s (your proportions between machines
/// are kept - they are your preference) until draw x away == charge,
/// or every machine hits 100%. Both directions: a short absence with
/// the rates dialed down scales UP; a long one with the rates left
/// high scales DOWN, which is MORE output (24h at 100% is 3h of
/// machine time; optimised it is 8.5h). The ceiling that gives is
/// sqrt(capacity x absence) - still sublinear, so the battery's job
/// (no runaway compounding) survives; only the "you set it wrong"
/// punishment goes.
///
/// Returns { run, fab, merge, s } - the rates to replay at and the
/// factor applied - or undefined when nothing draws / nothing changes.
/// Machines switched off stay off (their rate is moot). Solved by
/// bisection on s, because the 100% clamp makes the closed form miss.
/// @param away_s
function battery_optimise(_away) {
	battery_init();
	autom_init();
	var _b = g.battery, _a = g.autom;
	var _on = [ _a.run.on, _a.fab.on,
	            variable_global_exists("tiles") && g.tiles.automerge ];
	var _w  = [ BAT_W_RUN, BAT_W_FAB, BAT_W_MERGE ];
	var _r0 = [ _b.rate.run, _b.rate.fab, _b.rate.merge ];
	var _tot = BAT_W_RUN + BAT_W_FAB + BAT_W_MERGE;
	if (_away < 1 || _b.charge <= 0) return undefined;
	if (!(_on[0] || _on[1] || _on[2])) return undefined;

	// draw at a scale s, every machine clamped at 100
	var _drawat = function(_s, _on, _w, _r0, _tot) {
		var _d = 0;
		for (var _k = 0; _k < 3; _k++) {
			if (!_on[_k]) continue;
			var _r = min(100, _r0[_k] * _s);
			_d += _w[_k] * sqr(_r / 100);
		}
		return _d / _tot;
	};
	// the draw at which the charge lasts exactly the absence - in RAW
	// draw (the model above), so the over-budget factor battery_draw
	// applies comes OFF the target (x ram_throttle: over budget, less
	// raw draw is affordable)
	var _target = _b.charge / _away * ram_throttle();

	// the scale that never clamps everything: the largest s puts every
	// machine at 100 - above that nothing changes
	var _smax = 1;
	for (var _k = 0; _k < 3; _k++) if (_on[_k]) _smax = max(_smax, 100 / max(5, _r0[_k]));
	var _s;
	if (_drawat(_smax, _on, _w, _r0, _tot) <= _target) _s = _smax;   // even flat out it lasts: run flat out
	else {
		// bisect s in (0, smax] for draw(s) == target
		var _lo = 0, _hi = _smax;
		repeat (40) {
			var _mid = (_lo + _hi) * .5;
			if (_drawat(_mid, _on, _w, _r0, _tot) > _target) _hi = _mid; else _lo = _mid;
		}
		_s = _lo;
	}
	var _out = {
		run   : _on[0] ? clamp(_r0[0] * _s, 5, 100) : _r0[0],
		fab   : _on[1] ? clamp(_r0[1] * _s, 5, 100) : _r0[1],
		merge : _on[2] ? clamp(_r0[2] * _s, 5, 100) : _r0[2],
		s     : _s,
	};
	if (abs(_s - 1) < .02) return undefined;   // within 2%: nothing worth doing
	return _out;
}
