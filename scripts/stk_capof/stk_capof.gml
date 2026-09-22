/// @description stk_capof(s, l, i) -> the cap a CAP sink (l, i) gives its target layer: floor(per/100 x level^STK_CAP_POW) - the well deepens faster the deeper it goes (level ~ log t: the cap ~ log(t)^1.5, sublinear, no runaway)
function stk_capof(_s, _l, _i) {
	var _lv = _s.layers[_l].sinks[_i].level;
	if (_lv <= 0) return 0;
	return floor((stk_config()[_l][_i].per / 100) * power(_lv, STK_CAP_POW));
}
