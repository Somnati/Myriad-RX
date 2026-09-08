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

	// fleet
	send_ability("ad_warptune",  g.ad_warptune);
	send_ability("ad_fuelcells", g.ad_fuelcells);
	send_ability("ad_autopilot", g.ad_autopilot);
	send_ability("ad_deepspace", g.ad_deepspace);

	// tiles
	send_ability("ad_automerger",  g.ad_automerger);
	send_ability("ad_automerger2", g.ad_automerger2, g.ad_automerger);
	send_ability("ad_fabricator",  g.ad_fabricator);
	send_ability("ad_fabricator2", g.ad_fabricator2, g.ad_fabricator);
	send_ability("ad_duplicator",  g.ad_duplicator);
	send_ability("ad_tilerarity",  g.ad_tilerarity);
	send_ability("ad_hotswap",     g.ad_hotswap);

	// colony
	send_ability("ad_cityloans",   g.ad_cityloans);
	send_ability("ad_nightshift",  g.ad_nightshift);
	send_ability("ad_census",      g.ad_census);
	send_ability("ad_terraformer", g.ad_terraformer);

	// combat
	send_ability("ad_initiative",    g.ad_initiative);
	send_ability("ad_counterschool", g.ad_counterschool);
	send_ability("ad_fieldmedic",    g.ad_fieldmedic);
	send_ability("ad_warcry",        g.ad_warcry);

	// support
	send_ability("ad_onefinger",  g.ad_onefinger);
	send_ability("ad_autobuy",    g.ad_autobuy);
	send_ability("ad_aputilizer", g.ad_aputilizer);
	send_ability("ad_luckcharm",  g.ad_luckcharm);
	send_ability("ad_notekeeper", g.ad_notekeeper);
	send_ability("ad_bargain",     g.ad_bargain);
	send_ability("ad_deeppockets", g.ad_deeppockets);
	send_ability("ad_scholar",     g.ad_scholar);
}
