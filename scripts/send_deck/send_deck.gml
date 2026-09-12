/// @description send_deck() - list every ability's discovery
/// eligibility (the pool builder). sub-abilities pass their parent
/// so chains discover in order. keep in sync with the batches.
function send_deck() {

	// survey
	send_ability("ad_probespeed",  g.ad_probespeed);
	send_ability("ad_probespeed2", g.ad_probespeed2, g.ad_probespeed);
	send_ability("ad_multiprobe",  g.ad_multiprobe);
	send_ability("ad_deepscan",    g.ad_deepscan);
	send_ability("ad_autosurvey",  g.ad_autosurvey);
	send_ability("ad_signalboost", g.ad_signalboost);
	send_ability("ad_orbitalmap", g.ad_orbitalmap);
	send_ability("ad_probeswarm", g.ad_probeswarm);
	send_ability("ad_coresampler", g.ad_coresampler);
	send_ability("ad_geologist", g.ad_geologist);

	// fleet
	send_ability("ad_warptune",  g.ad_warptune);
	send_ability("ad_fuelcells", g.ad_fuelcells);
	send_ability("ad_autopilot", g.ad_autopilot);
	send_ability("ad_deepspace", g.ad_deepspace);
	send_ability("ad_cargohold", g.ad_cargohold);
	send_ability("ad_slingshot", g.ad_slingshot);
	send_ability("ad_hullplate", g.ad_hullplate);
	send_ability("ad_starcharts", g.ad_starcharts);
	send_ability("ad_wormhole", g.ad_wormhole);

	// tiles
	send_ability("ad_automerger",  g.ad_automerger);
	send_ability("ad_automerger2", g.ad_automerger2, g.ad_automerger);
	send_ability("ad_fabricator",  g.ad_fabricator);
	send_ability("ad_fabricator2", g.ad_fabricator2, g.ad_fabricator);
	send_ability("ad_duplicator",  g.ad_duplicator);
	send_ability("ad_tilerarity",  g.ad_tilerarity);
	send_ability("ad_hotswap",     g.ad_hotswap);
	send_ability("ad_magnet", g.ad_magnet);
	send_ability("ad_sorter", g.ad_sorter);
	send_ability("ad_smelter", g.ad_smelter);
	send_ability("ad_overclock", g.ad_overclock);
	send_ability("ad_goldleaf", g.ad_goldleaf);

	// colony
	send_ability("ad_cityloans",   g.ad_cityloans);
	send_ability("ad_nightshift",  g.ad_nightshift);
	send_ability("ad_census",      g.ad_census);
	send_ability("ad_terraformer", g.ad_terraformer);
	send_ability("ad_lanterns", g.ad_lanterns);
	send_ability("ad_marketday", g.ad_marketday);
	send_ability("ad_aqueducts", g.ad_aqueducts);
	send_ability("ad_observatory", g.ad_observatory);
	send_ability("ad_guilds", g.ad_guilds);
	send_ability("ad_capital", g.ad_capital);

	// combat
	send_ability("ad_initiative",    g.ad_initiative);
	send_ability("ad_counterschool", g.ad_counterschool);
	send_ability("ad_fieldmedic",    g.ad_fieldmedic);
	send_ability("ad_warcry",        g.ad_warcry);
	send_ability("ad_drillsgt", g.ad_drillsgt);
	send_ability("ad_ambush", g.ad_ambush);
	send_ability("ad_shieldwall", g.ad_shieldwall);
	send_ability("ad_lastword", g.ad_lastword);
	send_ability("ad_veterans", g.ad_veterans);
	send_ability("ad_ironwill", g.ad_ironwill);

	// support
	send_ability("ad_onefinger",  g.ad_onefinger);
	send_ability("ad_autobuy",    g.ad_autobuy);
	send_ability("ad_aputilizer", g.ad_aputilizer);
	send_ability("ad_luckcharm",  g.ad_luckcharm);
	send_ability("ad_notekeeper", g.ad_notekeeper);
	send_ability("ad_bargain",     g.ad_bargain);
	send_ability("ad_deeppockets", g.ad_deeppockets);
	send_ability("ad_scholar",     g.ad_scholar);
	send_ability("ad_alarmclock", g.ad_alarmclock);
	send_ability("ad_archivist", g.ad_archivist);
	send_ability("ad_nightowl", g.ad_nightowl);
	send_ability("ad_tinkerer", g.ad_tinkerer);
	send_ability("ad_secondwind", g.ad_secondwind);
}
