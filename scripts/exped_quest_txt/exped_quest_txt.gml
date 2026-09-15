/// @description exped_quest_txt(quest, region) -> the quest's one line ("escort bokk the merchant from Old Mill to Ashen Ford")
/// THE one builder: exped_quest_gen writes it, the save rebuilds it the
/// same way (exped_unpack), so a loaded quest reads as it did.
function exped_quest_txt(_q, _rg) {
	static _pl = function(_f) { return (_f == "wolf") ? "wolves" : (_f + "s"); };
	var _nn = array_length(_rg.nodes);
	var _nm = function(_i, _rg2, _nn2) { return _rg2.nodes[clamp(_i, 0, _nn2 - 1)].name; };
	var _to = _nm(_q.node, _rg, _nn), _fr = _nm((_q[$ "from"] ?? -1) >= 0 ? _q.from : _q.node, _rg, _nn);
	var _nk = _rg.nodes[clamp(_q.node, 0, _nn - 1)].kind;
	switch (_q.kind) {
		case "slay":   return ((_nk == "dungeon" || _nk == "crypt") ? "travel to " : "go to ") + _to + " and slay " + string(_q.n) + " " + _pl(_q.foe);
		case "clear":  return "clear " + _to + " (" + string(_q.n) + " rooms)";
		case "rout":   return "rout the bandits at " + _to;
		case "scout":  return "scout " + _to + " and come back";
		case "escort": return "escort " + (_q[$ "who"] ?? "a merchant") + " from " + _fr + " to " + _to;
		case "fetch":  return "fetch " + (_q[$ "who"] ?? "a thing") + " from " + _fr + " to " + _to;
		case "rescue": return "find " + (_q[$ "who"] ?? "someone") + ", lost at " + _fr + ", and bring them to " + _to;
		case "bounty": return "bring down " + (_q[$ "who"] ?? ("the " + _q.foe)) + " at " + _to;
		case "defend": return "hold " + _to + " against " + string(_q.n) + " waves of " + _pl(_q.foe);
		case "survey": {
			var _ns = _q[$ "nodes"], _l = [];
			if (is_array(_ns)) for (var _i = 0; _i < array_length(_ns); _i++) array_push(_l, _nm(_ns[_i], _rg, _nn));
			return "chart " + exped_crew_txt(_l);
		}
		case "gather": return "bring " + string(_q.n) + " sacks of " + (_q[$ "who"] ?? "ore") + " back from " + _to;
	}
	return _q.kind + " " + _to;
}
