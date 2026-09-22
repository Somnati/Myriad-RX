/// @description coll_tick(c, secs) - THE runner: both cascades advance by the exact closed form (one call, any window); the auto-collider fires on its interval - a window longer than the interval is walked collision by collision (the closed form between, exact), the walk coarsened past 3000 steps (a month at 3 s would be a million) so a long absence still lands in a frame
function coll_tick(_c, _secs) {
	if (_secs <= 0 || _c.inf) return;
	var _lf = coll_lfield(_c), _ev = coll_auto_every(_c.auto_lv);
	if (_ev <= 0) { cas_tick(_c.m, _secs, _lf); cas_tick(_c.a, _secs, _lf); return; }
	var _step = max(_ev, _secs / 3000), _left = _secs;
	while (_left > 0 && !_c.inf) {
		var _dt = min(_left, _step - _c.auto_t);
		if (_dt > 0) { cas_tick(_c.m, _dt, _lf); cas_tick(_c.a, _dt, _lf); _left -= _dt; _c.auto_t += _dt; }
		if (_c.auto_t >= _step - .0001) { _c.auto_t = 0; coll_collide(_c); }
	}
}
