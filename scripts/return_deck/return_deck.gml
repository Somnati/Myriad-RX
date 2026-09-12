/// @description return_deck() - write a slot's toggled input back to
/// the matching global. MUST mirror the grab_deck batch order exactly
/// (same entries, same sequence - the cursor is the identity).
/// titles are walked too; a title row's input (3) writes back as 3.
function return_deck() {
	_a = 0;

	// survey
	g.ad_title_survey = return_ability(g.ad_title_survey);
	g.ad_probespeed   = return_ability(g.ad_probespeed);
	g.ad_probespeed2  = return_ability(g.ad_probespeed2);
	g.ad_multiprobe   = return_ability(g.ad_multiprobe);
	g.ad_deepscan     = return_ability(g.ad_deepscan);
	g.ad_autosurvey   = return_ability(g.ad_autosurvey);
	g.ad_signalboost = return_ability(g.ad_signalboost);
	g.ad_orbitalmap = return_ability(g.ad_orbitalmap);
	g.ad_probeswarm = return_ability(g.ad_probeswarm);
	g.ad_coresampler = return_ability(g.ad_coresampler);
	g.ad_geologist = return_ability(g.ad_geologist);

	// fleet
	g.ad_title_fleet = return_ability(g.ad_title_fleet);
	g.ad_warptune    = return_ability(g.ad_warptune);
	g.ad_fuelcells   = return_ability(g.ad_fuelcells);
	g.ad_autopilot   = return_ability(g.ad_autopilot);
	g.ad_deepspace   = return_ability(g.ad_deepspace);
	g.ad_cargohold = return_ability(g.ad_cargohold);
	g.ad_slingshot = return_ability(g.ad_slingshot);
	g.ad_hullplate = return_ability(g.ad_hullplate);
	g.ad_starcharts = return_ability(g.ad_starcharts);
	g.ad_wormhole = return_ability(g.ad_wormhole);

	// tiles
	g.ad_title_tiles  = return_ability(g.ad_title_tiles);
	g.ad_automerger   = return_ability(g.ad_automerger);
	g.ad_automerger2  = return_ability(g.ad_automerger2);
	g.ad_fabricator   = return_ability(g.ad_fabricator);
	g.ad_fabricator2  = return_ability(g.ad_fabricator2);
	g.ad_duplicator   = return_ability(g.ad_duplicator);
	g.ad_tilerarity   = return_ability(g.ad_tilerarity);
	g.ad_hotswap      = return_ability(g.ad_hotswap);
	g.ad_magnet = return_ability(g.ad_magnet);
	g.ad_sorter = return_ability(g.ad_sorter);
	g.ad_smelter = return_ability(g.ad_smelter);
	g.ad_overclock = return_ability(g.ad_overclock);
	g.ad_goldleaf = return_ability(g.ad_goldleaf);

	// colony
	g.ad_title_colony = return_ability(g.ad_title_colony);
	g.ad_cityloans    = return_ability(g.ad_cityloans);
	g.ad_nightshift   = return_ability(g.ad_nightshift);
	g.ad_census       = return_ability(g.ad_census);
	g.ad_terraformer  = return_ability(g.ad_terraformer);
	g.ad_lanterns = return_ability(g.ad_lanterns);
	g.ad_marketday = return_ability(g.ad_marketday);
	g.ad_aqueducts = return_ability(g.ad_aqueducts);
	g.ad_observatory = return_ability(g.ad_observatory);
	g.ad_guilds = return_ability(g.ad_guilds);
	g.ad_capital = return_ability(g.ad_capital);

	// combat
	g.ad_title_combat  = return_ability(g.ad_title_combat);
	g.ad_initiative    = return_ability(g.ad_initiative);
	g.ad_counterschool = return_ability(g.ad_counterschool);
	g.ad_fieldmedic    = return_ability(g.ad_fieldmedic);
	g.ad_warcry        = return_ability(g.ad_warcry);
	g.ad_drillsgt = return_ability(g.ad_drillsgt);
	g.ad_ambush = return_ability(g.ad_ambush);
	g.ad_shieldwall = return_ability(g.ad_shieldwall);
	g.ad_lastword = return_ability(g.ad_lastword);
	g.ad_veterans = return_ability(g.ad_veterans);
	g.ad_ironwill = return_ability(g.ad_ironwill);

	// support
	g.ad_title_support = return_ability(g.ad_title_support);
	g.ad_onefinger     = return_ability(g.ad_onefinger);
	g.ad_autobuy       = return_ability(g.ad_autobuy);
	g.ad_aputilizer    = return_ability(g.ad_aputilizer);
	g.ad_luckcharm     = return_ability(g.ad_luckcharm);
	g.ad_notekeeper    = return_ability(g.ad_notekeeper);
	g.ad_bargain       = return_ability(g.ad_bargain);
	g.ad_deeppockets   = return_ability(g.ad_deeppockets);
	g.ad_scholar       = return_ability(g.ad_scholar);
	g.ad_alarmclock = return_ability(g.ad_alarmclock);
	g.ad_archivist = return_ability(g.ad_archivist);
	g.ad_nightowl = return_ability(g.ad_nightowl);
	g.ad_tinkerer = return_ability(g.ad_tinkerer);
	g.ad_secondwind = return_ability(g.ad_secondwind);

	save_mark_dirty();
}
