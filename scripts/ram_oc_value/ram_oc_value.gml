/// @description ram_oc_value(kind, k) -> the value notch k puts on a track
/// "speed" ends at 100% -> 120 / 150 / 200; "tap" ends at 10 a second
/// -> 12 / 15 / 20; "timer" ends at RAM_TIMER_MIN seconds -> 1/1.2,
/// 1/1.5, 1/2 (the RATE is what the ladder multiplies, so a timer's
/// value divides). The ends are the same numbers ram_snap and the
/// panel's tracks use.
/// @param kind   "speed" / "tap" / "timer"
/// @param k      the notch, 0..RAM_OC_N-1
function ram_oc_value(_kind, _k) {
	var _m = ram_oc(_k).mult;
	switch (_kind) {
		case "speed": return round(100 * _m);
		case "tap":   return round(10 * _m);
		case "timer": return RAM_TIMER_MIN / _m;
	}
	return 0;
}
