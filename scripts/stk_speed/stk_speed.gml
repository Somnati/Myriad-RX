/// @description stk_speed(s, l) -> layer l's progress a second per unit allocated: the layer's base x its speed sinks x every-speed x the cinders HELD x the FLOOD when the tide is on it
function stk_speed(_s, _l) {
	var _base = (_l == 0) ? 1 : ((_l == 1) ? STK_SPEED_AE : STK_SPEED_QU);
	var _kind = (_l == 0) ? "speed_en" : ((_l == 1) ? "speed_ae" : "speed_qu");
	var _v = _base * stk_mult(_s, _kind) * stk_mult(_s, "speed_all") * (1 + STK_CINDER_SPD * _s.cinders);
	if (_s.tide == _l) _v *= stk_tide_mult(_s);
	return _v;
}
