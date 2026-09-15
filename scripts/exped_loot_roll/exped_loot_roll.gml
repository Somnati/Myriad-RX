/// @description exped_loot_roll(trip) -> one find { kind, txt, rar, ... }
/// The biome's table picks the KIND; the destination's rate, leaned by
/// luck, rolls the RARITY through the house ladder (calculate_rarity -
/// the sprites' and the tiles' rung names, so rare means rare
/// everywhere). Materials are three hand-named families for the mock
/// (the tree comes later); the rest are real things the game consumes.
/// @param trip
function exped_loot_roll(_tr) {
	var _d  = _tr.dest;
	var _bi = exped_biomes()[_d.biome];
	var _kind = exped_pick(_bi.loot);
	var _rar  = clamp(calculate_rarity(luck_rate(_d.rate), .3, .03, 800, 8), 0, 7);
	var _ri   = upgrade_rarity_info(_rar);
	switch (_kind) {
		case "mats": {
			var _fam = ["ferrite", "bloom", "glass"][_d.biome mod 3];
			var _n = 1 + irandom(2) + _d.tier;
			return { kind : "mats", rar : _rar, fam : _fam, tier : _d.tier, n : _n,
			         txt : string(_n) + " " + _fam + " (t" + string(_d.tier) + ")", col : _ri.col };
		}
		case "sprite":
			return { kind : "sprite", rar : _rar, txt : "a sprite, asleep", col : _ri.col };
		case "offer":
			return { kind : "offer", rar : _rar, txt : "an upgrade offer (" + _ri.name + ")", col : _ri.col };
		case "charm":
			return { kind : "charm", rar : _rar, txt : "a charm (+1 luck)", col : c_seagreen };
		case "chart":
			return { kind : "chart", rar : _rar, txt : "a chart fragment", col : c_sblue };
		case "gear": {
			// AN ITEM (his pitch, 2026-09-14): a slot kind at random, at the
			// world's level, the rarity rolled above; the finder handles it
			// (exped_room -> sprite_take). txt is rewritten with the outcome
			var _slot = choose("w1", "w2", "armor", "talis");
			var _it = gear_gen(_slot, exped_trip_lv(_tr), _rar, irandom($7fffffff));   // (the region's level)
			return { kind : "gear", rar : _rar, txt : _it.name, col : _it.col, item : _it };
		}
	}
	var _cr = (2 + irandom(3)) * _d.tier * (1 + _rar);
	return { kind : "credits", rar : _rar, n : _cr, txt : string(_cr) + " credits", col : c_lavender };
}
