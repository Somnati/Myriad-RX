/// @description exped_quest_places(quest) -> every stop the quest visits, in order (the hours, the hazards, the odds read it)
function exped_quest_places(_q) {
	if (!is_struct(_q)) return [];
	if (_q.kind == "survey" && is_array(_q[$ "nodes"]) && array_length(_q.nodes) > 0) {
		// (a copy: the quest's own list must not be a caller's scratch array - bug hunt 2026-09-16)
		var _out = [];
		for (var _i = 0; _i < array_length(_q.nodes); _i++) array_push(_out, _q.nodes[_i]);
		return _out;
	}
	if ((_q[$ "from"] ?? -1) >= 0) return [_q.from, _q.node];
	return [_q.node];
}
