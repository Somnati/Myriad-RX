/// @description region_name(kind) -> a place name for a node of that kind
/// Rolled from the ambient stream (region_gen seeds it): the planet
/// syllables (letter_get_s_planet) with a suffix by kind for the places
/// people live, "the <adj> <noun>" for dungeons and the wild, "<name>'s
/// camp" for bandits.
function region_name(_kind) {
	// (letter_get_s_planet is gen_name_planet's helper: it reads these off
	// the caller - set them as gen_name_planet does before it calls)
	_name = ""; has_m = false; has_suffix = false; n_type = 0;
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
	// THE WILD (widened 2026-09-15 - "marsh pops up a lot"): a noun of the
	// kind's own family, and one of four shapes - "the <adj> <noun>", "<Name>
	// <noun>", "the <noun> of <Name>", "<Name>'s <noun>"
	var _nouns = [_kind];
	switch (_kind) {
		case "field":     _nouns = ["field", "fields", "meadow", "meadows", "downs", "heath", "pasture", "common", "lea", "grassland"]; break;
		case "forest":    _nouns = ["wood", "woods", "forest", "grove", "thicket", "copse", "weald", "pines", "oaks", "wildwood"]; break;
		case "hills":     _nouns = ["hills", "rise", "knolls", "ridge", "tor", "hollows", "barrows", "slopes"]; break;
		case "marsh":     _nouns = ["marsh", "fen", "fens", "bog", "mire", "moor", "swamp", "wetlands", "reeds"]; break;
		case "mountains": _nouns = ["mountains", "peaks", "crags", "heights", "pass", "spires", "cliffs", "scarp"]; break;
		case "desert":    _nouns = ["desert", "sands", "waste", "flats", "dunes", "dust", "badlands", "scrub"]; break;
		case "tundra":    _nouns = ["tundra", "frost", "snows", "barrens", "whites", "ice fields", "drifts"]; break;
		case "coast":     _nouns = ["shore", "strand", "cove", "cliffs", "bay", "headland", "sands", "beach"]; break;
		case "isle":      _nouns = ["isle", "island", "skerry", "holm", "rock", "key", "reef"]; break;
	}
	var _noun = _nouns[irandom(array_length(_nouns) - 1)];
	var _adj = choose("green", "wide", "long", "dim", "wet", "high", "old", "far", "still", "windy", "lesser", "grey", "black", "white", "red",
	                  "broken", "hollow", "low", "deep", "silent", "bright", "crooked", "thorny", "misty", "burnt", "lonely", "whispering", "sleeping", "bitter", "quiet");
	var _form = random(100);
	if (_form < 45) return "the " + _adj + " " + _noun;
	if (_form < 75) return _up + " " + _noun;
	if (_form < 90) return "the " + _noun + " of " + _up;
	return _up + "'s " + _noun;
}
