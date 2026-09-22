/// @description stk_catchup(s) -> the seconds replayed: the time away (a day at most) through stk_tick in ten-minute steps - the speeds and the spark rate re-read between them, so a level gained mid-absence works the rest of it
function stk_catchup(_s) {
	var _away = clamp(universal_now() - (_s[$ "last"] ?? universal_now()), 0, STK_CATCHUP_MAX);
	if (_away < 2) { _s.last = universal_now(); return 0; }
	var _left = _away;
	while (_left > 0) { var _dt = min(600, _left); _left -= _dt; stk_tick(_s, _dt); }
	_s.last = universal_now();
	return _away;
}
