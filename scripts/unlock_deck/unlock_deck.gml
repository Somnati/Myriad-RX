/// @description unlock_deck() - the discovery dispatch: `abi` (the
/// drawn key) becomes an unlocked ability with its name and rarity
/// fanfare. unlock_ability returns 100 - the "new" badge state.
function unlock_deck() {
	var _common = 0, _uncommon = 1, _rare = 2, _legendary = 3, _epic = 4;

	// survey
	if (abi == "ad_probespeed")  g.ad_probespeed  = unlock_ability("Fast Probes", _common);
	if (abi == "ad_probespeed2") g.ad_probespeed2 = unlock_ability("Fast Probes+", _uncommon);
	if (abi == "ad_multiprobe")  g.ad_multiprobe  = unlock_ability("Twin Probes", _rare);
	if (abi == "ad_deepscan")    g.ad_deepscan    = unlock_ability("Deep Scan", _uncommon);
	if (abi == "ad_autosurvey")  g.ad_autosurvey  = unlock_ability("Auto Survey", _legendary);

	// fleet
	if (abi == "ad_warptune")  g.ad_warptune  = unlock_ability("Warp Tuning", _common);
	if (abi == "ad_fuelcells") g.ad_fuelcells = unlock_ability("Fuel Cells", _common);
	if (abi == "ad_autopilot") g.ad_autopilot = unlock_ability("Autopilot", _rare);
	if (abi == "ad_deepspace") g.ad_deepspace = unlock_ability("Deep Space Antenna", _epic);

	// tiles
	if (abi == "ad_automerger")  g.ad_automerger  = unlock_ability("Automerger", _common);
	if (abi == "ad_automerger2") g.ad_automerger2 = unlock_ability("Automerger+", _uncommon);
	if (abi == "ad_fabricator")  g.ad_fabricator  = unlock_ability("Fabrication", _common);
	if (abi == "ad_fabricator2") g.ad_fabricator2 = unlock_ability("Fabrication+", _uncommon);
	if (abi == "ad_duplicator")  g.ad_duplicator  = unlock_ability("Duplicator", _rare);
	if (abi == "ad_tilerarity")  g.ad_tilerarity  = unlock_ability("Refined Alloys", _legendary);
	if (abi == "ad_hotswap")     g.ad_hotswap     = unlock_ability("Hot Swap", _rare);

	// colony
	if (abi == "ad_cityloans")   g.ad_cityloans   = unlock_ability("City Loans", _common);
	if (abi == "ad_nightshift")  g.ad_nightshift  = unlock_ability("Night Shift", _uncommon);
	if (abi == "ad_census")      g.ad_census      = unlock_ability("Census", _common);
	if (abi == "ad_terraformer") g.ad_terraformer = unlock_ability("Terraformers", _epic);

	// combat
	if (abi == "ad_initiative")    g.ad_initiative    = unlock_ability("Initiative", _common);
	if (abi == "ad_counterschool") g.ad_counterschool = unlock_ability("Counter School", _uncommon);
	if (abi == "ad_fieldmedic")    g.ad_fieldmedic    = unlock_ability("Field Medic", _rare);
	if (abi == "ad_warcry")        g.ad_warcry        = unlock_ability("War Cry", _legendary);

	// support
	if (abi == "ad_onefinger")  g.ad_onefinger  = unlock_ability("One Finger Mode", _rare);
	if (abi == "ad_autobuy")    g.ad_autobuy    = unlock_ability("Autobuy", _common);
	if (abi == "ad_aputilizer") g.ad_aputilizer = unlock_ability("AP Utilizer", _rare);
	if (abi == "ad_luckcharm")  g.ad_luckcharm  = unlock_ability("Lucky Charm", _uncommon);
	if (abi == "ad_notekeeper") g.ad_notekeeper = unlock_ability("Note Keeper", _common);
	if (abi == "ad_bargain")     g.ad_bargain     = unlock_ability("Bargain Hunter", _uncommon);
	if (abi == "ad_deeppockets") g.ad_deeppockets = unlock_ability("Deep Pockets", _rare);
	if (abi == "ad_scholar")     g.ad_scholar     = unlock_ability("Scholar", _legendary);

	abi = "";
}
