/// @description stk_per(s, l, i) -> sink (l, i)'s per today: the roster's, x1.5 at each MILESTONE held (levels 10 / 25 / 50 / 100 / 200 - the stars), x the keystone (every bonus)
function stk_per(_s, _l, _i) {
	var _cfg = stk_config()[_l][_i], _lv = _s.layers[_l].sinks[_i].level, _p = _cfg.per;
	static _ms = [10, 25, 50, 100, 200];
	for (var _m = 0; _m < array_length(_ms); _m++) if (_lv >= _ms[_m]) _p *= 1.5;
	if (_cfg.kind != "per_all") {
		var _ks = _s.layers[2].sinks[0];   // the keystone
		if (_ks.level > 0) _p *= 1 + (stk_config()[2][0].per / 100) * power(_ks.level, STK_BONUS_POW);
	}
	return _p;
}
