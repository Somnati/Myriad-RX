/// @description foe_plural(kind) -> "lupi", "vespae", "harpies", "goblins" - the Latin kinds decline, the plain ones take an s
function foe_plural(_k) {
	switch (_k) {
		case "lupus": return "lupi";
		case "snow lupus": return "snow lupi";
		case "apero": return "aperos";
		case "vespae": return "vespae";
		case "aranea": return "araneae";
		case "ursus": return "ursi";
		case "bufo": return "bufones";
		case "hirudo": return "hirudines";
		case "paluster": return "palustres";
		case "vipera": return "viperae";
		case "musca": return "muscae";
		case "scorpio": return "scorpiones";
		case "thos": return "thosos";
		case "mumia": return "mumiae";
		case "capra": return "caprae";
		case "nivalis": return "nivales";
		case "trollus": return "trolli";
		case "vesper": return "vespers";
		case "vermis": return "vermes";
		case "sand vermis": return "sand vermes";
		case "harpy": return "harpies";
		case "leech": return "leeches";
	}
	return _k + "s";
}
