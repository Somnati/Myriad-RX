/// @description exped_eta(dest, quest) -> seconds the trip should take (an estimate), -1 for an explore
/// The flight there, the roads there and back (the quest's hours x
/// EXPED_HOUR), the doing (a few steps of EXPED_ROOM_T), the flight home.
function exped_eta(_d, _q) {
	if (!is_struct(_q)) return -1;
	var _fly = _d.dist * (EXPED_TRAVEL + EXPED_RETURN);
	var _roads = 2 * (_q[$ "hours"] ?? 0) * EXPED_HOUR;
	var _do = ((_q.kind == "scout") ? 1 : 4) * EXPED_ROOM_T;
	return _fly + _roads + _do;
}
