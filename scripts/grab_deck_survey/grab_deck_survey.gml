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

	if (oo) if (a_ == -1) syst_rm_ability.batch_survey = _a;
}
