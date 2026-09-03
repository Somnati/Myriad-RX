/// @description buy_resolve(i, from, mode) - THE BUY-MODE LADDER: turn
/// a buy mode into a TARGET LEVEL (Myriad DE's update_auto_cost +
/// get_buy_max, rebuilt as one pure function).
/// Modes: 1 / 10 / 100 / 1000 / "next" / "max" (DE's set and order;
/// g.buy_lv holds the live one, cycled by the drawer's mode button).
///
/// DE'S ROUNDING LAW, kept exactly: x10 / x100 / x1000 do NOT buy ten
/// levels - they buy UP TO THE NEXT ROUND LEVEL. At level 37, x10 buys
/// three levels (to 40), x100 buys 63 (to 100). The next press is a
/// clean +10 / +100. That is the whole feel of the button.
///     des = floor((level + N) / N) * N
///
/// "next" = up to the NEXT MILESTONE level (DE: p_ms_req). Until the
/// milestone system lands it falls back to the x100 rule, as DE does
/// when a dial has no further milestone (p_ms_level = -1).
/// >>> MILESTONES: replace the fallback with the ladder's next level.
///
/// "max" = the largest target the pile can pay for. DE walked it in a
/// ladder over several frames (get_buy_max); RX finds the edge in one
/// call by doubling out then bisecting dial_cost (a closed form, so
/// every probe is O(1)), then SNAPS DOWN to the biggest round level
/// that still fits - DE's descent steps 1000000 / 100000 / 10000 /
/// 1000 / 500 / 100 / 50 / 10 - or keeps the raw edge when no round
/// level clears the current level. Can't afford one level: quotes
/// level+1 anyway, so the button can show the price, dimmed.
function buy_resolve(_i, _from, _mode) {
	var _to = _from + 1;

	if (is_real(_mode)) {
		var _n = max(1, floor(_mode));
		_to = (_n == 1) ? _from + 1 : (floor((_from + _n) / _n) * _n);
	}
	else if (_mode == "next") {
		// >>> MILESTONES: _to = dial_milestone_next(_i, _from) when it exists
		_to = floor((_from + 100) / 100) * 100;
	}
	else if (_mode == "max") {
		if (!(g.profit >= dial_cost(_i, _from, _from + 1))) return _from + 1;
		var _step = 1;
		while (_step < 1000000
			&& g.profit >= dial_cost(_i, _from, _from + _step * 2)) _step *= 2;
		var _lo = _from + _step;       // affordable
		var _hi = _from + _step * 2;   // not (or the search cap)
		while (_hi - _lo > 1) {
			var _mid = (_lo + _hi) div 2;
			if (g.profit >= dial_cost(_i, _from, _mid)) _lo = _mid;
			else _hi = _mid;
		}
		_to = _lo;
		var _snaps = [1000000, 100000, 10000, 1000, 500, 100, 50, 10];
		for (var _s = 0; _s < array_length(_snaps); _s++) {
			var _r = (_to div _snaps[_s]) * _snaps[_s];
			if (_r > _from) { _to = _r; break; }
		}
	}

	return max(_to, _from + 1);
}
