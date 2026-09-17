/// @description upgrade_rarity_info(rarity) -> { name, col } - THE ONE
/// RARITY LADDER (his call, 2026-09-17: "fix our rarity system... i want
/// it using tech demo's, as that system is an evolution of myriad's").
/// Fourteen rungs, the house colours from main_macros, the tech demo's
/// order - basic (the dirty one, trash) under common, then the climb:
///   0 basic  1 common  2 uncommon  3 rare  4 epic  5 elite  6 master
///   7 exotic  8 ancient  9 legendary  10 cosmic  11 mythic  12 divine
///   13 ultimate
/// Every rarity in the game reads this: upgrades, sprites, gear, the
/// abilities, the expedition finds. (DE's eight - common .. ultimate with
/// legendary before elite - were the ladder before; rarity_remap8 lifts
/// an old save's indices onto this one.)
function upgrade_rarity_info(_r) {
	static _t = [
		{ name : "basic",     col : c_rarity_basic     },
		{ name : "common",    col : c_rarity_common    },
		{ name : "uncommon",  col : c_rarity_uncommon  },
		{ name : "rare",      col : c_rarity_rare      },
		{ name : "epic",      col : c_rarity_epic      },
		{ name : "elite",     col : c_rarity_elite     },
		{ name : "master",    col : c_rarity_master    },
		{ name : "exotic",    col : c_rarity_exotic    },
		{ name : "ancient",   col : c_rarity_ancient   },
		{ name : "legendary", col : c_rarity_legendary },
		{ name : "cosmic",    col : c_rarity_cosmic    },
		{ name : "mythic",    col : c_rarity_mythic    },
		{ name : "divine",    col : c_rarity_divine    },
		{ name : "ultimate",  col : c_rarity_ultimate  },
	];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
