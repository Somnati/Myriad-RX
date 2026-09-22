/// @description stk_eta(s, l, i) -> seconds to sink (l, i)'s next level at its allocation now, or -1 with none
function stk_eta(_s, _l, _i) {
	var _k = _s.layers[_l].sinks[_i], _ly = _s.layers[_l];
	if (_k.alloc <= 0) return -1;
	var _f = (_ly.focus < 0) ? 1 : ((_ly.focus == _i) ? stk_focus_on(_s) : STK_FOCUS_OFF);
	var _v = _k.alloc * stk_speed(_s, _l) * _f;
	if (_v <= 0) return -1;
	return max(0, (stk_thr(_s, _l, _i, _k.level) - _k.prog) / _v);
}
