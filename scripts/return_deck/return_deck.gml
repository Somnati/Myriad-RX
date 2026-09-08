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

	// fleet
	g.ad_title_fleet = return_ability(g.ad_title_fleet);
	g.ad_warptune    = return_ability(g.ad_warptune);
	g.ad_fuelcells   = return_ability(g.ad_fuelcells);
	g.ad_autopilot   = return_ability(g.ad_autopilot);
	g.ad_deepspace   = return_ability(g.ad_deepspace);

	// tiles
	g.ad_title_tiles  = return_ability(g.ad_title_tiles);
	g.ad_automerger   = return_ability(g.ad_automerger);
	g.ad_automerger2  = return_ability(g.ad_automerger2);
	g.ad_fabricator   = return_ability(g.ad_fabricator);
	g.ad_fabricator2  = return_ability(g.ad_fabricator2);
	g.ad_duplicator   = return_ability(g.ad_duplicator);
	g.ad_tilerarity   = return_ability(g.ad_tilerarity);
	g.ad_hotswap      = return_ability(g.ad_hotswap);

	// colony
	g.ad_title_colony = return_ability(g.ad_title_colony);
	g.ad_cityloans    = return_ability(g.ad_cityloans);
	g.ad_nightshift   = return_ability(g.ad_nightshift);
	g.ad_census       = return_ability(g.ad_census);
	g.ad_terraformer  = return_ability(g.ad_terraformer);

	// combat
	g.ad_title_combat  = return_ability(g.ad_title_combat);
	g.ad_initiative    = return_ability(g.ad_initiative);
	g.ad_counterschool = return_ability(g.ad_counterschool);
	g.ad_fieldmedic    = return_ability(g.ad_fieldmedic);
	g.ad_warcry        = return_ability(g.ad_warcry);

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

	save_mark_dirty();
}
