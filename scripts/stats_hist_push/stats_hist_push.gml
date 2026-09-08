/// @description stats_hist_push(key, value, [cap]);
/// @param key
/// @param value
/// @param [cap]
/// THE FEEDER for the statistics screen's spark rows. stats_v2_spark
/// draws whatever it finds at g.stats_hist[$ key]; this is the only
/// thing that puts anything there.
///
/// ⚖️ IT IS A DECIMATING BUFFER, and that is what makes the graphs
/// LIFETIME rather than "the last two minutes" (his call). A hundred
/// hours of play at one sample a second is 360,000 samples, which is
/// not a thing to keep or to save. So the buffer is a FIXED 120 slots:
/// when it fills, every other sample is dropped and the interval
/// doubles. The window it covers therefore doubles too, forever, in
/// constant memory -
///     1s apart -> 2 minutes        256s apart -> 8.5 hours
///     16s      -> 32 minutes       4096s      -> 5.7 days
///     64s      -> 2.1 hours        65536s     -> 91 days
/// - and the curve keeps its shape while it coarsens, because dropping
/// alternate samples is a resample, not a truncation. You lose the fine
/// grain of an hour ago, which is exactly the thing nobody is looking
/// at when they open a lifetime graph.
///
/// SAMPLES ARE STORED RAW, and for arb-packed values that is not
/// laziness: the packing is logarithmic by construction, which is
/// exactly the axis an idle curve wants. A graph of raw packed profit
/// is a log plot for free, and min/max/lerp over packed values stay
/// meaningful because the packing is monotonic.
function stats_hist_push(_key, _val, _cap = 120) {
	if (!variable_global_exists("stats_hist")) g.stats_hist = {};
	if (!variable_global_exists("hist_meta"))  g.hist_meta  = {};

	// per-series interval and the seconds counted toward the next sample
	var _m = g.hist_meta[$ _key];
	if (!is_struct(_m)) {
		_m = { step : 1, acc : 0 };
		g.hist_meta[$ _key] = _m;
	}

	// one call is one second - stats_hist_tick guarantees that - so the
	// interval is counted in calls rather than in wall time, which keeps
	// a stalled frame from inventing samples that were never taken
	_m.acc += 1;
	if (_m.acc < _m.step) return;
	_m.acc = 0;

	var _a = g.stats_hist[$ _key];
	if (!is_array(_a)) {
		_a = [];
		g.stats_hist[$ _key] = _a;
	}
	array_push(_a, _val);       // arrays are references, so this lands

	// ---- the halving ----
	// A `while` rather than an `if`: a buffer loaded from a save can
	// arrive over cap (an older build with a bigger one, a hand-edited
	// ini), and it should settle in one pass rather than shed one
	// sample a second for two minutes.
	while (array_length(_a) > _cap) {
		var _b = [];
		for (var _i = 0; _i < array_length(_a); _i += 2) array_push(_b, _a[_i]);
		g.stats_hist[$ _key] = _b;
		_a = _b;                // the local has to follow the swap
		_m.step *= 2;
	}
}
