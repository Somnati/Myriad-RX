/// @description stk_tick(s, secs, [at]) - THE runner (q316): progress += allocation x the layer's speed x the focus x seconds, a sink at a time; levels clear at the ladder; the generators' spark accrues on the rate; the tide is read at the step's middle (at = the wall second the step starts; the catch-up passes its own); burns count down; the siphon feeds aether. Linear in time - any budget is exact in one call, so the catch-up is this call with the time away
function stk_tick(_s, _secs, _at = -1) {
	if (_secs <= 0) return;
	if (_at < 0) _at = universal_now();
	_s.tide = stk_tide(_at + _secs * .5).layer;
	var _cfg = stk_config(), _ups = 0, _clamp = false, _fon = stk_focus_on(_s);
	// the spark first, on the rate as it stands (a generator's level-up this tick pays from the next - an ounce of humility)
	var _got = stk_spark_rate(_s) * _secs;
	_s.spark += _got; _s.life += _got; _s.rate_acc += _got;
	// THE SIPHON (energy's seventh): its energy x energy's speed x STK_SIPHON x its bonus, split over aether's working sinks
	var _feed = 0;
	if (stk_sink_n(_s, 0) >= 7) {
		var _sp = _s.layers[0].sinks[6];
		if (_sp.alloc > 0) {
			var _nw = 0, _ask = _s.layers[1].sinks, _na = stk_sink_n(_s, 1);
			for (var _i = 0; _i < _na; _i++) if (_ask[_i].alloc > 0) _nw++;
			if (_nw > 0) _feed = _sp.alloc * stk_speed(_s, 0) * STK_SIPHON * stk_bonus(_s, 0, 6) * _secs / _nw;
		}
	}
	for (var _l = 0; _l < array_length(_cfg); _l++) {
		var _ly = _s.layers[_l], _spd = stk_speed(_s, _l), _n = stk_sink_n(_s, _l);
		for (var _i = 0; _i < _n; _i++) {
			var _k = _ly.sinks[_i];
			if (_k.alloc <= 0) continue;
			var _f = (_ly.focus < 0) ? 1 : ((_ly.focus == _i) ? _fon : STK_FOCUS_OFF);
			_k.prog += _k.alloc * _spd * _f * _secs + ((_l == 1) ? _feed : 0);
			var _thr = stk_thr(_s, _l, _i, _k.level), _guard = 0;
			while (_k.prog >= _thr && _guard < 5000) { _guard++; _k.prog -= _thr; _k.level += 1; _k.ups += 1; _ups++; _thr = stk_thr(_s, _l, _i, _k.level); }
		}
		// the burn counts down; when it dies the overflow drains back (the clamp below)
		if (_ly.burn_t > 0) { _ly.burn_t -= _secs; if (_ly.burn_t <= 0) { _ly.burn_t = 0; _ly.burn_add = 0; _clamp = true; } }
	}
	_s.rate_t += _secs;
	if (_s.rate_t >= 5) { _s.rate = _s.rate_acc / _s.rate_t; _s.rate_acc = 0; _s.rate_t = 0; }
	if (_ups > 0 || _clamp) { stk_clamp(_s); save_mark_dirty(); }
	_s.last = universal_now();
}
