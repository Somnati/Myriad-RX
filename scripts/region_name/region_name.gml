/// @description region_name(kind) -> a place name for a node of that kind
/// Rolled from the ambient stream (region_gen seeds it): the planet
/// syllables (letter_get_s_planet) with a suffix by kind for the places
/// people live, "the <adj> <noun>" for dungeons and the wild, "<name>'s
/// camp" for bandits.
function region_name(_kind) {
	_name = "";
	letter_get_s_planet();
	var _base = _name;
	if (string_length(_base) < 2) _base = choose("or", "el", "an", "ur", "ash");
	var _up = string_upper(string_char_at(_base, 1)) + string_delete(_base, 1, 1);
	switch (_kind) {
		case "settlement": return _up + choose("stead", "ford", "wick", "holm", "by", "thorpe", "cott");
		case "village":    return _up + choose("bury", "ley", "dale", "combe", "worth", "ham");
		case "town":       return _up + choose("ton", "mouth", "bridge", "market", "haven");
		case "city":       return choose("Great ", "High ", "Old ") + _up + choose("gard", "haven", "minster", "keep");
		case "camp":       return _up + choose("'s camp", "'s hollow", "'s lot");
		case "dungeon":    return "the " + choose("sunken", "weeping", "howling", "quiet", "black", "old", "nameless", "hungry", "dripping", "low")
		                        + " " + choose("cave", "hollow", "barrow", "pit", "crypt", "warren", "tomb", "lair", "deep");
		case "ruin":       return "the ruins of " + _up + choose("gard", "ton", "stead");
		case "shrine":     return "the shrine of " + _up;
		case "mine":       return "the " + _up + " mine";
		case "landing":    return "the landing zone";
	}
	// the wild: "the <adj> <kind>"
	return "the " + choose("green", "wide", "long", "dim", "wet", "high", "old", "far", "still", "windy", "lesser", "grey") + " " + _kind;
}
