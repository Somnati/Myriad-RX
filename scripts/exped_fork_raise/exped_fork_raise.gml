/// @description exped_fork_raise(trip, fork) -> true when it resolved at once (the crew chose), false when the card is waiting for you (q258)
/// The fork onto the trip (the cadence's stamp: count, world time, the
/// node), its prompt into the diary; then the crew's own choice through
/// exped_fork_lean + exped_fork_choose - unless you are watching the
/// page (exped_fork_watched), where the card waits its window and
/// exped_agent pays the held seconds back after
function exped_fork_raise(_tr, _fk) {
	_tr.fork = _fk;
	_tr.fork_n = (_tr[$ "fork_n"] ?? 0) + 1;
	_tr.fork_t = _tr[$ "planet_t"] ?? 0;
	if (!is_array(_tr[$ "fork_at"])) _tr.fork_at = [];
	array_push(_tr.fork_at, _tr.pos);
	array_push(_tr.log, "* " + _fk.prompt);
	exped_stat("forks");
	if (exped_fork_watched(_tr)) return false;
	exped_fork_choose(_tr, exped_fork_lean(_tr), false);
	return true;
}
