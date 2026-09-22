/// @description syz_lcm(cycles) -> the grand cycle: the least common multiple of every period (capped at a million - the readout says "never" past it)
function syz_lcm(_cy) {
	var _l = 1;
	for (var _i = 0; _i < array_length(_cy); _i++) {
		var _p = _cy[_i].per, _a = _l, _b = _p;
		while (_b != 0) { var _r = _a mod _b; _a = _b; _b = _r; }
		_l = _l / _a * _p;
		if (_l > 1000000) return 1000000;
	}
	return _l;
}
