/// @description star_kind_word(skind, [short]) -> the plain words for a star's kind: "a red giant" / "red giant" (short) - the cards, the labels, the captions (q265)
function star_kind_word(_skind, _short = false) {
	var _w = "star";
	switch (_skind) {
		case "giant":   _w = "red giant"; break;
		case "dwarf":   _w = "white dwarf"; break;
		case "pulsar":  _w = "pulsar"; break;
		case "hole":    _w = "black hole"; break;
		case "brown":   _w = "brown dwarf"; break;
		case "wolf":    _w = "wolf-rayet star"; break;
		case "cepheid": _w = "cepheid"; break;
		case "proto":   _w = "protostar"; break;
		default:        _w = "main-sequence star"; break;
	}
	if (_short) return _w;
	return ((string_char_at(_w, 1) == "a" || string_char_at(_w, 1) == "e" || string_char_at(_w, 1) == "i" || string_char_at(_w, 1) == "o" || string_char_at(_w, 1) == "u") ? "an " : "a ") + _w;
}
