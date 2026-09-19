/// @description exped_fork_allowed(trip, [node]) -> true when a fork may be raised now: none open, EXPED_FORK_EVERY world hours since the last, never twice at one node (q258)
function exped_fork_allowed(_tr, _node = -1) {
	if (is_struct(_tr[$ "fork"])) return false;
	if ((_tr[$ "planet_t"] ?? 0) - (_tr[$ "fork_t"] ?? -1000000) < EXPED_FORK_EVERY * EXPED_HOUR) return false;
	if (_node >= 0 && is_array(_tr[$ "fork_at"]) && array_contains(_tr.fork_at, _node)) return false;
	return true;
}
