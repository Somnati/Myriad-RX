/// @description ram_snap(kind, v) -> v on its nearest legal stop
/// THE ONE SNAPPER for every overclockable track: the normal stops (a
/// speed's 20/40/60/80/100, the tapper's 2..10 by 2, a timer's whole
/// seconds 1..30) and, past the end, the overclock notches. It snaps
/// to the ladder whether or not the toggle is on - ram_oc_clamp is
/// what drops values off the ladder when it goes off - so a loaded or
/// unpacked value is never bent to something the track cannot show.
/// @param kind   "speed" / "tap" / "timer"
/// @param v      the value
function ram_snap(_kind, _v) {
	switch (_kind) {
		case "speed":
			if (_v <= 100) return clamp(round(_v / 20) * 20, 20, 100);
			return ram_oc_value("speed", ram_oc_k("speed", _v));
		case "tap":
			if (_v <= 10) return clamp(round(_v / 2) * 2, 2, 10);
			return ram_oc_value("tap", ram_oc_k("tap", _v));
		case "timer":
			if (_v >= RAM_TIMER_MIN) return clamp(round(_v), RAM_TIMER_MIN, RAM_TIMER_MAX);
			return ram_oc_value("timer", ram_oc_k("timer", _v));
	}
	return _v;
}
