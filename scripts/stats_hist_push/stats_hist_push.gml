/// @description stats_hist_push(key, value, [cap]);
/// @param key
/// @param value
/// @param [cap]
/// THE FEEDER for the statistics screen's spark rows. stats_v2_spark
/// draws whatever it finds at g.stats_hist[$ key]; this is the only
/// thing that puts anything there.
///
/// It went missing: the spark widget shipped complete - area fill,
/// gridlines, hi/lo labels, hover scrub - and its own header named a
/// stats_hist_push() that had never been written, so no row could ever
/// call it and the screen carried a finished graph nothing could draw
/// (found 2026-09-07).
///
/// SAMPLES ARE STORED RAW, and for arb-packed values that is not
/// laziness: the packing is logarithmic by construction, which is
/// exactly the axis an idle curve wants. A graph of raw packed profit
/// is a log plot for free, and min/max/lerp over packed values stay
/// meaningful because the packing is monotonic. Plain reals (a tap
/// count, a rate) graph linearly, which is also what they want.
///
/// The buffer is a rolling window `cap` samples long - a plain array,
/// oldest at index 0, so the draw walks it left to right without
/// arithmetic. Session-only by design: history is a picture of the run
/// you are in, and writing two minutes of samples into every savefile
/// would cost more than it tells anyone.
function stats_hist_push(_key, _val, _cap = 120) {
	if (!variable_global_exists("stats_hist")) g.stats_hist = {};
	var _a = g.stats_hist[$ _key];
	if (!is_array(_a)) {
		_a = [];
		g.stats_hist[$ _key] = _a;
	}
	array_push(_a, _val);
	// arrays are reference types, so this trims the stored buffer
	while (array_length(_a) > _cap) array_delete(_a, 0, 1);
}
