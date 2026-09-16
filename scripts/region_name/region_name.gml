/// @description region_name(kind) -> a place name for a node of that kind
/// Rolled from the ambient stream (region_gen seeds it): the planet
/// syllables (letter_get_s_planet) with a suffix by kind for the places
/// people live, shapes of their own for camps, dungeons, crypts, ruins,
/// shrines and mines, and "the <adj> <noun>" and its cousins for the wild.
/// THE NODE-NAMES PASS (2026-09-15): every kind has several shapes now,
/// and the pools are twice the size.
function region_name(_kind) {
	// (letter_get_s_planet is gen_name_planet's helper: it reads these off
	// the caller - set them as gen_name_planet does before it calls)
	_name = ""; has_m = false; has_suffix = false; n_type = 0;
	letter_get_s_planet();
	var _base = _name;
	if (string_length(_base) < 2) _base = choose("or", "el", "an", "ur", "ash", "bel", "tor", "wen");
	var _up = string_upper(string_char_at(_base, 1)) + string_delete(_base, 1, 1);
	var _f = random(100);
	switch (_kind) {
		case "settlement":
			if (_f < 70) return _up + choose("stead", "ford", "wick", "holm", "by", "thorpe", "cott", "croft", "hythe", "stoke", "wich", "sett");
			if (_f < 85) return choose("Little ", "Nether ", "Upper ", "Long ") + _up + choose("stead", "cott", "by", "croft");
			return _up + choose("'s farm", "'s croft", " crossing", " end");
		case "village":
			if (_f < 70) return _up + choose("bury", "ley", "dale", "combe", "worth", "ham", "ing", "well", "field", "bourne", "den", "hurst");
			if (_f < 85) return choose("Little ", "Great ", "Old ", "New ", "West ", "East ") + _up + choose("ham", "ley", "worth", "bury");
			return _up + choose(" green", " cross", " hollow", "'s well", " lane");
		case "town":
			if (_f < 65) return _up + choose("ton", "mouth", "bridge", "market", "haven", "chester", "borough", "cross", "gate", "port", "wick", "bury");
			if (_f < 85) return _up + choose(" market", " bridge", " ford", " ferry", " cross", " town");
			return choose("Market ", "Bishop's ", "King's ", "Old ", "High ") + _up + choose("ton", "bridge", "borough");
		case "city":
			if (_f < 55) return choose("Great ", "High ", "Old ", "Royal ", "") + _up + choose("gard", "haven", "minster", "keep", "burgh", "castle", "hold", "spire");
			if (_f < 80) return "the city of " + _up;
			return _up + choose(" the Golden", " the Grey", " the Walled", " of the Towers", " the Old");
		case "camp":
			if (_f < 45) return _up + choose("'s camp", "'s hollow", "'s lot", "'s boys", "'s band", "'s den");
			if (_f < 70) return "the " + choose("bandits'", "outlaws'", "reavers'", "cutthroats'", "robbers'") + " " + choose("camp", "hollow", "roost", "hideout", "rest");
			if (_f < 85) return "the camp " + choose("at the ford", "under the hill", "in the thorns", "by the dead tree", "on the ridge", "at the crossroads");
			return choose("Redhand", "Blackcoat", "Greycloak", "Longknife", "Broken Tooth", "Sixfinger") + choose(" camp", " hollow", " rest");
		case "dungeon":
			if (_f < 50) return "the " + choose("sunken", "weeping", "howling", "quiet", "black", "old", "nameless", "hungry", "dripping", "low", "forgotten", "gnawed", "burrowed", "crooked", "bottomless", "cold")
			                        + " " + choose("cave", "hollow", "barrow", "pit", "warren", "lair", "deep", "delve", "burrow", "undercroft", "cavern", "hole");
			if (_f < 70) return _up + choose("'s barrow", "'s deep", "'s hollow", "'s warren", "'s pit");
			if (_f < 85) return "the " + choose("deep", "hollow", "barrow", "warren", "caves") + " under " + _up;
			return "the " + choose("cave", "hole", "pit", "lair") + " of the " + choose("worm", "goblins", "rats", "hundred eyes", "lost", "wolf", "old king", "slime");
		case "crypt":
			if (_f < 40) return "the " + choose("old", "cold", "silent", "sealed", "weeping", "broken", "sunken", "grey", "lower", "forgotten")
			                        + " " + choose("crypt", "tomb", "catacombs", "ossuary", "vault", "sepulchre", "bone house", "mausoleum");
			if (_f < 65) return "the " + choose("crypt", "tomb", "vault", "rest", "catacombs") + " of " + _up;
			if (_f < 85) return _up + choose("'s rest", "'s tomb", "'s vault", "'s bones");
			return "the " + choose("tomb", "crypt", "barrow") + " of the " + choose("nine kings", "drowned priest", "unnamed", "last abbot", "sleeping knight", "quiet ones");
		case "ruin":
			if (_f < 40) return "the ruins of " + _up + choose("gard", "ton", "stead", "keep", "hall", "minster");
			if (_f < 65) return "old " + _up + choose("gard", "keep", "hall", "tower", "bridge");
			if (_f < 85) return "the " + choose("broken", "fallen", "roofless", "tumbled", "burnt", "hollow", "leaning") + " " + choose("tower", "hall", "keep", "abbey", "mill", "manor", "gate", "wall");
			return _up + choose("'s fall", "'s folly", "'s stones", "'s end");
		case "shrine":
			if (_f < 40) return "the shrine of " + _up;
			if (_f < 60) return "the " + choose("wayside", "hilltop", "hidden", "little", "mossy", "roadside", "old", "quiet") + " shrine";
			if (_f < 80) return _up + choose("'s stone", "'s well", "'s cross", "'s tree");
			return "the shrine of the " + choose("wanderer", "lost", "three", "small god", "hedge", "river", "patient", "kind");
		case "mine":
			if (_f < 40) return "the " + _up + " mine";
			if (_f < 60) return _up + choose(" pit", " delvings", " workings", " shafts", " diggings");
			if (_f < 80) return "the " + choose("old", "deep", "flooded", "north", "lower", "upper", "rich", "abandoned") + " " + choose("mine", "workings", "pit", "shaft", "seam");
			return "the " + choose("iron", "copper", "salt", "tin", "silver", "glass", "coal") + " " + choose("mine", "pit", "workings");
		case "landing":    return "the landing zone";
	}
	// THE WILD (widened 2026-09-15 - "marsh pops up a lot"): a noun of the
	// kind's own family, and one of six shapes - "the <adj> <noun>", "<Name>
	// <noun>", "the <noun> of <Name>", "<Name>'s <noun>", "Little <Name>
	// <noun>", "<noun>'s end"
	var _nouns = [_kind];
	switch (_kind) {
		case "field":     _nouns = ["field", "fields", "meadow", "meadows", "downs", "heath", "pasture", "common", "lea", "grassland", "green", "flats", "plain"]; break;
		case "forest":    _nouns = ["wood", "woods", "forest", "grove", "thicket", "copse", "weald", "pines", "oaks", "wildwood", "holt", "shaw", "brake"]; break;
		case "hills":     _nouns = ["hills", "rise", "knolls", "ridge", "tor", "hollows", "barrows", "slopes", "downs", "brae", "howe", "edge"]; break;
		case "marsh":     _nouns = ["marsh", "fen", "fens", "bog", "mire", "moor", "swamp", "wetlands", "reeds", "slough", "wash", "carr", "sump"]; break;
		case "mountains": _nouns = ["mountains", "peaks", "crags", "heights", "pass", "spires", "cliffs", "scarp", "fell", "shoulder", "needle", "saddle"]; break;
		case "desert":    _nouns = ["desert", "sands", "waste", "flats", "dunes", "dust", "badlands", "scrub", "pan", "salt", "reach", "bones"]; break;
		case "tundra":    _nouns = ["tundra", "frost", "snows", "barrens", "whites", "ice fields", "drifts", "floe", "cold", "white"]; break;
		case "coast":     _nouns = ["shore", "strand", "cove", "cliffs", "bay", "headland", "sands", "beach", "point", "spit", "ness", "sound"]; break;
		case "isle":      _nouns = ["isle", "island", "skerry", "holm", "rock", "key", "reef", "eyot", "sandbank"]; break;
	}
	var _noun = _nouns[irandom(array_length(_nouns) - 1)];
	var _adj = choose("green", "wide", "long", "dim", "wet", "high", "old", "far", "still", "windy", "lesser", "grey", "black", "white", "red",
	                  "broken", "hollow", "low", "deep", "silent", "bright", "crooked", "thorny", "misty", "burnt", "lonely", "whispering", "sleeping", "bitter", "quiet",
	                  "singing", "sunken", "wild", "lost", "blue", "golden", "haunted", "gentle", "howling", "narrow", "open", "crooked", "salt", "sour", "sweet", "dry");
	var _form = random(100);
	if (_form < 38) return "the " + _adj + " " + _noun;
	if (_form < 62) return _up + " " + _noun;
	if (_form < 76) return "the " + _noun + " of " + _up;
	if (_form < 86) return _up + "'s " + _noun;
	if (_form < 94) return choose("Little ", "Great ", "Long ", "Far ") + _up + " " + _noun;
	return _noun + "'s end";
}
