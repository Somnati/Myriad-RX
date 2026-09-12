/// @description ccore_tick(secs) - the well's clock, on a seconds budget
/// (syst_production's heartbeat, the time bank's burn and the offline
/// replay all call it - one code path, so away == here by construction)
/// PRODUCING fills at the rate to the cap and stops there (FULL);
/// COOLING counts the cooldown down and, when it runs out, the
/// overshoot fills the well (DE's carry: a long absence spent cooling
/// does not lose its remainder).
/// @param secs
function ccore_tick(_secs) {
	ccore_init();
	var _c = g.ccore;
	if (_c.lv <= 0) { _c.st = 0; return; }
	if (_c.st == 0) { _c.st = 1; _c.xp = 0; }
	var _v = ccore_values();
	if (_c.st == 3) {
		var _rate = max(.0001, _c.cool_from) / CCORE_COOL;   // per second
		_c.xp -= _rate * _secs;
		if (_c.xp <= 0) {
			var _over = -_c.xp / _rate;   // seconds past the end of the cooldown
			_c.xp = _over * _v.gain;
			_c.st = 1;
		} else return;
	}
	if (_c.st == 1) {
		_c.xp += _v.gain * _secs;
		if (_c.xp >= _v.cap) { _c.xp = _v.cap; _c.st = 2; }
	}
	if (_c.st == 2 && _c.xp < _v.cap) _c.st = 1;   // the cap grew under it (a split drag)
}
