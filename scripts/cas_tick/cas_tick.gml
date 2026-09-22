/// @description cas_tick(c, secs, lfield) - THE FRAMEWORK's exact closed form (dims_tick's math, the cascade as a parameter): the cascade is linear - tier i grows at count[i+1] x rate[i+1], nothing consumes anything - so its solution is the finite Taylor sum: tier j's gift to tier i after t seconds is count[j] x prod(rates i+1..j) x t^(j-i) / (j-i)!, and the stock (tier 0's integral) gets one more order. One call covers a frame or a month with zero drift. Rates hold across the window (true whenever nobody buys - the offline case exactly). All LOG10; the running term is a float add an order; empty tiers sit at the sentinel and fall out by arithmetic
function cas_tick(_c, _t, _lfield) {
	if (_t <= 0) return;
	var _la = cas_rates(_c, _lfield), _lt = log10(_t);
	var _new = array_create(COLL_N);
	for (var _i = 0; _i < COLL_N; _i++) {
		var _sum = _c.count[_i], _term = 0;
		for (var _j = _i + 1; _j < COLL_N; _j++) {
			_term += _la[_j] + _lt - log10(_j - _i);
			_sum = lg_add(_sum, _c.count[_j] + _term);
		}
		_new[_i] = _sum;
	}
	var _ft = _la[0] + _lt, _fg = _c.count[0] + _ft;
	for (var _j = 1; _j < COLL_N; _j++) {
		_ft += _la[_j] + _lt - log10(_j + 1);
		_fg = lg_add(_fg, _c.count[_j] + _ft);
	}
	_c.count = _new;
	_c.stock = lg_add(_c.stock, _fg);
}
