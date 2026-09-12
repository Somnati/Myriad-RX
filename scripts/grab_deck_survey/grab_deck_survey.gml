/// @description grab_deck_survey() - placeholder abilities for the
/// future planet-survey system (probes, sites, discoveries). all
/// no-ops until the system exists; the deck framework doesn't care.
function grab_deck_survey() {

	ability(g.ad_title_survey, "Survey", 0, 0, "", false, false);

	ability(g.ad_probespeed, "Fast Probes", common, 2,
		"survey probes travel\n25% faster", false, false);
	ability_flavor("+25%", "probe speed", "", -1);

	_open = false;
	if (g.ad_probespeed == 1) _open = true;
	if (g.ad_probespeed == -1) _open = -1;
	ability(g.ad_probespeed2, "Fast Probes+", uncommon, 3,
		"probes travel another\n25% faster", true, false);
	ability_flavor("+25%", "probe speed", "", -1);
	if (_open == false) ability_flavor("[requires fast probes]", "", "", c_hred);
	_open = true;

	ability(g.ad_multiprobe, "Twin Probes", rare, 5,
		"two survey sites can run\nat the same time", false, false);
	ability_flavor("+1", "active sites", "", -1);

	ability(g.ad_deepscan, "Deep Scan", uncommon, 3,
		"completed surveys reveal\none extra discovery", false, false);
	ability_flavor("+1", "discoveries", "", -1);

	ability(g.ad_autosurvey, "Auto Survey", legendary, 8,
		"finished sites relaunch\ntheir probes automatically", false, false);

	// ---- the second half (2026-09-11): made up, unwired placeholders ----
	ability(g.ad_signalboost, "Signal Boost", common, 2,
		"probe reports arrive\n30% sooner", false, false);
	ability_flavor("-30%", "report delay", "", -1);

	ability(g.ad_orbitalmap, "Orbital Cartography", uncommon, 3,
		"surveyed sites stay marked\nfrom orbit forever", false, false);

	ability(g.ad_probeswarm, "Probe Swarm", rare, 5,
		"one launch sends three\nprobes toward a site", false, false);
	ability_flavor("+2", "probes per launch", "", -1);

	ability(g.ad_coresampler, "Core Sampler", legendary, 7,
		"surveys can strike the\nmantle: rare finds doubled", false, false);
	ability_flavor("x2", "rare finds", "", -1);

	ability(g.ad_geologist, "Field Geologist", epic, 9,
		"every tenth survey is a\nguaranteed discovery", false, false);
	ability_flavor("1 in 10", "sure finds", "", -1);

	if (oo) if (a_ == -1) syst_rm_ability.batch_survey = _a;
}
