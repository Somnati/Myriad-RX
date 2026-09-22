/// @description stk_cap(s, l) -> layer l's cap, a whole number: energy = the base + the buys + the cap sinks aimed at it (the hollow, the loop); aether = the well's (+ the ember's); quintessence = the deep well's - each through stk_capof. 0 = the layer is shut
function stk_cap(_s, _l) {
	var _cfg = stk_config(), _cap = (_l == 0) ? (STK_CAP_BASE + _s.cap_lv * STK_CAP_STEP) : 0;
	var _kind = (_l == 0) ? "cap_en" : ((_l == 1) ? "cap_ae" : "cap_qu"), _kflat = _kind + "_flat";
	for (var _k = 0; _k < 3; _k++) for (var _i = 0; _i < array_length(_cfg[_k]); _i++) {
		var _kd = _cfg[_k][_i].kind;
		if (_kd == _kind || _kd == _kflat) _cap += stk_capof(_s, _k, _i);
	}
	return _cap;
}
