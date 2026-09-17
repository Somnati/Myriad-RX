/// @description exped_loot_roll(trip) -> one find { kind, txt, rar, ... }
/// The biome's table picks the KIND; the destination's rate, leaned by
/// luck, rolls the RARITY through the house ladder (calculate_rarity -
/// the sprites' and the tiles' rung names, so rare means rare
/// everywhere). Materials are three hand-named families for the mock
/// (the tree comes later); the rest are real things the game consumes.
/// @param trip
function exped_loot_roll(_tr) {
	static _rgl_lv = function(_tr2) { return exped_trip_lv(_tr2); };
	var _d  = _tr.dest;
	var _bi = exped_biomes()[_d.biome];
	// FOR NOW (his call, 2026-09-15): credits or gear for the sprites, nothing else
	var _rar  = clamp(calculate_rarity(luck_rate(_d.rate) + (exped_party_luck(_tr) + exped_party_ab(_tr).loot) * 12, .3, .03, 800, 14), 0, 13);   // (treasure sense leans it like luck - 2026-09-17)
	var _ri   = upgrade_rarity_info(_rar);
	// gear, a potion, A TREASURE (2026-09-17), an elixir (epic and up), or credits (the consumables pass, 2026-09-16)
	var _kr = random(100), _kind = "credits";
	if (_kr < 30) _kind = "gear"; else if (_kr < 50) _kind = "use"; else if (_kr < 68) _kind = "treasure"; else if (_kr < 74 && _rar >= 4) _kind = "elixir";
	if (_kind == "treasure") { var _tit = treasure_gen(irandom($7fffffff), _rar, _d.tier); return { kind : "gear", rar : _rar, txt : _tit.name, col : _tit.col, item : _tit }; }   // (rides the gear's lane: the finder pockets it)
	// THE EGGS (his ask, 2026-09-16): now and then, in the credits' lane, a warm egg - carried home, it hatches a sprite (exped_tick)
	if (_kind == "credits" && random(100) < EXPED_EGG_CHANCE) _kind = "egg";
	if (_kind == "use" || _kind == "elixir") {
		// (a consumable rides the gear's lane: the finder handles it - sprite_take pockets a potion and drinks an elixir on the spot)
		var _cit = (_kind == "elixir") ? use_gen("elixir", 1, _rgl_lv(_tr), choose("hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit", "luck"))
		                               : use_gen(potion_pick(_rar), (_rar >= 3 && random(1) < .5) ? 2 : 1, _rgl_lv(_tr));   // (the roster, by the find's rung - 2026-09-17)   // (epic / rare on the fourteen-rung ladder)
		return { kind : "gear", rar : (_kind == "elixir") ? max(_rar, 5) : _rar, txt : _cit.name, col : _cit.col, item : _cit };
	}
	switch (_kind) {
		case "mats": {
			var _fam = ["ferrite", "bloom", "glass"][_d.biome mod 3];
			var _n = 1 + irandom(2) + _d.tier;
			return { kind : "mats", rar : _rar, fam : _fam, tier : _d.tier, n : _n,
			         txt : string(_n) + " " + _fam + " (t" + string(_d.tier) + ")", col : _ri.col };
		}
		case "sprite":
			return { kind : "sprite", rar : _rar, txt : "a sprite, asleep", col : _ri.col };
		case "egg": {
			// the egg's colour is the sprite's to come (the sprites' own palette law); its seed rides in tier, its colour in n (the pack's lanes)
			var _ehue = irandom(255), _ecol = make_colour_hsv(_ehue, irandom_range(150, 220), irandom_range(225, 255)), _eseed = irandom(999999);
			var _ew = egg_word(_ehue, _eseed);
			return { kind : "egg", rar : max(_rar, 2), n : _ecol, fam : _ew, tier : _eseed, txt : "a " + _ew + " egg, warm", col : _ecol };
		}
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
			var _rgl = exped_region(_tr), _tagl = _rgl.nodes[clamp(_tr[$ "pos"] ?? 0, 0, array_length(_rgl.nodes) - 1)].kind;   // (tagged by the place - the proc-gear pass)
			var _it = gear_gen(_slot, exped_trip_lv(_tr), _rar, irandom($7fffffff), _tagl);   // (the region's level)
			return { kind : "gear", rar : _rar, txt : _it.name, col : _it.col, item : _it };
		}
	}
	var _cr = (2 + irandom(3)) * _d.tier * (1 + _rar);
	return { kind : "credits", rar : _rar, n : _cr, txt : string(_cr) + " credits", col : c_lavender };
}
#macro EXPED_EGG_CHANCE 7   // THE EGGS (2026-09-16): of the finds that would be credits, this % are a warm egg (a sprite, hatched at home)
