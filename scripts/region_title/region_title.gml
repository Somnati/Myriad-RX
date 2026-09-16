/// @description region_title(kind) -> the REGION's name, off the land it mostly is (its dominant wild kind)
/// THE REGION-NAMES PASS (2026-09-15): rolled from the ambient stream
/// (region_gen seeds it) - a Name off the planet syllables, a LAND WORD
/// off the kind's own pool (fens / marches / mires for a marsh, wastes /
/// sands / badlands for a desert, reach / vale / downs / weald for the
/// green), and one of nine shapes:
///   the grey fens / Orrin fens / the fens of Orrin / Bel's downs /
///   Orrinshire / the seven dales / the red country / the low fens of
///   Ashby / Orrin beyond the fens
function region_title(_kind) {
	_name = ""; has_m = false; has_suffix = false; n_type = 0;
	letter_get_s_planet();
	var _base = _name;
	if (string_length(_base) < 2) _base = choose("or", "el", "an", "ur", "ash", "bel", "tor");
	var _up = string_upper(string_char_at(_base, 1)) + string_delete(_base, 1, 1);
	var _land;
	switch (_kind) {
		case "field":     _land = ["reach", "vale", "shire", "downs", "meadowlands", "greens", "lea", "commons", "dales", "pastures", "lowlands", "flats"]; break;
		case "forest":    _land = ["woods", "weald", "wildwood", "forest", "wold", "groves", "greenwood", "holt", "timberlands", "shades"]; break;
		case "hills":     _land = ["uplands", "highlands", "downs", "ridges", "tors", "hill country", "knolls", "rises", "wolds", "hollows"]; break;
		case "marsh":     _land = ["fens", "marches", "mires", "moors", "wetlands", "bogs", "levels", "sedges", "reedlands", "sloughs", "washes"]; break;
		case "desert":    _land = ["wastes", "sands", "flats", "badlands", "dunes", "drylands", "barrens", "pans", "scrublands", "reaches", "dust"]; break;
		case "mountains": _land = ["heights", "passes", "crags", "peaks", "high country", "spires", "scarps", "fells", "shoulders"]; break;
		case "coast":     _land = ["shores", "strand", "coast", "bays", "headlands", "littoral", "sea-marches", "sands", "reaches", "salt-lands"]; break;
		case "tundra":    _land = ["snows", "frosts", "whites", "barrens", "ice fields", "cold reach", "frostlands", "wastes"]; break;
		case "isle":      _land = ["isles", "skerries", "keys", "reefs", "sounds"]; break;
		default:          _land = ["reach", "lands", "country", "march", "holds", "lowlands", "borders"]; break;
	}
	var _lw = _land[irandom(array_length(_land) - 1)];
	var _adj = choose("green", "wide", "long", "far", "near", "low", "high", "old", "grey", "red", "white", "black", "quiet", "broken", "hollow", "sunken",
	                  "windy", "misty", "still", "bitter", "wild", "lost", "lesser", "greater", "outer", "inner", "upper", "lower", "north", "south",
	                  "east", "west", "middle", "lonely", "fair", "burnt", "drowned", "singing", "sleeping", "crooked", "sunny", "sodden", "dry", "blessed");
	var _form = random(100);
	if (_form < 22) return "the " + _adj + " " + _lw;
	if (_form < 40) return _up + " " + _lw;
	if (_form < 52) return "the " + _lw + " of " + _up;
	if (_form < 60) return _up + "'s " + _lw;
	if (_form < 72) return _up + choose("shire", "land", "mark", "wold", "moor", "fold", "reach", "dale", "combe", "holm");
	if (_form < 80) return "the " + choose("three", "five", "seven", "nine", "twelve", "hundred") + " " + _lw;
	if (_form < 88) return "the " + choose("grey", "green", "red", "white", "black", "gold", "brown", "blue", "silver", "amber") + " country";
	if (_form < 94) return "the " + _adj + " " + _lw + " of " + _up;
	return _up + " " + choose("under", "over", "beyond", "by", "before") + " the " + _lw;
}
