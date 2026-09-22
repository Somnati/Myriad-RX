/// @description syz_next(s, [horizon]) -> { at, k } the next CONJUNCTION coming (two or more cycles firing in the same quarter second), or undefined within the horizon (the grand cycle, or four minutes at most) - the readout's "next: 3 in 14s"
function syz_next(_s, _hor = undefined) {
	var _n = array_length(_s.cycles);
	if (_n < 2) return undefined;
	if (is_undefined(_hor)) _hor = min(240, syz_lcm(_s.cycles));
	var _step = .25, _t = 0;
	var _ph = array_create(_n, 0);
	for (var _i = 0; _i < _n; _i++) _ph[_i] = _s.cycles[_i].t;
	while (_t < _hor) {
		_t += _step;
		var _k = 0;
		for (var _i = 0; _i < _n; _i++) { _ph[_i] += _step; if (_ph[_i] >= _s.cycles[_i].per) { _ph[_i] -= _s.cycles[_i].per; _k++; } }
		if (_k >= 2) return { at : _t, k : _k };
	}
	return undefined;
}
