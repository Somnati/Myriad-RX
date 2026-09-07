/// @description dial_breakdown(i);
/// @param i
/// WHY A DIAL EARNS WHAT IT EARNS, factor by factor - the data behind
/// the statistics screen's dial pages.
///
/// Myriad DE had a version of this and it was, by his own verdict,
/// lame: a flat list of numbers with no sense of which one was doing
/// the work. The fix is not more numbers, it is the RIGHT measure.
/// Per-second output is a product of independent factors, so in LOG10
/// space it is a SUM - and a sum can be shared out. Each factor's
/// contribution is log10(factor) / log10(total), which is the honest
/// answer to "what is actually carrying this dial", and it is what the
/// contribution bar draws. A x2 milestone next to a x1000 base curve
/// stops looking equally important, because it is not.
///
/// THE CHAIN, in update_dial's own order (that script is the authority;
/// this one mirrors it and then CHECKS ITSELF against the live value -
/// see `ok` below, so a future edit to one and not the other shows up
/// on screen instead of quietly lying):
///   base curve      dial_gps(tier, level)      - level + tier head start
///   cycle window    cycle x level-ramp          - seconds of base per cycle
///   speed milestone divides the cycle           - more cycles per second
///   profit milestone multiplies the per-cycle pay
///   rebirth boost   multiplies the per-cycle pay
/// The wind-up (autoeff) is reported too, as the one factor BELOW 1:
/// it stretches every cycle 30% longer than its roster time, which is a
/// real and permanent tax on output, and DE's autostarter abilities
/// exist to buy it back.
///
/// Returns:
///   steps    array of { name, note, mult, lg, share, col } - `mult` is
///            the plain multiplier, `lg` its log10, `share` its signed
///            fraction of the total, `col` a suggested colour
///   gps      the LIVE per-second value (from the dial, not re-derived)
///   derived  what this chain multiplies out to, as log10
///   ok       whether the two agree - false means update_dial moved and
///            this did not
/// ⚖️ NO SCIENTIFIC LITERALS ANYWHERE IN HERE. GML's parser rejects
/// 1e-9 and 1e9 alike, and the error it reports names the enclosing
/// statement rather than the number - this file shipped broken twice
/// on one `log10(max(_win, 1e-9))` guard that was not even needed.
function dial_breakdown(_i) {
	var _out = { steps : [], gps : 0, derived : 0, live_lg : 0, ok : true };
	if (!variable_global_exists("dial")) return _out;
	if (_i < 0 || _i >= array_length(g.dial)) return _out;

	var _d   = g.dial[_i];
	var _cfg = dial_config(_i);
	_out.gps = _d.gps;
	if (_d.level <= 0) return _out;

	var _ms = milestone_get(_i, _d.level);
	var _md = clamp(_d.level / 50, .1, 1);

	// ---- the factors, each as a plain multiplier on per-second output ----

	// 1. the base curve. This is the only step that is not a
	// multiplier on something else - it IS the something else - so its
	// "multiplier" is its own value and its log is the bulk of the sum.
	var _base_lg = (_d.b_gps >= arb(1)) ? arb_log10(_d.b_gps) : 0;
	var _hs   = dial_lvdiv(_i);
	var _note = "lv " + string(_d.level);
	if (_hs > 0) _note += " +" + string(_hs) + " tier";
	array_push(_out.steps, {
		name  : "base curve",
		note  : _note,
		mult  : -1,               // -1 = show the VALUE, not a xN
		val   : _d.b_gps,
		lg    : _base_lg,
		share : 0,
		col   : dial_color(_i),
	});

	// 2. the cycle window: one cycle banks `cycle x ramp` seconds of
	// base output. Note this cancels against cycles-per-second almost
	// exactly - a slow dial banks the same income in rarer lumps - so
	// what survives here is the LEVEL RAMP, reported separately below.
	var _win = max(1, _cfg.cycle * _md);
	array_push(_out.steps, {
		name  : "cycle window",
		note  : string_format(_cfg.cycle, 1, 0) + "s cycle",
		mult  : _win, val : 0, lg : log10(_win), share : 0,
		col   : c_steelblue,
	});

	// 3. cycles per second - the other half of that cancellation, and
	// where a SPEED milestone actually lands
	var _cyt = _cfg.cycle * (1 + _cfg.autoeff) / max(1, _ms.speed);
	var _cps = 1 / _cyt;
	array_push(_out.steps, {
		name  : "cycles / sec",
		note  : string_format(_cyt, 1, 1) + "s each",
		mult  : _cps, val : 0, lg : log10(max(_cps, 0.000000001)), share : 0,
		col   : c_steelblue,
	});

	// 4. the level ramp, called out on its own because under level 50
	// it is the single biggest thing holding a dial back and nothing on
	// screen says so anywhere else
	if (_md < 1)
		array_push(_out.steps, {
			name  : "level ramp",
			note  : "full at lv 50",
			mult  : _md, val : 0, lg : log10(_md), share : 0,
			col   : c_horange,
		});

	// 5. the wind-up: 30% of every cycle is spin-up, so the cycle runs
	// 1.3x its roster length and output is 1/1.3 of what it would be
	array_push(_out.steps, {
		name  : "wind-up",
		note  : string(round(_cfg.autoeff * 100)) + "% spin-up",
		mult  : 1 / (1 + _cfg.autoeff), val : 0,
		lg    : log10(1 / (1 + _cfg.autoeff)), share : 0,
		col   : c_hred,
	});

	// 6. the milestones, only when earned - a x1 row is furniture
	if (_ms.speed > 1)
		array_push(_out.steps, {
			name  : "speed milestones",
			note  : "cycle / " + string(_ms.speed),
			mult  : _ms.speed, val : 0, lg : log10(_ms.speed), share : 0,
			col   : c_sgreen,
		});
	if (_ms.profit > 1)
		array_push(_out.steps, {
			name  : "profit milestones",
			note  : "per cycle",
			mult  : _ms.profit, val : 0, lg : log10(_ms.profit), share : 0,
			col   : c_sgreen,
		});

	// 7. the rebirth bank. A packed arb, so its log comes from
	// arb_log10 rather than log10 - the one factor big enough to need it
	var _rb = rebirth_boost();
	if (_rb > arb(1)) {
		var _rlg = arb_log10(_rb);
		array_push(_out.steps, {
			name  : "rebirth boost",
			note  : "x" + crunch_arb(_rb),
			mult  : -2, val : _rb, lg : _rlg, share : 0,
			col   : c_hpurple,
		});
	}

	// ---- the shares ----
	// Signed: a factor below 1 (the ramp, the wind-up) has a negative
	// log and takes a share AWAY. The denominator is the sum of the
	// magnitudes, so the bar's segments always fill it exactly and a
	// penalty reads as its own weight rather than as a hole.
	var _mag = 0;
	for (var _s = 0; _s < array_length(_out.steps); _s++)
		_mag += abs(_out.steps[_s].lg);
	if (_mag > 0)
		for (var _s = 0; _s < array_length(_out.steps); _s++)
			_out.steps[_s].share = _out.steps[_s].lg / _mag;

	// ---- the self-check ----
	// The chain multiplied out should be the live per-second value. If
	// it is not, update_dial has moved and this mirror has not; the
	// page says so rather than presenting a confident wrong answer.
	var _sum = 0;
	for (var _s = 0; _s < array_length(_out.steps); _s++) _sum += _out.steps[_s].lg;
	_out.derived = _sum;
	_out.live_lg = (_d.gps >= arb(1)) ? arb_log10(_d.gps) : 0;
	// a tenth of an order of magnitude of slack: gpc is do_ceil'd, which
	// rounds a real amount at small values and nothing at large ones
	_out.ok = (abs(_out.derived - _out.live_lg) < .12) || (_out.live_lg <= 0);

	return _out;
}
