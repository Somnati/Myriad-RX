/// @description return_deck() - write a slot's toggled input back to
/// the matching global. MUST mirror the grab_deck batch order exactly
/// (same entries, same sequence - the cursor is the identity).
/// titles are walked too. (GENERATED from build_deck.py's table)
function return_deck() {
	_a = 0;

	// tapper
	g.ad_title_tapper = return_ability(g.ad_title_tapper);
	g.ad_critical = return_ability(g.ad_critical);
	g.ad_critrate1 = return_ability(g.ad_critrate1);
	g.ad_critrate2 = return_ability(g.ad_critrate2);
	g.ad_critrate3 = return_ability(g.ad_critrate3);
	g.ad_critcut1 = return_ability(g.ad_critcut1);
	g.ad_critcut2 = return_ability(g.ad_critcut2);
	g.ad_critcut3 = return_ability(g.ad_critcut3);
	g.ad_criticalsyphon = return_ability(g.ad_criticalsyphon);
	g.ad_tappersyphon1 = return_ability(g.ad_tappersyphon1);
	g.ad_tappersyphon2 = return_ability(g.ad_tappersyphon2);
	g.ad_tappersyphon3 = return_ability(g.ad_tappersyphon3);

	// overcharge
	g.ad_title_overcharge = return_ability(g.ad_title_overcharge);
	g.ad_overtapper = return_ability(g.ad_overtapper);
	g.ad_chargercap = return_ability(g.ad_chargercap);
	g.ad_chargerate1 = return_ability(g.ad_chargerate1);

	// dials
	g.ad_title_dials = return_ability(g.ad_title_dials);
	g.ad_patientpayload = return_ability(g.ad_patientpayload);

	// tiles
	g.ad_title_tiles = return_ability(g.ad_title_tiles);
	g.ad_fabricator = return_ability(g.ad_fabricator);
	g.ad_fabricator2 = return_ability(g.ad_fabricator2);
	g.ad_fabricator3 = return_ability(g.ad_fabricator3);
	g.ad_automerger2 = return_ability(g.ad_automerger2);
	g.ad_automerger3 = return_ability(g.ad_automerger3);
	g.ad_duplicator = return_ability(g.ad_duplicator);
	g.ad_duplicator2 = return_ability(g.ad_duplicator2);
	g.ad_tiermerger1 = return_ability(g.ad_tiermerger1);
	g.ad_mergecharger = return_ability(g.ad_mergecharger);
	g.ad_raritymerger = return_ability(g.ad_raritymerger);

	// puck
	g.ad_title_puck = return_ability(g.ad_title_puck);
	g.ad_th_bounce1 = return_ability(g.ad_th_bounce1);
	g.ad_th_bouncegain2 = return_ability(g.ad_th_bouncegain2);

	// upgrades
	g.ad_title_upgrades = return_ability(g.ad_title_upgrades);
	g.ad_topgrade1 = return_ability(g.ad_topgrade1);
	g.ad_topgrade2 = return_ability(g.ad_topgrade2);
	g.ad_topgrade3 = return_ability(g.ad_topgrade3);
	g.ad_upgradetier = return_ability(g.ad_upgradetier);

	// support
	g.ad_title_support = return_ability(g.ad_title_support);
	g.ad_luckystrike = return_ability(g.ad_luckystrike);
	g.ad_jackpot1 = return_ability(g.ad_jackpot1);
	g.ad_offlinecollect = return_ability(g.ad_offlinecollect);

	// rebirth
	g.ad_title_rebirth = return_ability(g.ad_title_rebirth);
	g.ad_networth = return_ability(g.ad_networth);
	g.ad_resetbracer = return_ability(g.ad_resetbracer);
	g.ad_resetbracer2 = return_ability(g.ad_resetbracer2);
	g.ad_cheatpool1 = return_ability(g.ad_cheatpool1);
	g.ad_cheatpool2 = return_ability(g.ad_cheatpool2);
	g.ad_cheatpool3 = return_ability(g.ad_cheatpool3);
	g.ad_cheatcap1 = return_ability(g.ad_cheatcap1);
	g.ad_cheatcap2 = return_ability(g.ad_cheatcap2);

	save_mark_dirty();
}
