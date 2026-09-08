/// @description upgrade_rarity_info(rarity);
/// @param rarity
/// A RUNG'S NAME AND COLOUR, in one place, so the upgrade screen and
/// the statistics page cannot disagree about what a rarity is called.
///
/// THE ORDER IS DE'S UPGRADE ORDER, and it is worth being exact about
/// which ladder that is, because DE has TWO. calculate_rarity - the
/// engine the tech demo's rarity bar was built on - runs fourteen rungs
/// (basic common uncommon rare epic ELITE master exotic ancient
/// LEGENDARY cosmic mythic divine ultimate) and drives gear and tiles.
/// roll_upgrade declares its own eight for the upgrade table:
///
///     common uncommon rare epic LEGENDARY ELITE divine ultimate
///
/// with legendary BELOW elite - the reverse of the gear ladder. RX's
/// upgrade table follows this one, because it is the upgrade table.
/// Colours still come from the shared palette in main_macros, so a word
/// looks the same wherever the game uses it.
function upgrade_rarity_info(_r) {
	var _t = [
		{ name : "common",    col : c_rarity_common    },
		{ name : "uncommon",  col : c_rarity_uncommon  },
		{ name : "rare",      col : c_rarity_rare      },
		{ name : "epic",      col : c_rarity_epic      },
		{ name : "legendary", col : c_rarity_legendary },
		{ name : "elite",     col : c_rarity_elite     },
		{ name : "divine",    col : c_rarity_divine    },
		{ name : "ultimate",  col : c_rarity_ultimate  },
	];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
