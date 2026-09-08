/// @description update_deck_titles() - section titles only exist
/// while their section holds at least one DISCOVERED ability (the
/// native rule: an empty deck shows nothing). the titles are real
/// g.ad_title_* state so grab_deck and return_deck walk the same
/// cursor; this derives them and runs from fetch_new_ability (which
/// every unlock, load, and room entry passes through).
function update_deck_titles() {
	g.ad_title_survey = (g.ad_probespeed != -1 || g.ad_probespeed2 != -1
		|| g.ad_multiprobe != -1 || g.ad_deepscan != -1
		|| g.ad_autosurvey != -1) ? 3 : -1;

	g.ad_title_fleet = (g.ad_warptune != -1 || g.ad_fuelcells != -1
		|| g.ad_autopilot != -1 || g.ad_deepspace != -1) ? 3 : -1;

	g.ad_title_tiles = (g.ad_automerger != -1 || g.ad_automerger2 != -1
		|| g.ad_fabricator != -1 || g.ad_fabricator2 != -1
		|| g.ad_duplicator != -1 || g.ad_tilerarity != -1) ? 3 : -1;

	g.ad_title_colony = (g.ad_cityloans != -1 || g.ad_nightshift != -1
		|| g.ad_census != -1 || g.ad_terraformer != -1) ? 3 : -1;

	g.ad_title_combat = (g.ad_initiative != -1 || g.ad_counterschool != -1
		|| g.ad_fieldmedic != -1 || g.ad_warcry != -1) ? 3 : -1;

	g.ad_title_support = (g.ad_onefinger != -1 || g.ad_autobuy != -1
		|| g.ad_aputilizer != -1 || g.ad_luckcharm != -1
		|| g.ad_notekeeper != -1) ? 3 : -1;
}
