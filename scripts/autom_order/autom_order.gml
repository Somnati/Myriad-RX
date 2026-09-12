/// @description autom_order(n) -> the dials in the strategy's order
/// strongest first: by p/s, best first (the p/s the panel already
/// marks in gold). cheapest first: by the next level's price, least
/// first. round-robin: the roster rotated to start at the cursor
/// (dial_all.cur), which the walk advances one pulse at a time. Only
/// dials with a level count (a dead slot has no price to compare).
/// @param n   how many dials there are
function autom_order(_n) {
	autom_init();
	var _a = g.autom;
	var _o = [];
	for (var _i = 0; _i < _n; _i++) array_push(_o, _i);
	switch (_a.strat) {
		case 1:
			array_sort(_o, function(_p, _q) {
				var _gp = g.dial[_p].gps, _gq = g.dial[_q].gps;
				var _ap = (_gp >= arb(1)), _aq = (_gq >= arb(1));
				if (_ap != _aq) return _ap ? -1 : 1;
				if (!_ap) return _p - _q;
				if (_gp > _gq) return -1;
				if (_gq > _gp) return 1;
				return _p - _q;
			});
			break;
		case 2:
			array_sort(_o, function(_p, _q) {
				var _lp = g.dial[_p].level, _lq = g.dial[_q].level;
				var _cp = dial_cost(_p, _lp, _lp + 1), _cq = dial_cost(_q, _lq, _lq + 1);
				if (_cq > _cp) return -1;
				if (_cp > _cq) return 1;
				return _p - _q;
			});
			break;
		case 3: {
			var _c = _a.dial_all.cur mod max(1, _n);
			var _r = [];
			for (var _i = 0; _i < _n; _i++) array_push(_r, _o[(_c + _i) mod _n]);
			_o = _r;
			break;
		}
	}
	return _o;
}
