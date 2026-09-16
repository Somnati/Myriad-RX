/// @description foe_plural(kind) -> "wolves", "hornets", "harpies", "goblins"
function foe_plural(_k) {
	switch (_k) {
		case "wolf": return "wolves"; case "snow wolf": return "snow wolves";
		case "hornets": return "hornets";
		case "harpy": return "harpies"; case "mummy": return "mummies";
		case "leech": return "leeches";
	}
	return _k + "s";
}
