/// @description exped_quest_txt(quest, region) -> the quest's one line ("escort bokk the merchant from Old Mill to Ashen Ford")
/// THE one builder: exped_quest_gen writes it, the save rebuilds it the
/// same way (exped_unpack), so a loaded quest reads as it did.
function exped_quest_txt(_q, _rg) {
	static _pl = function(_f) { return foe_plural(_f); };
	var _nn = array_length(_rg.nodes);
	var _nm = function(_i, _rg2, _nn2) { return _rg2.nodes[clamp(_i, 0, _nn2 - 1)].name; };
	var _to = _nm(_q.node, _rg, _nn), _fr = _nm((_q[$ "from"] ?? -1) >= 0 ? _q.from : _q.node, _rg, _nn);
	var _nk = _rg.nodes[clamp(_q.node, 0, _nn - 1)].kind;
	switch (_q.kind) {
		case "slay":   return ((_nk == "dungeon" || _nk == "crypt" || _nk == "sewer") ? "travel to " : "go to ") + _to + " and slay " + string(_q.n) + " " + _pl(_q.foe);
		// THE TOWN QUESTS (2026-09-16)
		case "parcel":  return "carry " + (_q[$ "who"] ?? "a parcel") + " from " + _fr + " to " + _to;
		case "goat":    return "walk " + (_q[$ "who"] ?? "a goat") + " from " + _fr + " to " + _to;
		case "count": {
			var _ns2 = _q[$ "nodes"], _l2 = [];
			if (is_array(_ns2)) for (var _i2 = 0; _i2 < array_length(_ns2); _i2++) array_push(_l2, _nm(_ns2[_i2], _rg, _nn));
			return "count the " + (_q[$ "who"] ?? "geese") + " at " + exped_crew_txt(_l2);
		}
		case "shop":    return "mind the shop in " + _to + " for a day";
		case "nothing": return "go to " + _to + " and stand in it for " + string(_q.n) + " hours";
		case "cellars": return "clear the cellars of " + _to + " of " + string(_q.n) + " " + _pl(_q.foe);
		case "well":    return "see what is in the well at " + _to;
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
