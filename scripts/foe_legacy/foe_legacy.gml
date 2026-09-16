/// @description foe_legacy(kind) -> the kind's key today: a save from before the Latin forms (2026-09-16) names "wolf" where the roster says "lupus"
function foe_legacy(_k) {
	switch (_k) {
		case "wolf": return "lupus";
		case "boar": return "apero";
		case "hornets": return "vespae";
		case "spider": return "aranea";
		case "bear": return "ursus";
		case "toad": return "bufo";
		case "leech": return "hirudo";
		case "bogling": return "paluster";
		case "snake": return "vipera";
		case "fly": return "musca";
		case "scorpion": return "scorpio";
		case "jackal": return "thos";
		case "mummy": return "mumia";
		case "goat": return "capra";
		case "yeti": return "nivalis";
		case "snow wolf": return "snow lupus";
		case "troll": return "trollus";
		case "bat": return "vesper";
		case "sandworm": return "sand vermis";
	}
	return _k;
}
