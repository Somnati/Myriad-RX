/// @description pop_word(pp) -> { txt, col } a place's population as a phrase for a card (q284): "about 1,240 - rising / falling / steady", the deviation's word when it is large
function pop_word(_pp) {
	if (!is_struct(_pp)) return { txt : "", col : c_white };
	var _s = string(_pp.pop), _o = "", _l = string_length(_s);
	for (var _i = 1; _i <= _l; _i++) { _o += string_char_at(_s, _i); if (_i < _l && ((_l - _i) mod 3) == 0) _o += ","; }
	var _tw = (_pp.trend > 0) ? "rising" : ((_pp.trend < 0) ? "falling" : "steady");
	var _dw = (_pp.dev < -.15) ? " (emptied lately)" : ((_pp.dev < -.05) ? " (thinned lately)" : ((_pp.dev > .08) ? " (swelled lately)" : ""));
	return { txt : "about " + _o + " - " + _tw + _dw, col : (_pp.dev < -.05) ? c_horange : ((_pp.trend > 0) ? c_seagreen : c_white) };
}
