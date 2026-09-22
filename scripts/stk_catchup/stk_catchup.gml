/// @description stk_catchup(s) -> the seconds replayed: the time away (a day, + a day a rank of the long reach) through stk_tick in ten-minute steps at their own wall seconds (the tide walks, burns die) - the speeds and the spark rate re-read between them, so a level gained mid-absence works the rest of it; THE HAND (a perk) re-runs [chase] on every open layer each step
function stk_catchup(_s) {
	var _now = universal_now(), _from = _s[$ "last"] ?? _now;
	var _away = clamp(_now - _from, 0, STK_CATCHUP_MAX * (1 + stk_perk(_s, "reach")));
	if (_away < 2) { _s.last = _now; return 0; }
	var _left = _away, _hand = (stk_perk(_s, "hand") > 0), _t0 = _now - _away;
	while (_left > 0) {
		var _dt = min(STK_HAND_EVERY, _left);
		stk_tick(_s, _dt, _t0 + (_away - _left));
		_left -= _dt;
		if (_hand) for (var _l = 0; _l < 3; _l++) if (stk_cap(_s, _l) > 0) stk_preset(_s, _l, "chase");
	}
	_s.last = _now;
	return _away;
}
