/// @description potion_config() -> THE POTIONS (his ask, 2026-09-17: "a bunch
/// of random potions"): every consumable a crew can carry - what it is
/// called, its colour, its draw weight in a find, the find rarity it
/// starts at, its shop price, WHEN it is drunk (the crew drinks by itself,
/// exped_drink and its kin) and the popup's line. `big` names the size-2
/// one (the red and the blue only). Kinds: hp / mp / tonic / antidote /
/// mystery (drunk when low) / strength / stoneskin / haste / clarity /
/// regen / the three wards / growth (at a fight's door - exped_drink_open)
/// / owl (the first dark hour) / fortune (the first room of a delve -
/// exped_drink_road) / phoenix / totem (fallen). use_gen reads it,
/// gear_desc quotes it, potion_pick draws from it.
function potion_config() {
	static _c = [
		{ key : "hp", name : "red potion", big : "big red potion", col : c_hred, w : 30, rar : 0, price : 1, when : "low", help : "a red potion: four tenths of the hp back. drunk when low - the nervous early, the brave late, the greedy at the last moment, the dreamy forget it.", bighelp : "a big red potion: eight tenths of the hp back. drunk when it is bad, by whoever carries it." },
		{ key : "mp", name : "blue potion", big : "big blue potion", col : c_sblue, w : 12, rar : 0, price : 1, when : "mp", help : "a blue potion: half the mp back, drunk in a fight when the mp is short of a skill.", bighelp : "a big blue potion: all the mp back, drunk in a fight when the mp is short of a skill." },
		{ key : "tonic", name : "tonic", big : "", col : c_sgreen, w : 8, rar : 0, price : 2, when : "hazard", help : "a tonic: drunk at the door of a fight under a hazard the carrier has nothing else against. holds the hazard for that fight.", bighelp : "" },
		{ key : "antidote", name : "antidote", big : "", col : rgb(120, 220, 120), w : 8, rar : 0, price : 2, when : "ailing", help : "an antidote: drunk in a fight the moment the carrier is poisoned, slowed or marked. all three off.", bighelp : "" },
		{ key : "mystery", name : "a bottle of something", big : "", col : c_hpurple, w : 6, rar : 0, price : 1, when : "low", help : "a bottle of something. drunk when low and there is no red one. usually good.", bighelp : "" },
		{ key : "strength", name : "potion of strength", big : "", col : c_horange, w : 5, rar : 2, price : 3, when : "open", help : "a potion of strength: drunk walking into a fight with a titled foe or a pack of three - the carrier's atk raised for a while.", bighelp : "" },
		{ key : "stoneskin", name : "potion of stone skin", big : "", col : rgb(150, 150, 160), w : 5, rar : 2, price : 3, when : "open", help : "a potion of stone skin: drunk walking into a fight with a titled foe or a pack of three - the carrier's def raised for a while.", bighelp : "" },
		{ key : "haste", name : "potion of haste", big : "", col : rgb(255, 230, 90), w : 5, rar : 2, price : 3, when : "open", help : "a potion of haste: drunk walking into a fight with a titled foe or a pack of three - the carrier hastened for a while.", bighelp : "" },
		{ key : "clarity", name : "potion of clarity", big : "", col : c_white, w : 5, rar : 2, price : 3, when : "open", help : "a potion of clarity: drunk walking into a fight with a titled foe or a pack of three - the carrier's hit raised for a while.", bighelp : "" },
		{ key : "regen", name : "potion of regeneration", big : "", col : c_pink, w : 5, rar : 2, price : 3, when : "open", help : "a potion of regeneration: drunk walking into a fight under six tenths of hp - the carrier mends a little every action for a while.", bighelp : "" },
		{ key : "fireward", name : "fireward draught", big : "", col : cbt_elem_info("fire").col, w : 3, rar : 3, price : 3, when : "open", help : "a fireward draught: drunk walking into a fight with a fire foe - +30 fire res for that fight.", bighelp : "" },
		{ key : "waterward", name : "waterward draught", big : "", col : cbt_elem_info("water").col, w : 3, rar : 3, price : 3, when : "open", help : "a waterward draught: drunk walking into a fight with a water foe - +30 water res for that fight.", bighelp : "" },
		{ key : "thornward", name : "thornward draught", big : "", col : cbt_elem_info("nature").col, w : 3, rar : 3, price : 3, when : "open", help : "a thornward draught: drunk walking into a fight with a nature foe - +30 nature res for that fight.", bighelp : "" },
		{ key : "owl", name : "owl's eye potion", big : "", col : rgb(120, 110, 220), w : 3, rar : 3, price : 3, when : "night", help : "an owl's eye potion: drunk at the first dark hour of a trip - the night costs the crew nothing for the rest of it.", bighelp : "" },
		{ key : "fortune", name : "potion of fortune", big : "", col : c_gold, w : 3, rar : 3, price : 4, when : "delve", help : "a potion of fortune: drunk at the first room of a delve - three luck to the crew for the rest of the trip.", bighelp : "" },
		{ key : "growth", name : "potion of growth", big : "", col : rgb(170, 230, 80), w : 3, rar : 3, price : 4, when : "open", help : "a potion of growth: drunk walking into a fight with a titled foe - twice the xp from it.", bighelp : "" },
		{ key : "phoenix", name : "phoenix draught", big : "", col : rgb(255, 150, 60), w : 4, rar : 5, price : 6, when : "fallen", help : "a phoenix draught: a carrier who falls stands up at three tenths, and the bottle is ash. one use. the totem goes first.", bighelp : "" },
		{ key : "totem", name : "totem of don't die", big : "", col : c_gold, w : 6, rar : 4, price : 6, when : "fallen", help : "the totem of don't die. a carrier who falls stands up at half hp, and the totem cracks. one use. keep it in the pocket.", bighelp : "" },
	];
	return _c;
}
