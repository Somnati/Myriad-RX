/// @description syz_tick(s, dt, [live]) - THE CLOCKWORK for dt seconds (q315): every cycle's phase runs, the ones that cross their period FIRE - together in one tick is a CONJUNCTION and each pays k times over (the harmonic); the drift's wobble; the sync's cooldown. live = the flash and the log (the room), false in the catch-up
/// A tick holds at most one fire a cycle (dt is a frame or a quarter second; the shortest period is three), so the
/// fires of a tick are the set that align. A grand conjunction (every cycle, three or more) mints a token
function syz_tick(_s, _dt, _live = true) {
	var _n = array_length(_s.cycles), _fired = [], _k = 0;
	for (var _i = 0; _i < _n; _i++) {
		var _c = _s.cycles[_i];
		_c.t += _dt;
		if (_c.fired > 0) _c.fired = max(0, _c.fired - _dt);
		if (_c.t >= _c.per) { _c.t -= _c.per; array_push(_fired, _i); _k++; }
	}
	if (_k > 0) {
		var _mult = 1 + (_k - 1) * _s.harm, _got = 0;
		for (var _f = 0; _f < _k; _f++) {
			var _i2 = _fired[_f], _c2 = _s.cycles[_i2];
			_got += syz_yield(_s, _i2) * _mult;
			_c2.fired = .6; _c2.k = _k;
		}
		_s.flux += _got; _s.life += _got; _s.rate_acc += _got;
		if (_k >= 2) {
			_s.conj[min(9, _k)] += 1;
			_s.best = max(_s.best, _k);
			if (_k == _n && _n >= 3) {
				var _tk = (_n >= 7) ? 3 : ((_n >= 5) ? 2 : 1);
				_s.tokens += _tk; _s.grand += 1;
				if (_live) syz_log(_s, "GRAND CONJUNCTION  -  " + string(_n) + " as one, +" + string(_tk) + " token" + ((_tk > 1) ? "s" : ""));
			} else if (_live) syz_log(_s, string(_k) + " in conjunction  x" + string_format(_mult, 1, 1) + "  +" + syz_num(_got));
		}
	}
	// THE DRIFT: now and then an unanchored cycle slips a fraction of a second - its alignments are gone until a sync or an anchor
	_s.drift_t -= _dt;
	if (_s.drift_t <= 0) {
		_s.drift_t = SYZ_DRIFT_EVERY * random_range(.7, 1.3);
		var _free = [];
		for (var _i = 0; _i < _n; _i++) if (!_s.cycles[_i].anchor) array_push(_free, _i);
		if (array_length(_free) > 0) {
			var _w = _free[irandom(array_length(_free) - 1)], _by = random_range(.3, 1.4);
			_s.cycles[_w].t = (_s.cycles[_w].t + _by) mod _s.cycles[_w].per;
			_s.wobbles += 1;
			if (_live) syz_log(_s, "cycle " + string(_w + 1) + " wobbles " + string_format(_by, 1, 1) + "s off its phase");
		}
	}
	if (_s.sync_cd > 0) _s.sync_cd = max(0, _s.sync_cd - _dt);
	// the readout's rate, over the last ten seconds
	_s.rate_t += _dt;
	if (_s.rate_t >= 10) { _s.rate = _s.rate_acc / _s.rate_t; _s.rate_acc = 0; _s.rate_t = 0; }
	_s.last = universal_now();
}
