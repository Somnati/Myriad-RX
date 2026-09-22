/// @description syz_catchup(s) -> the seconds replayed: the time away run through syz_tick at a quarter second (six hours at most) - the clockwork is exact, so the conjunctions that would have come, came
function syz_catchup(_s) {
	var _away = clamp(universal_now() - (_s[$ "last"] ?? universal_now()), 0, SYZ_CATCHUP_MAX);
	if (_away < 2) { _s.last = universal_now(); return 0; }
	var _left = _away;
	while (_left > 0) { var _dt = min(.25, _left); _left -= _dt; syz_tick(_s, _dt, false); }
	_s.last = universal_now();
	return _away;
}
