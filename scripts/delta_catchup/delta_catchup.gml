/// @description delta_catchup(d) -> the seconds replayed: the time away run through delta_tick in thirty-second steps (six hours at most, three thousand droplets at most - the rain thins to fit), so the delta grew while you were gone
function delta_catchup(_d) {
	var _away = clamp(universal_now() - (_d[$ "last"] ?? universal_now()), 0, DELTA_CATCHUP_MAX);
	if (_away < 5) { _d.last = universal_now(); return 0; }
	var _step = 30, _rate = (1.6 + .8 * (_d.rain - 1));
	var _want = _rate * _away, _thin = (_want > DELTA_DROPS_MAX) ? DELTA_DROPS_MAX / _want : 1;
	var _rain0 = _d.rain, _left = _away;
	while (_left > 0) {
		var _dt = min(_step, _left); _left -= _dt;
		// (the rain thinned to the budget: the level lent down for the call - the droplets' number is what costs)
		_d.rain = _rain0;
		if (_thin < 1) { _d.acc += _rate * _dt * (_thin - 1); }
		delta_tick(_d, _dt, false);
	}
	_d.rain = _rain0;
	_d.last = universal_now();
	return _away;
}
