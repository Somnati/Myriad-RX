/// @description coll_catchup(c) -> the seconds replayed since `last` (30 days at most): the wall clock's absence through coll_tick - exact by construction (the framework's point), the auto-collider walked
function coll_catchup(_c) {
	var _now = universal_now(), _away = clamp(_now - (_c[$ "last"] ?? _now), 0, COLL_AWAY_MAX);
	if (_away > 0) coll_tick(_c, _away);
	_c.last = _now;
	return _away;
}
