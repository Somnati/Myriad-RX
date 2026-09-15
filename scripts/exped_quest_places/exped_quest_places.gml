/// @description exped_quest_places(quest) -> every stop the quest visits, in order (the hours, the hazards, the odds read it)
function exped_quest_places(_q) {
	if (!is_struct(_q)) return [];
	if (_q.kind == "survey" && is_array(_q[$ "nodes"]) && array_length(_q.nodes) > 0) return _q.nodes;
	if ((_q[$ "from"] ?? -1) >= 0) return [_q.from, _q.node];
	return [_q.node];
}
