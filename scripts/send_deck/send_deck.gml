/// @description send_deck() - list every ability's discovery
/// eligibility (the pool builder). sub-abilities pass their parent
/// so chains discover in order. (GENERATED from build_deck.py's table)
function send_deck() {
	// tapper
	send_ability("ad_critrate1", g.ad_critrate1);
	send_ability("ad_critrate2", g.ad_critrate2, g.ad_critrate1);
	send_ability("ad_critrate3", g.ad_critrate3, g.ad_critrate2);
	send_ability("ad_critcut1", g.ad_critcut1);
	send_ability("ad_critcut2", g.ad_critcut2, g.ad_critcut1);
	send_ability("ad_critcut3", g.ad_critcut3, g.ad_critcut2);
	send_ability("ad_criticalsyphon", g.ad_criticalsyphon);
	send_ability("ad_tappersyphon1", g.ad_tappersyphon1);
	send_ability("ad_tappersyphon2", g.ad_tappersyphon2, g.ad_tappersyphon1);
	send_ability("ad_tappersyphon3", g.ad_tappersyphon3, g.ad_tappersyphon2);
	// overcharge
	send_ability("ad_chargercap", g.ad_chargercap);
	send_ability("ad_chargerate1", g.ad_chargerate1);
	// dials
	send_ability("ad_patientpayload", g.ad_patientpayload);
	// tiles
	send_ability("ad_fabricator", g.ad_fabricator);
	send_ability("ad_fabricator2", g.ad_fabricator2, g.ad_fabricator);
	send_ability("ad_fabricator3", g.ad_fabricator3, g.ad_fabricator2);
	send_ability("ad_automerger2", g.ad_automerger2);
	send_ability("ad_automerger3", g.ad_automerger3, g.ad_automerger2);
	send_ability("ad_duplicator", g.ad_duplicator);
	send_ability("ad_duplicator2", g.ad_duplicator2, g.ad_duplicator);
	send_ability("ad_tiermerger1", g.ad_tiermerger1);
	send_ability("ad_mergecharger", g.ad_mergecharger);
	send_ability("ad_raritymerger", g.ad_raritymerger);
	// puck
	send_ability("ad_th_bounce1", g.ad_th_bounce1);
	send_ability("ad_th_bouncegain2", g.ad_th_bouncegain2);
	// upgrades
	send_ability("ad_topgrade1", g.ad_topgrade1);
	send_ability("ad_topgrade2", g.ad_topgrade2, g.ad_topgrade1);
	send_ability("ad_topgrade3", g.ad_topgrade3, g.ad_topgrade2);
	send_ability("ad_upgradetier", g.ad_upgradetier);
	// support
	send_ability("ad_luckystrike", g.ad_luckystrike);
	send_ability("ad_jackpot1", g.ad_jackpot1);
	send_ability("ad_offlinecollect", g.ad_offlinecollect);
	// rebirth
	send_ability("ad_networth", g.ad_networth);
	send_ability("ad_resetbracer", g.ad_resetbracer);
	send_ability("ad_resetbracer2", g.ad_resetbracer2, g.ad_resetbracer);
}
