/// @description stk_bonus(s, l, i) -> sink (l, i)'s bonus multiplier (>= 1), derived at read time and never stored: 1 + per/100 x level^STK_BONUS_POW - THE DIMINISHING LAW; a reduction sink's consumer divides by it. 1 at level 0
function stk_bonus(_s, _l, _i) {
	var _lv = _s.layers[_l].sinks[_i].level;
	if (_lv <= 0) return 1;
	return 1 + (stk_per(_s, _l, _i) / 100) * power(_lv, STK_BONUS_POW);
}
