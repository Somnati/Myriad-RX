/// @description gear_desc(item) -> the popup's line of voice: where it is from, what its quirks do, or a word on its rarity
function gear_desc(_it) {
	if ((_it[$ "slot"] ?? "") == "use") {
		switch (_it.kind) {
			case "hp":    return (_it.size >= 2) ? "a big red potion: eight tenths of the hp back. drunk when it is bad, by whoever carries it." : "a red potion: four tenths of the hp back. drunk when low - the nervous early, the brave late, the greedy at the last moment, the dreamy when they remember.";
			case "mp":    return (_it.size >= 2) ? "a big blue potion: all the mp back, drunk in a fight when the mp is short of a skill." : "a blue potion: half the mp back, drunk in a fight when the mp is short of a skill.";
			case "tonic": return "a tonic: drunk at the door of a fight under a hazard the carrier has nothing else against. holds the hazard for that fight.";
			case "totem": return "the totem of don't die. a carrier who falls stands up at half hp, and the totem cracks. one use. keep it in the pocket.";
			case "elixir": return "an elixir: drunk on the spot. +1 to a line, for good.";
		}
		return "a bottle of something.";
	}
	var _s = "";
	var _tg = gear_tags()[$ (_it[$ "tag"] ?? "")];
	if (is_struct(_tg)) _s += _tg.origin + ". ";
	if ((_it[$ "own"] ?? "") != "") _s += "it was " + _it.own + "'s. it is not now. ";
	var _qs = gear_quirks(), _ql = _it[$ "quirks"] ?? [];
	for (var _i = 0; _i < array_length(_ql); _i++) for (var _j = 0; _j < array_length(_qs); _j++) if (_qs[_j].key == _ql[_i]) _s += _qs[_j].desc + " ";
	if (_s == "") {
		var _r = _it[$ "rar"] ?? 0;
		if (_r <= 0)      _s = "common as mud, and about as useful, which is more than it sounds.";
		else if (_r == 1) _s = "a cut above mud. not a large cut.";
		else              _s = "the kind of thing that gets talked about, briefly.";
	}
	return string_trim(_s);
}
