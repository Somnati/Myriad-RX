/// @description star_swell(seed) -> { s : the size factor .84 .. 1.42, flare : 0 .. 1 } - THE SWELLING STAR now, on the universal clock (q267; his ask: "pulsates like it's going to explode, with a rubbery pull to its size")
/// An irregular period (two to five minutes, drifting; every cycle's reach
/// its own by a hash of the cycle) - NO METRONOME (his rule). The shape:
/// a slow rise that accelerates over the first five sixths (the star
/// filling, faster and faster, as if it will not stop), then the SNAP: a
/// damped spring over the last sixth - it overshoots below its rest,
/// rings twice, settles. The flare peaks at the snap and dies with it
function star_swell(_seed) {
	var _t = universal_now() + (_seed mod 100000) * 3.1;
	var _base = 120 + (_seed mod 97) * 1.9;   // (the star's own period, 120 .. 300 s)
	var _drift = sin(_t / (_base * 5.3) * 2 * pi + (_seed mod 360) * pi / 180);
	var _p = _base * (1 + .18 * _drift);
	var _cyc = floor(_t / _p), _ph = frac(_t / _p);
	var _reach = .28 + .14 * ((hash_mix(_seed, _cyc mod 100000) mod 1000) / 1000);   // (this cycle's swell: .28 .. .42)
	var _s = 1, _flare = 0;
	if (_ph < 5 / 6) {
		var _u = _ph / (5 / 6);
		_s = 1 + _reach * power(_u, 2.6);   // (the accelerating fill)
	} else {
		var _u = (_ph - 5 / 6) / (1 / 6);   // 0 .. 1 over the snap
		_s = 1 + _reach * exp(-5.5 * _u) * cos(2 * pi * 2.2 * _u);   // (the rubbery pull: over, under, over, settled)
		_flare = exp(-7 * _u);
	}
	return { s : _s, flare : _flare };
}
