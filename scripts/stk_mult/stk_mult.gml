/// @description stk_mult(s, kind) -> the product of every sink's bonus of that kind across the stack (the consumers read it): "spark", "speed_en", "speed_ae", "speed_qu", "speed_all", "thr_en", "thr_ae", "thr_qu", "capcost"
function stk_mult(_s, _kind) {
	var _cfg = stk_config(), _m = 1;
	for (var _l = 0; _l < array_length(_cfg); _l++) for (var _i = 0; _i < array_length(_cfg[_l]); _i++) if (_cfg[_l][_i].kind == _kind) _m *= stk_bonus(_s, _l, _i);
	return _m;
}
