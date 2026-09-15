/// @description unlock_deck() - the discovery dispatch: `abi` (the
/// drawn key) becomes an unlocked ability with its name and rarity
/// fanfare. unlock_ability returns 100 - the "new" badge state.
/// (GENERATED from build_deck.py's table)
function unlock_deck() {
	// tapper
	if (abi == "ad_critical") g.ad_critical = unlock_ability("Critical Taps", 0);
	if (abi == "ad_critrate1") g.ad_critrate1 = unlock_ability("Critical Rate+", 0);
	if (abi == "ad_critrate2") g.ad_critrate2 = unlock_ability("Critical Rate++", 0);
	if (abi == "ad_critrate3") g.ad_critrate3 = unlock_ability("Critical Rate+++", 1);
	if (abi == "ad_critcut1") g.ad_critcut1 = unlock_ability("Critical Cut", 0);
	if (abi == "ad_critcut2") g.ad_critcut2 = unlock_ability("Critical Cut+", 0);
	if (abi == "ad_critcut3") g.ad_critcut3 = unlock_ability("Critical Cut++", 0);
	if (abi == "ad_criticalsyphon") g.ad_criticalsyphon = unlock_ability("Critical Syphon", 1);
	if (abi == "ad_tappersyphon1") g.ad_tappersyphon1 = unlock_ability("Tapper Syphon", 2);
	if (abi == "ad_tappersyphon2") g.ad_tappersyphon2 = unlock_ability("Tapper Syphon+", 2);
	if (abi == "ad_tappersyphon3") g.ad_tappersyphon3 = unlock_ability("Tapper Syphon++", 3);
	// overcharge
	if (abi == "ad_overtapper") g.ad_overtapper = unlock_ability("Overcharge", 0);
	if (abi == "ad_chargercap") g.ad_chargercap = unlock_ability("Charger Cap+", 1);
	if (abi == "ad_chargerate1") g.ad_chargerate1 = unlock_ability("Charge Rate+", 1);
	// dials
	if (abi == "ad_patientpayload") g.ad_patientpayload = unlock_ability("Patient Payload", 1);
	// tiles
	if (abi == "ad_fabricator") g.ad_fabricator = unlock_ability("Fabrication", 0);
	if (abi == "ad_fabricator2") g.ad_fabricator2 = unlock_ability("Fabrication+", 0);
	if (abi == "ad_fabricator3") g.ad_fabricator3 = unlock_ability("Fabrication++", 1);
	if (abi == "ad_automerger2") g.ad_automerger2 = unlock_ability("Automerger+", 1);
	if (abi == "ad_automerger3") g.ad_automerger3 = unlock_ability("Automerger++", 2);
	if (abi == "ad_duplicator") g.ad_duplicator = unlock_ability("Duplicator", 0);
	if (abi == "ad_duplicator2") g.ad_duplicator2 = unlock_ability("Duplicator+", 1);
	if (abi == "ad_tiermerger1") g.ad_tiermerger1 = unlock_ability("Tier Merger", 1);
	if (abi == "ad_mergecharger") g.ad_mergecharger = unlock_ability("Merge Charger", 1);
	if (abi == "ad_raritymerger") g.ad_raritymerger = unlock_ability("Rarity Merger", 2);
	// puck
	if (abi == "ad_th_bounce1") g.ad_th_bounce1 = unlock_ability("Bounce+", 0);
	if (abi == "ad_th_bouncegain2") g.ad_th_bouncegain2 = unlock_ability("Bounce Earnings", 1);
	// upgrades
	if (abi == "ad_topgrade1") g.ad_topgrade1 = unlock_ability("Top Grade", 0);
	if (abi == "ad_topgrade2") g.ad_topgrade2 = unlock_ability("Top Grade+", 1);
	if (abi == "ad_topgrade3") g.ad_topgrade3 = unlock_ability("Top Grade++", 2);
	if (abi == "ad_upgradetier") g.ad_upgradetier = unlock_ability("Upgrade Tier+", 1);
	// support
	if (abi == "ad_luckystrike") g.ad_luckystrike = unlock_ability("Lucky Strike", 2);
	if (abi == "ad_jackpot1") g.ad_jackpot1 = unlock_ability("Jackpot", 0);
	if (abi == "ad_offlinecollect") g.ad_offlinecollect = unlock_ability("Autocollect", 0);
	// rebirth
	if (abi == "ad_networth") g.ad_networth = unlock_ability("Networth", 3);
	if (abi == "ad_resetbracer") g.ad_resetbracer = unlock_ability("Reset Bracer", 2);
	if (abi == "ad_resetbracer2") g.ad_resetbracer2 = unlock_ability("Reset Bracer+", 3);
	if (abi == "ad_cheatpool1") g.ad_cheatpool1 = unlock_ability("Cheat Points", 1);
	if (abi == "ad_cheatpool2") g.ad_cheatpool2 = unlock_ability("Cheat Points+", 2);
	if (abi == "ad_cheatpool3") g.ad_cheatpool3 = unlock_ability("Cheat Points++", 4);
	if (abi == "ad_cheatcap1") g.ad_cheatcap1 = unlock_ability("Cheat Ceiling", 2);
	if (abi == "ad_cheatcap2") g.ad_cheatcap2 = unlock_ability("Cheat Ceiling+", 4);

	abi = "";
}
