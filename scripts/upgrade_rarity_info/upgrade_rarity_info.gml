/// @description upgrade_rarity_info(rarity);
/// @param rarity
/// A RUNG'S NAME AND COLOUR, in one place, so the upgrade screen and
/// the statistics page cannot disagree about what a rarity is called.
/// Both carried private copies in their own Create events, which is
/// exactly how a ladder ends up existing in two different orders.
///
/// THE ORDER IS DE'S ORDER. Myriad DE's rarity ladder runs
///   basic common uncommon rare epic elite master exotic ancient
///   legendary cosmic mythic divine ultimate
/// and RX already carries that whole palette in main_macros. Our seven
/// rungs are a SUBSET of it in DE's order - so elite sits BELOW
/// legendary, where the upgrade screen's first cut had the two of them
/// swapped. `tier` is the rung's index on DE's full ladder, which is
/// why the colour here is the same colour the rest of the game gives
/// that word rather than a seventh palette invented for one screen.
///
/// Only the NAMES moved. upgrade_rarity_mult is indexed by our own
/// 0..6 and is untouched, so no saved roll and no price changed
/// meaning - rung 4 is worth exactly what it was worth, it is just
/// called elite now instead of legendary.
function upgrade_rarity_info(_r) {
	var _t = [
		{ name : "common",    col : c_rarity_common,    tier : 1  },
		{ name : "uncommon",  col : c_rarity_uncommon,  tier : 2  },
		{ name : "rare",      col : c_rarity_rare,      tier : 3  },
		{ name : "epic",      col : c_rarity_epic,      tier : 4  },
		{ name : "elite",     col : c_rarity_elite,     tier : 5  },
		{ name : "legendary", col : c_rarity_legendary, tier : 9  },
		{ name : "ultimate",  col : c_rarity_ultimate,  tier : 13 },
	];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
