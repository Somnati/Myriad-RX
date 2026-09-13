/// @description exped_crew_txt(names) -> "Pim" / "Pim and Tok" /
/// "Pim, Tok and Vee" - the crew as prose, for the truth lines
function exped_crew_txt(_n) {
	var _c = array_length(_n);
	if (_c <= 0) return "nobody";
	if (_c == 1) return _n[0];
	var _o = "";
	for (var _i = 0; _i < _c; _i++)
		_o += _n[_i] + ((_i < _c - 2) ? ", " : ((_i == _c - 2) ? " and " : ""));
	return _o;
}
