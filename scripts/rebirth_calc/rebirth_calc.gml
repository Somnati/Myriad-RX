/// @description rebirth_calc() - THE EARN LAWYER: what a rebirth
/// right now would award (Myriad DE's update_rebirth, rebuilt as a
/// pure read - nothing here is stored, every caller derives fresh).
/// Returns { units, can, cool, run_s, lack, start, tc, gfrac }:
///   units  the award, a packed arb (0 = nothing)
///   can    units >= 1
///   cool   seconds until the press timer allows a rebirth (0 = now)
///   run_s  seconds into this run
///   lack   profit still missing to the gate (below it)
///   gfrac  0..1 log progress toward the gate (below it), for bars
///
/// DE'S LAWS, VERBATIM (classic and hard modes off, no abilities -
/// the multiplier stack DE hangs under this re-enters result-side as
/// those layers are rebuilt):
///   THE SOURCE is PROFIT HELD right now - not lifetime. Spend it on
///   levels and it is not there to count. That tension is the design.
///   THE HARD GATE: under 1,000,000 held, nothing.
///   THE ORIGIN: start = packed(profit) - floor(arb(1,000,000) + 1),
///   i.e. minus 7: zero at ten million.
///   BELOW THE ORIGIN (1m..10m) a flat ladder by the leading digit:
///   1 unit from 1m, 2 from 3m, 3 from 5m, 4 from 6m, 5 from 8m, 6
///   from 9.x m.
///   ABOVE IT: profit_to_unit = clamp(5 + start x 5/616, 0, 10) x .75
///   orders of magnitude per unit DECADE - 3.75 at the origin,
///   stretching to 7.5 by +616 orders. dig = depth / that. The award
///   is 6 + a number whose EXPONENT is floor(dig) and whose leading
///   digits are frac(dig): units multiply by TEN every 3.75 orders of
///   profit. (Techdemo II's port made this linear by accident - its
///   arb library could not pack the fraction. This is DE's curve.)
///   THE MILESTONE: +1 unit per 10 orders of magnitude past 1e16.
///   THE TIMECLAMP: under 300 s into the run units scale by
///   (run/300)^2, hard zero under 1% of it; the FIRST rebirth is
///   exempt. THE PRESS TIMER: the button will not fire before 600 s
///   into any run (cool counts it down).
function rebirth_calc() {
	rebirth_init();
	var _out = { units : 0, can : false, cool : 0, run_s : 0, lack : 0,
		start : 0, tc : 1, gfrac : 0 };

	var _run = max(0, (variable_global_exists("time_played_active") ? g.time_played_active : 0)
		- g.rebirth.run_pt0);
	_out.run_s = _run;
	if (_run < 600) _out.cool = 600 - _run;

	// the hard gate
	var _gate = arb(1000000);
	if (!(g.profit >= _gate)) {
		_out.lack  = (g.profit >= arb(1)) ? do_subtract(_gate, g.profit) : _gate;
		_out.gfrac = (g.profit >= arb(1)) ? clamp(arb_log10(g.profit) / 6, 0, 1) : 0;
		return _out;
	}

	// the origin (packed arithmetic: floor = exponent, frac x 10 = digits)
	var _start = g.profit - 7;
	_out.start = _start;
	var _deci  = max(0, ((frac(g.profit) * 10) - 1) / 9);

	var _units = 0;
	if (_start < 0) {
		var _n = 1;
		if (_start > -1 + .2) _n = 2;
		if (_start > -1 + .3) _n = 3;
		if (_start > -1 + .5) _n = 4;
		if (_start > -1 + .7) _n = 5;
		if (_start > -1 + .9) _n = 6;
		_units = arb(_n);
	} else {
		var _ptu = clamp(5 + ((5 / 616) * _start), 0, 10) * .75;
		var _dig = (floor(_start) + _deci) / _ptu;
		// DE: units_add = do_add(.6, floor(dig) + lerp(.1, .9999, frac(dig)))
		// - the second term IS a packed arb: exponent floor(dig),
		// mantissa 1..9.999. Built here in log space, packed once.
		var _lg = floor(_dig) + log10(lerp(1, 9.999, frac(_dig)));
		_units = do_add(arb(6), log_to_arb(_lg));
	}

	// the milestone: +1 per decade of orders past 1e16
	var _ms = ceil(max(0, (g.profit - 16) / 10));
	if (_ms > 0) _units = do_add(_units, arb(_ms));

	// the timeclamp
	var _tc = clamp(_run / 300, 0, 1);
	if (g.rebirth.total == 0) _tc = 1;
	_out.tc = _tc;
	if (_tc < 1)   _units = do_floor(do_scale(_units, _tc * _tc));
	if (_tc < .01) _units = 0;
	if (_start > 0 && _tc == 1 && !(_units >= arb(1))) _units = arb(1);

	// ---- UPGRADES, RESULT-SIDE and AFTER THE TIMECLAMP ----
	// Deliberately last. Before the clamp, an upgrade would partly buy
	// back the penalty for rebirthing too early, which is the one thing
	// the clamp exists to prevent; after it, an upgrade multiplies what
	// the run actually earned and the clamp still bites at full strength.
	var _ub = upgrade_bonus();
	if (_ub.rebirth_units > 0 && _units >= arb(1))
		_units = do_floor(do_scale(_units, 1 + _ub.rebirth_units / 100));

	_out.units = _units;
	_out.can   = (_units >= arb(1));
	return _out;
}
