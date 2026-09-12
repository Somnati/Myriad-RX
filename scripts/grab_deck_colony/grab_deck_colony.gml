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

	// ---- the second half (2026-09-11): made up, unwired placeholders ----
	ability(g.ad_lanterns, "Lanterns", common, 1,
		"city lights reach further\ninto the night side", false, false);

	ability(g.ad_marketday, "Market Day", common, 2,
		"tribute collects 10%\nfaster on the day side", false, false);
	ability_flavor("+10%", "day tribute", "", -1);

	ability(g.ad_aqueducts, "Aqueducts", uncommon, 3,
		"cities grow one size past\nwhat their biome allows", false, false);
	ability_flavor("+1", "city size", "", -1);

	ability(g.ad_observatory, "Observatory", rare, 4,
		"a city with an observatory\nreveals its whole system", false, false);

	ability(g.ad_guilds, "Guilds", rare, 5,
		"settled cities trade with\neach other: +15% tribute", false, false);
	ability_flavor("+15%", "tribute", "", -1);

	ability(g.ad_capital, "Capital", legendary, 8,
		"name one city the capital:\nit pays double", false, false);
	ability_flavor("x2", "capital tribute", "", -1);

	if (oo) if (a_ == -1) syst_rm_ability.batch_colony = _a;
}
