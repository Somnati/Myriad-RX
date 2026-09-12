/// @description ram_oc_k(kind, v) -> the notch a value sits on, -1 if not overclocked
/// The inverse of ram_oc_value: a speed over 100, a tap rate over 10, a
/// timer under RAM_TIMER_MIN is overclocked, and the nearest notch by
/// its multiple is the one it is on. Everything that prices or draws
/// an overclocked value asks here.
/// @param kind   "speed" / "tap" / "timer"
/// @param v      the value
function ram_oc_k(_kind, _v) {
	var _m = 0;
	switch (_kind) {
		case "speed": if (_v <= 100) return -1; _m = _v / 100; break;
		case "tap":   if (_v <= 10)  return -1; _m = _v / 10;  break;
		case "timer": if (_v >= RAM_TIMER_MIN || _v <= 0) return -1; _m = RAM_TIMER_MIN / _v; break;
		default: return -1;
	}
	var _best = 0, _bd = 999;
	for (var _k = 0; _k < RAM_OC_N; _k++) {
		var _d = abs(ram_oc(_k).mult - _m);
		if (_d < _bd) { _bd = _d; _best = _k; }
	}
	return _best;
}
