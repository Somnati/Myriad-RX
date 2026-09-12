/// @description grab_deck_ap() - recompute the whole AP economy from
/// scratch, ported from Myriad. AP is an ENABLE BUDGET: maxap grows
/// +2 per discovered ability (on a small base so the first commons
/// are usable), and every enabled ability's cost is subtracted.
/// WARNING (native discipline): every cost here MUST match its
/// ability() line in the grab_deck batches - two lists, one truth.
function grab_deck_ap() {
	mx = 0;
	g.ap          = 0;
	g.maxap       = 0;
	g.maxap_spend = 0;
	g.curap_spend = 0;
	ap_multi = 1;

	// survey
	get_ap(g.ad_title_survey);
	get_ap(g.ad_probespeed, 2);
	get_ap(g.ad_probespeed2, 3);
	get_ap(g.ad_multiprobe, 5);
	get_ap(g.ad_deepscan, 3);
	get_ap(g.ad_autosurvey, 8);
	get_ap(g.ad_signalboost, 2);
	get_ap(g.ad_orbitalmap, 3);
	get_ap(g.ad_probeswarm, 5);
	get_ap(g.ad_coresampler, 7);
	get_ap(g.ad_geologist, 9);

	// fleet
	get_ap(g.ad_title_fleet);
	get_ap(g.ad_warptune, 2);
	get_ap(g.ad_fuelcells, 2);
	get_ap(g.ad_autopilot, 6);
	get_ap(g.ad_deepspace, 9);
	get_ap(g.ad_cargohold, 2);
	get_ap(g.ad_slingshot, 3);
	get_ap(g.ad_hullplate, 4);
	get_ap(g.ad_starcharts, 5);
	get_ap(g.ad_wormhole, 10);

	// tiles
	get_ap(g.ad_title_tiles);
	get_ap(g.ad_automerger, 5);
	get_ap(g.ad_automerger2, 6);
	get_ap(g.ad_fabricator, 2);
	get_ap(g.ad_fabricator2, 3);
	get_ap(g.ad_duplicator, 4);
	get_ap(g.ad_tilerarity, 7);
	get_ap(g.ad_hotswap, 3);
	get_ap(g.ad_magnet, 2);
	get_ap(g.ad_sorter, 4);
	get_ap(g.ad_smelter, 5);
	get_ap(g.ad_overclock, 7);
	get_ap(g.ad_goldleaf, 9);

	// colony
	get_ap(g.ad_title_colony);
	get_ap(g.ad_cityloans, 2);
	get_ap(g.ad_nightshift, 4);
	get_ap(g.ad_census, 1);
	get_ap(g.ad_terraformer, 10);
	get_ap(g.ad_lanterns, 1);
	get_ap(g.ad_marketday, 2);
	get_ap(g.ad_aqueducts, 3);
	get_ap(g.ad_observatory, 4);
	get_ap(g.ad_guilds, 5);
	get_ap(g.ad_capital, 8);

	// combat
	get_ap(g.ad_title_combat);
	get_ap(g.ad_initiative, 2);
	get_ap(g.ad_counterschool, 4);
	get_ap(g.ad_fieldmedic, 6);
	get_ap(g.ad_warcry, 8);
	get_ap(g.ad_drillsgt, 2);
	get_ap(g.ad_ambush, 3);
	get_ap(g.ad_shieldwall, 5);
	get_ap(g.ad_lastword, 6);
	get_ap(g.ad_veterans, 7);
	get_ap(g.ad_ironwill, 9);

	// support
	get_ap(g.ad_title_support);
	get_ap(g.ad_onefinger, 0);
	get_ap(g.ad_autobuy, 0);
	get_ap(g.ad_aputilizer, 4);
	get_ap(g.ad_luckcharm, 3);
	get_ap(g.ad_notekeeper, 1);
	get_ap(g.ad_bargain, 3);
	get_ap(g.ad_deeppockets, 2);
	get_ap(g.ad_scholar, 4);
	get_ap(g.ad_alarmclock, 1);
	get_ap(g.ad_archivist, 2);
	get_ap(g.ad_nightowl, 3);
	get_ap(g.ad_tinkerer, 4);
	get_ap(g.ad_secondwind, 6);

	// ---- finals: the pool, then what's left of it ----
	g.maxap = 4 + 2 * g.new_abilities_unlocked;
	if (g.ad_aputilizer == 1) g.maxap += 2;  // the recursive one
	if (g.ad_deeppockets == 1) g.maxap += 4; // its bigger sibling
	g.ap += g.maxap;
	if (g.ap < 0) g.ap = 0; // over-committed loads clamp gracefully

	if (instance_exists(syst_rm_ability)) syst_rm_ability.mx = mx;
}
