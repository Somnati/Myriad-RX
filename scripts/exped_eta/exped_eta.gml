/// @description exped_eta(dest, quest) -> seconds the trip should take (an estimate), -1 for an explore
/// The flight there, the roads there and back (the quest's hours x
/// EXPED_HOUR), the doing (a few steps of EXPED_ROOM_T), the flight home.
function exped_eta(_d, _q) {
	if (!is_struct(_q)) return -1;
	var _fly = _d.dist * (EXPED_TRAVEL + EXPED_RETURN);
	// an explore card (2026-09-15): a ramble's hours, a survey's places (~2.5 h each); a wander has no end
	if ((_q[$ "kind"] ?? "") == "explore") {
		if (_q.ex == "ramble") return _fly + _q.n * EXPED_HOUR + 2 * EXPED_HOUR;
		if (_q.ex == "survey") return _fly + _q.n * 2.5 * EXPED_HOUR + 2 * EXPED_HOUR;
		return -1;
	}
	var _roads = 2 * (_q[$ "hours"] ?? 0) * EXPED_HOUR;
	var _do = ((_q.kind == "scout") ? 1 : 4) * EXPED_ROOM_T;
	return _fly + _roads + _do;
}
