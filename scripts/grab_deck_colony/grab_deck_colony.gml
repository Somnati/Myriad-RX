/// @description grab_deck_colony() - placeholder abilities for the
/// future colony/civilization layer (city lights, tribute, biomes).
function grab_deck_colony() {

	ability(g.ad_title_colony, "Colony", 0, 0, "", false, false);

	ability(g.ad_cityloans, "City Loans", common, 2,
		"settled cities pay 10%\nmore tribute", false, false);
	ability_flavor("+10%", "tribute", "", -1);

	ability(g.ad_nightshift, "Night Shift", uncommon, 4,
		"night side cities produce\n25% more while dark", false, false);
	ability_flavor("+25%", "night output", "", -1);

	ability(g.ad_census, "Census", common, 1,
		"city populations become\nvisible from orbit", false, false);

	ability(g.ad_terraformer, "Terraformers", epic, 10,
		"biome shifts crawl\ntwice as fast", false, false);
	ability_flavor("x2", "terraform speed", "", -1);

	if (oo) if (a_ == -1) syst_rm_ability.batch_colony = _a;
}
