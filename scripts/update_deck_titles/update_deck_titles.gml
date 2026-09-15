/// @description update_deck_titles() - section titles only exist
/// while their section holds at least one DISCOVERED ability (the
/// native rule: an empty deck shows nothing). the titles are real
/// g.ad_title_* state so grab_deck and return_deck walk the same
/// cursor; this derives them and runs from fetch_new_ability (which
/// every unlock, load, and room entry passes through).
/// (GENERATED from build_deck.py's table)
function update_deck_titles() {
	g.ad_title_tapper = (g.ad_critical != -1
		|| g.ad_critrate1 != -1
		|| g.ad_critrate2 != -1
		|| g.ad_critrate3 != -1
		|| g.ad_critcut1 != -1
		|| g.ad_critcut2 != -1
		|| g.ad_critcut3 != -1
		|| g.ad_criticalsyphon != -1
		|| g.ad_tappersyphon1 != -1
		|| g.ad_tappersyphon2 != -1
		|| g.ad_tappersyphon3 != -1) ? 3 : -1;
	g.ad_title_overcharge = (g.ad_overtapper != -1
		|| g.ad_chargercap != -1
		|| g.ad_chargerate1 != -1) ? 3 : -1;
	g.ad_title_dials = (g.ad_patientpayload != -1) ? 3 : -1;
	g.ad_title_tiles = (g.ad_fabricator != -1
		|| g.ad_fabricator2 != -1
		|| g.ad_fabricator3 != -1
		|| g.ad_automerger2 != -1
		|| g.ad_automerger3 != -1
		|| g.ad_duplicator != -1
		|| g.ad_duplicator2 != -1
		|| g.ad_tiermerger1 != -1
		|| g.ad_mergecharger != -1
		|| g.ad_raritymerger != -1) ? 3 : -1;
	g.ad_title_puck = (g.ad_th_bounce1 != -1
		|| g.ad_th_bouncegain2 != -1) ? 3 : -1;
	g.ad_title_upgrades = (g.ad_topgrade1 != -1
		|| g.ad_topgrade2 != -1
		|| g.ad_topgrade3 != -1
		|| g.ad_upgradetier != -1) ? 3 : -1;
	g.ad_title_support = (g.ad_luckystrike != -1
		|| g.ad_jackpot1 != -1
		|| g.ad_offlinecollect != -1) ? 3 : -1;
	g.ad_title_rebirth = (g.ad_networth != -1
		|| g.ad_resetbracer != -1
		|| g.ad_resetbracer2 != -1
		|| g.ad_cheatpool1 != -1
		|| g.ad_cheatpool2 != -1
		|| g.ad_cheatpool3 != -1
		|| g.ad_cheatcap1 != -1
		|| g.ad_cheatcap2 != -1) ? 3 : -1;
}
