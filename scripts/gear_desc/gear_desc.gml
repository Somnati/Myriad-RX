/// @description gear_desc(item) -> the popup's line of voice: where it is from, what its quirks do, or a word on its rarity
function gear_desc(_it) {
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
