/// @description mood_pack(sprite) -> the mood as one save field: v~a~e~why~lostname~lostbond~lostg~pokes~pday ("" at rest) (q261)
function mood_pack(_sp) {
	var _m = _sp[$ "mood"];
	if (!is_struct(_m)) return "";
	var _cl = function(_s) { return string_replace_all(string_replace_all(string_replace_all(string_replace_all(string(_s), "|", " "), "/", " "), "~", " "), "^", " "); };
	var _l = is_struct(_m.lost) ? (_cl(_m.lost.name) + "~" + string(_m.lost.bond) + "~" + string_format(_m.lost.g, 1, 3)) : "~~";
	return string_format(_m.v, 1, 3) + "~" + string_format(_m.a, 1, 3) + "~" + string_format(_m.e, 1, 3) + "~" + _cl(_m.why) + "~" + _l + "~" + string(_m.pokes) + "~" + string(_m.pday);
}
