/// @description ram_snap(kind, v) -> v on its nearest legal stop
/// THE ONE SNAPPER for every overclockable track: the normal stops (a
/// speed's 20/40/60/80/100, the tapper's 2..10 by 2, a timer's four
/// price stops - RAM_TIMER_STOPS) and, past the end, the overclock notches. It snaps
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
		case "timer": {
			// THE LADDER (2026-09-14): one stop per price - RAM_TIMER_STOPS.
			// under the floor is a notch, everything else lands on the
			// nearest stop (a loaded 60 becomes 30: the same stick, more pulses)
			if (_v < RAM_TIMER_MIN && _v > 0) return ram_oc_value("timer", ram_oc_k("timer", _v));
			var _st = RAM_TIMER_STOPS, _bv = RAM_TIMER_MAX, _bd = 999999;
			for (var _i = 0; _i < array_length(_st); _i++) {
				var _d = abs(_st[_i] - _v);
				if (_d < _bd) { _bd = _d; _bv = _st[_i]; }
			}
			return _bv;
		}
	}
	return _v;
}
