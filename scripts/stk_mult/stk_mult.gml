/// @description stk_mult(s, kind) -> the product of every open sink's bonus of that kind across the stack (the consumers read it), x the MIRROR when aether's focused sink is of that kind: "spark", "speed_en", "speed_ae", "speed_qu", "speed_all", "thr_en", "thr_ae", "thr_qu", "capcost"
function stk_mult(_s, _kind) {
	var _cfg = stk_config(), _m = 1;
	for (var _l = 0; _l < array_length(_cfg); _l++) {
		var _n = stk_sink_n(_s, _l);
		for (var _i = 0; _i < _n; _i++) if (_cfg[_l][_i].kind == _kind) _m *= stk_bonus(_s, _l, _i);
	}
	var _ae = _s.layers[1];
	if (stk_sink_n(_s, 1) >= 7 && _ae.focus >= 0 && _ae.focus != 6 && _ae.sinks[6].level > 0 && _cfg[1][_ae.focus].kind == _kind) _m *= stk_bonus(_s, 1, 6);
	return _m;
}
