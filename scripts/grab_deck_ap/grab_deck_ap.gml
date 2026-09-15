/// @description grab_deck_ap() - recompute the whole AP economy from
/// scratch, ported from Myriad. AP is an ENABLE BUDGET: maxap grows
/// +2 per discovered ability (on a small base so the first commons
/// are usable), and every enabled ability's cost is subtracted.
/// (GENERATED from scratchpad/build_deck.py's table - the costs here
/// and in the batches come from the one row)
function grab_deck_ap() {
	mx = 0;
	g.ap          = 0;
	g.maxap       = 0;
	g.maxap_spend = 0;
	g.curap_spend = 0;
	ap_multi = 1;

	// tapper
	get_ap(g.ad_title_tapper);
	get_ap(g.ad_critical, 2);
	get_ap(g.ad_critrate1, 3);
	get_ap(g.ad_critrate2, 2);
	get_ap(g.ad_critrate3, 3);
	get_ap(g.ad_critcut1, 4);
	get_ap(g.ad_critcut2, 4);
	get_ap(g.ad_critcut3, 4);
	get_ap(g.ad_criticalsyphon, 5);
	get_ap(g.ad_tappersyphon1, 7);
	get_ap(g.ad_tappersyphon2, 10);
	get_ap(g.ad_tappersyphon3, 15);

	// overcharge
	get_ap(g.ad_title_overcharge);
	get_ap(g.ad_overtapper, 3);
	get_ap(g.ad_chargercap, 4);
	get_ap(g.ad_chargerate1, 3);

	// dials
	get_ap(g.ad_title_dials);
	get_ap(g.ad_patientpayload, 3);

	// tiles
	get_ap(g.ad_title_tiles);
	get_ap(g.ad_fabricator, 2);
	get_ap(g.ad_fabricator2, 2);
	get_ap(g.ad_fabricator3, 3);
	get_ap(g.ad_automerger2, 6);
	get_ap(g.ad_automerger3, 7);
	get_ap(g.ad_duplicator, 3);
	get_ap(g.ad_duplicator2, 5);
	get_ap(g.ad_tiermerger1, 5);
	get_ap(g.ad_mergecharger, 4);
	get_ap(g.ad_raritymerger, 7);

	// puck
	get_ap(g.ad_title_puck);
	get_ap(g.ad_th_bounce1, 5);
	get_ap(g.ad_th_bouncegain2, 5);

	// upgrades
	get_ap(g.ad_title_upgrades);
	get_ap(g.ad_topgrade1, 2);
	get_ap(g.ad_topgrade2, 3);
	get_ap(g.ad_topgrade3, 5);
	get_ap(g.ad_upgradetier, 5);

	// support
	get_ap(g.ad_title_support);
	get_ap(g.ad_luckystrike, 7);
	get_ap(g.ad_jackpot1, 3);
	get_ap(g.ad_offlinecollect, 2);

	// rebirth
	get_ap(g.ad_title_rebirth);
	get_ap(g.ad_networth, 5);
	get_ap(g.ad_resetbracer, 5);
	get_ap(g.ad_resetbracer2, 10);
	get_ap(g.ad_cheatpool1, 4);
	get_ap(g.ad_cheatpool2, 6);
	get_ap(g.ad_cheatpool3, 10);
	get_ap(g.ad_cheatcap1, 6);
	get_ap(g.ad_cheatcap2, 10);

	// ---- finals: the pool, then what's left of it ----
	g.maxap = 4 + 2 * g.new_abilities_unlocked;
	g.ap += g.maxap;
	if (g.ap < 0) g.ap = 0; // over-committed loads clamp gracefully

	if (instance_exists(syst_rm_ability)) syst_rm_ability.mx = mx;
}
