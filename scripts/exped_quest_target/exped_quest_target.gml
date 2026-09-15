/// @description exped_quest_target(quest) -> the node the crew heads for NOW (-1 = no quest)
/// The two-stop kinds (escort / fetch / rescue) go to `from` until `at`
/// says the first stop is done, then to node; a survey walks its nodes
/// in order (done = how many are charted); every other kind, its node.
function exped_quest_target(_q) {
	if (!is_struct(_q)) return -1;
	switch (_q.kind) {
		case "escort": case "fetch": case "rescue": return ((_q[$ "at"] ?? 0) == 0 && (_q[$ "from"] ?? -1) >= 0) ? _q.from : _q.node;
		case "survey": { var _ns = _q[$ "nodes"]; if (is_array(_ns) && array_length(_ns) > 0) return _ns[clamp(_q.done, 0, array_length(_ns) - 1)]; break; }
	}
	return _q.node;
}
