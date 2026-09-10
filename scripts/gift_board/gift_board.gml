/// @description gift_board() -> the current cycle's 14 slots, each
/// { rar : tier index, kind : 0 profit / 1 credits }. Fully DERIVED:
/// every slot rolls from a seed built on (cycle, slot) - the house
/// per-child pattern - so the board is stable across boots and saves
/// carry zero board state. Tier odds lerp from cfg.w_first to
/// cfg.w_last across the fortnight and the week-cap slots wear their
/// guaranteed floors. The seeded section leaves through rng_release
/// (never a set_seed "restore" - that rewinds the ambient stream).
function gift_board() {
	gift_init();
	var _c = g.gift_cfg;
	var _n = _c.days;
	var _nr = array_length(_c.rars);
	var _out = array_create(_n);
	var _sd = random_get_seed();
	for (var _i = 0; _i < _n; _i++) {
		random_set_seed((((g.gift.cycle * _n + _i + 1) * 2654435761)
			& $7fffffff) ^ 40503);

		// tier weights, lerped across the board
		var _t = _i / (_n - 1);
		var _tot = 0;
		var _w = array_create(_nr);
		for (var _r = 0; _r < _nr; _r++) {
			_w[_r] = lerp(_c.w_first[_r], _c.w_last[_r], _t);
			_tot += _w[_r];
		}
		var _p = random(_tot);
		var _rar = _nr - 1;
		for (var _r = 0; _r < _nr; _r++) {
			if (_p < _w[_r]) { _rar = _r; break; }
			_p -= _w[_r];
		}
		// week-cap floors: each week ends on a showpiece
		if (_i == _c.floor_a) _rar = max(_rar, _c.floor_a_tier);
		if (_i == _c.floor_b) _rar = max(_rar, _c.floor_b_tier);

		var _kind = (random(100) < _c.profit_odds) ? 0 : 1;
		_out[_i] = { rar : _rar, kind : _kind };
	}
	rng_release(_sd);
	return _out;
}
