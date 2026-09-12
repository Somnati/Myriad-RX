/// @description buy_resolve(i, from, mode) - THE BUY-MODE LADDER: turn
/// a buy mode into a TARGET LEVEL (Myriad DE's update_auto_cost +
/// get_buy_max, rebuilt as one pure function).
/// Modes: 1 / 10 / 100 / 1000 / "next" / "max" (DE's set and order;
/// g.buy_lv holds the live one, cycled by the drawer's mode button).
///
/// DE'S ROUNDING LAW: x10 / x100 / x1000 do NOT buy ten levels - they
/// buy UP TO THE NEXT ROUND LEVEL. At level 37, x10 buys three levels
/// (to 40), x100 buys 63 (to 100). The next press is a clean +10 /
/// +100. That is the whole feel of the button.
///     des = floor((level + N) / N) * N
/// g.buy_round (settings > gameplay, "rounded bulk buys", DE's default
/// on) switches it: off, x10 is a flat +10 from wherever you are.
///
/// "next" = up to the NEXT MILESTONE level (DE: p_ms_req), the x100
/// rule past the top of the ladder (DE's own fallback).
///
/// "max" = EVERY level the pile can pay for. DE walked it in a ladder
/// over several frames (get_buy_max: down by multiples while too dear,
/// then up one level per frame until the edge); RX finds the same
/// edge in one call by doubling out then bisecting dial_cost (a closed
/// form, so every probe is O(1)). No round-level snap: the techdemo
/// snapped down and left up to 95 levels unbought (his check,
/// 2026-09-03). Can't afford one level: quotes level+1 anyway, so the
/// button can show the price, dimmed.
/// @param [wallet]  what "max" may spend - the spendable pile by default;
///                  autobuy hands in its cap share (his call, 2026-09-12:
///                  buy max within the cap, every pulse)
function buy_resolve(_i, _from, _mode, _wallet = undefined) {
	var _to = _from + 1;

	if (is_real(_mode)) {
		var _n = max(1, floor(_mode));
		var _round = (!variable_global_exists("buy_round") || g.buy_round);
		if (_n == 1)      _to = _from + 1;
		else if (_round)  _to = floor((_from + _n) / _n) * _n;   // DE: up to the round level
		else              _to = _from + _n;                       // flat
	}
	else if (_mode == "next") {
		// up to the next milestone rung; past the top of the ladder DE
		// falls back to the x100 rule, and so does this
		var _nx = milestone_next(_from);
		_to = (_nx > _from) ? _nx : floor((_from + 100) / 100) * 100;
	}
	else if (_mode == "max") {
		// the RESERVE is not the wallet - see profit_spendable
		var _wal = _wallet ?? profit_spendable();
		if (!(_wal >= dial_cost(_i, _from, _from + 1))) return _from + 1;
		var _step = 1;
		while (_step < 1000000
			&& _wal >= dial_cost(_i, _from, _from + _step * 2)) _step *= 2;
		var _lo = _from + _step;       // affordable
		var _hi = _from + _step * 2;   // not (or the search cap)
		while (_hi - _lo > 1) {
			var _mid = (_lo + _hi) div 2;
			if (_wal >= dial_cost(_i, _from, _mid)) _lo = _mid;
			else _hi = _mid;
		}
		_to = _lo;   // the exact edge: cost(from, lo) fits, cost(from, lo+1) doesn't
	}

	return max(_to, _from + 1);
}
