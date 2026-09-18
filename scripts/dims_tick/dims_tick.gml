/// @description dims_tick(secs) - advance the cascade by EXACT closed
/// form, the whole reason this bench exists (his question: how
/// accurate is AD's offline?). the cascade is a LINEAR system - tier
/// i grows at count[i+1] x rate[i+1], nothing consumes anything - so
/// its solution is a finite Taylor sum: tier j's contribution to tier
/// i after t seconds is
///     count[j] x (prod of rates i+1..j) x t^(j-i) / (j-i)!
/// and dark matter (which integrates tier 0) gets one more order. that means
/// ONE call covers a frame or a week with zero drift: offline == online
/// isn't approximated here, it's an identity. (AD itself big-steps a
/// capped number of simulated ticks offline - close, but lossy around
/// thresholds; the closed form is what the mechanic deserves.) rates
/// hold constant across the window, which is true whenever nobody's
/// buying - i.e. exactly the offline case.
///
/// LOG10 REWORK (the float ceiling bug): every quantity is log10 now.
/// products/quotients become sums of logs (the running term is a plain
/// float add per order), and the Taylor SUM accumulates through
/// dims' ladd (log-sum-exp). a zero count sits at the lz sentinel
/// (~-1e9), which any added log term leaves astronomically small, so
/// empty tiers fall out of the sums by arithmetic - no branches.
function dims_tick(_t) {
	if (_t <= 0) return;
	var _d = g.dims;
	if (_d.inf) return; // crossed the wall: frozen until the big crunch
	var _n = _d.n;
	var _lt = log10(_t);

	// per-second rates in log10: the per-10 doubling x global
	// tickspeed (x1.15/buy - a coupled balance knob, see dims_cost)
	var _la = array_create(_n);
	for (var _i = 0; _i < _n; _i++)
		_la[_i] = (_d.bought[_i] div 10) * log10(2)
			+ _d.tick_bought * log10(1.15);

	// counts: every tier drinks its whole upstream in one pass
	var _new = array_create(_n);
	for (var _i = 0; _i < _n; _i++) {
		var _sum = _d.count[_i];
		var _term = 0; // log of the running (prod rates) x t^k / k!
		for (var _j = _i + 1; _j < _n; _j++) {
			_term += _la[_j] + _lt - log10(_j - _i);
			_sum = _d.ladd(_sum, _d.count[_j] + _term);
		}
		_new[_i] = _sum;
	}

	// dark matter: the integral of rate0 x count0 over the window
	var _ft = _la[0] + _lt;
	var _fg = _d.count[0] + _ft;
	for (var _j = 1; _j < _n; _j++) {
		_ft += _la[_j] + _lt - log10(_j + 1);
		_fg = _d.ladd(_fg, _d.count[_j] + _ft);
	}

	_d.count = _new;
	_d.dark = _d.ladd(_d.dark, _fg);

	// ---- the wall: 1.8e308 dark matter ends the run (AD's infinity). the
	// cascade freezes mid-flight; the room's banner takes over ----
	if (_d.dark >= _d.wall) {
		_d.dark = _d.wall;
		_d.inf = true;
		_d.run = date_current_datetime() * 86400 - _d.start;
		if (_d.best < 0 || _d.run < _d.best) _d.best = _d.run;
		save_mark_dirty();
	}
}
