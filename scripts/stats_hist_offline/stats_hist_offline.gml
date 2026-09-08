/// @description stats_hist_offline(seconds, before, gain, rate);
/// @param seconds  how long the absence was
/// @param before   profit when it started (packed arb, or 0)
/// @param gain     what the replay paid over it (packed arb, or 0)
/// @param rate     profit per second across it (packed arb, or 0)
/// FILL THE GAP AN ABSENCE LEAVES IN THE HISTORY GRAPHS.
///
/// The graphs sample from syst_production's heartbeat, which does not
/// run while the game is closed - so every absence used to land on the
/// profit line as a vertical cliff between two adjacent samples, and
/// the axis label (samples x step) claimed a duration that ignored
/// every hour the account had ever spent shut. The graphs were lifetime
/// in PLAYED time and were labelled as though they were lifetime in
/// ELAPSED time.
///
/// THIS IS NOT INVENTED DATA, which is the only reason it is allowed.
/// Nothing is bought while you are away, so across the absence:
///   - p/s is CONSTANT. It is the rate the replay itself used.
///   - rebirth units are CONSTANT. Nothing rebirths offline.
///   - profit accumulates LINEARLY at that rate, and the endpoints are
///     both known exactly - offline_replay measured them.
/// So the samples here are the analytic solution over the interval, the
/// same solution prod_dials used to pay the absence in one bulk call.
/// The alternative - leaving the hole - is not "no claim", it is the
/// false claim that no time passed.
///
/// THE STEP GROWS AS IT GOES, which is what makes a month affordable.
/// Each forced push advances the cursor by that series' CURRENT
/// interval, and stats_hist_push doubles that interval every time the
/// buffer fills. The cursor therefore accelerates geometrically.
/// Measured, from a full buffer at a 1s step:
///     1 hour     298 pushes    ends at a 32s step
///     1 day      566           1024s
///     30 days    861           32768s   (window 45 days)
///     10 years  1277           4194304s
/// - so a month costs 861 pushes rather than 2.6 million, and lands
/// with the window genuinely covering the month. HIST_FILL_MAX is a
/// backstop against a corrupt step, never the expected exit.
function stats_hist_offline(_secs, _before, _gain, _rate) {
	if (_secs < 1) return;
	if (!variable_global_exists("stats_hist")) return;

	var _units = (variable_global_exists("rebirth")
		&& g.rebirth.units >= arb(1)) ? g.rebirth.units : 0;

	var _keys = ["h_profit", "h_units", "h_ps"];
	for (var _k = 0; _k < array_length(_keys); _k++) {
		var _key = _keys[_k];
		// only fill a series that already exists: a graph that has never
		// been fed should start when the account starts being watched,
		// not with a synthesised prologue
		if (!is_array(g.stats_hist[$ _key])) continue;

		var _t = 0;
		var _guard = 0;
		while (_t < _secs && _guard < HIST_FILL_MAX) {
			var _m = g.hist_meta[$ _key];
			var _step = is_struct(_m) ? max(1, _m.step) : 1;
			_t += _step;                       // the sample sits at the
			var _f = clamp(_t / _secs, 0, 1);  // END of its interval

			var _v = 0;
			switch (_k) {
				case 0:
					// profit: linear from before to before + gain
					_v = _before;
					if (_gain > 0) {
						var _add = do_scale(_gain, _f);
						_v = (_before >= arb(1)) ? do_add(_before, _add) : _add;
					}
					break;
				case 1: _v = _units; break;    // flat: nothing rebirths away
				case 2: _v = _rate;  break;    // flat: nothing is bought away
			}

			stats_hist_push(_key, _v, 120, true);
			_guard += 1;
		}
	}
}
