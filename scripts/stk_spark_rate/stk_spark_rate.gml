/// @description stk_spark_rate(s) -> spark a second: every generator (per x level^0.75 a second) x the spark sinks x the cinders
function stk_spark_rate(_s) {
	var _cfg = stk_config(), _g = 0;
	for (var _l = 0; _l < array_length(_cfg); _l++) for (var _i = 0; _i < array_length(_cfg[_l]); _i++) {
		if (_cfg[_l][_i].kind != "gen") continue;
		var _lv = _s.layers[_l].sinks[_i].level;
		if (_lv > 0) _g += (stk_per(_s, _l, _i) / 100) * power(_lv, STK_BONUS_POW);
	}
	return _g * stk_mult(_s, "spark") * (1 + STK_CINDER_SPK * _s.cinders);
}
