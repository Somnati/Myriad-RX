/// @description exped_abort(trip) - the mission is called off (his ask, 2026-09-15: an abort button)
/// On the way there: the ship turns around, the flight home as long as
/// the way out so far. On the world: the crew heads for the nearest
/// landing zone (recall's road - exped_next_node) and the quest is
/// dropped (no reward; the xp for what was done still pays at home).
/// Already flying home: nothing to do. Counts in the ledger.
function exped_abort(_tr) {
	if (_tr[$ "aborted"] ?? false) return;
	_tr.aborted = true;
	_tr.recall = true;
	exped_stat("aborted");
	if (_tr.stage == 0) {
		var _travel = _tr.dur * EXPED_TRAVEL;
		var _flown = clamp(_tr.t / max(1, _travel), 0, 1);
		_tr.stage = 2;
		_tr.leave_t = _tr.t - _tr.dur * EXPED_RETURN * (1 - _flown);   // (the way back is as long as the way out so far)
		array_push(_tr.log, "the abort came through. the ship turned around " + ((_flown < .5) ? "before " : "within sight of ") + _tr.dest.name);
	} else if (_tr.stage == 1) {
		array_push(_tr.log, "the abort came through. " + exped_crew_txt(_tr.names) + ((array_length(_tr.names) > 1) ? " turn" : " turns") + " for the landing zone");
		if (is_struct(_tr[$ "quest"]) && _tr.quest.done < _tr.quest.n) array_push(_tr.log, "the quest is dropped: " + _tr.quest.txt);
		// the quest's node no longer calls: the agent decides afresh
		_tr.act = undefined; _tr.path = [];
	}
	if (is_struct(_tr[$ "fork"])) { _tr.fork_pay = (_tr[$ "fork_pay"] ?? 0) + (_tr.fork[$ "held"] ?? 0); _tr.fork = undefined; }   // (a fork waiting for your tap: the question is moot - bug hunt q263)
	exped_say(_tr, "return", undefined, .6);
	save_mark_dirty();
}
