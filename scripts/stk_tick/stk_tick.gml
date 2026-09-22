/// @description stk_tick(s, secs) - THE runner (q316): progress += allocation x the layer's speed x the focus x seconds, a sink at a time; levels clear at the ladder; the generators' spark accrues on the rate (linear in time - any budget is exact in one call, so the catch-up is this call with the time away)
function stk_tick(_s, _secs) {
	if (_secs <= 0) return;
	var _cfg = stk_config(), _ups = 0;
	// the spark first, on the rate as it stands (a generator's level-up this tick pays from the next - an ounce of humility)
	var _got = stk_spark_rate(_s) * _secs;
	_s.spark += _got; _s.life += _got; _s.rate_acc += _got;
	for (var _l = 0; _l < array_length(_cfg); _l++) {
		var _ly = _s.layers[_l], _spd = stk_speed(_s, _l);
		for (var _i = 0; _i < array_length(_ly.sinks); _i++) {
			var _k = _ly.sinks[_i];
			if (_k.alloc <= 0) continue;
			var _f = (_ly.focus < 0) ? 1 : ((_ly.focus == _i) ? STK_FOCUS_ON : STK_FOCUS_OFF);
			_k.prog += _k.alloc * _spd * _f * _secs;
			var _thr = stk_thr(_s, _l, _i, _k.level), _guard = 0;
			while (_k.prog >= _thr && _guard < 5000) { _guard++; _k.prog -= _thr; _k.level += 1; _k.ups += 1; _ups++; _thr = stk_thr(_s, _l, _i, _k.level); }
		}
	}
	_s.rate_t += _secs;
	if (_s.rate_t >= 5) { _s.rate = _s.rate_acc / _s.rate_t; _s.rate_acc = 0; _s.rate_t = 0; }
	if (_ups > 0) { stk_clamp(_s); save_mark_dirty(); }   // (a cap can only grow on a level-up; the clamp is for the turn's sake)
	_s.last = universal_now();
}
