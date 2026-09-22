/// @description syz_yield(s, i) -> what cycle i pays a fire, before any conjunction: per^SYZ_PER_POW x the level's climb (x1.18 a level) x in tune (a period a whole multiple of another cycle's, or a whole divisor of one: +SYZ_TUNE_BONUS)
function syz_yield(_s, _i) {
	var _c = _s.cycles[_i], _tune = false;
	for (var _j = 0; _j < array_length(_s.cycles) && !_tune; _j++) {
		if (_j == _i) continue;
		var _q = _s.cycles[_j].per;
		if (_q != _c.per && ((_c.per mod _q) == 0 || (_q mod _c.per) == 0)) _tune = true;
	}
	return power(_c.per, SYZ_PER_POW) * power(1.18, _c.lv - 1) * (_tune ? (1 + SYZ_TUNE_BONUS) : 1);
}
