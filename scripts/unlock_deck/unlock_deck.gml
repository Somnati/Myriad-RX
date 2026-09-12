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
	if (abi == "ad_signalboost") g.ad_signalboost = unlock_ability("Signal Boost", _common);
	if (abi == "ad_orbitalmap") g.ad_orbitalmap = unlock_ability("Orbital Cartography", _uncommon);
	if (abi == "ad_probeswarm") g.ad_probeswarm = unlock_ability("Probe Swarm", _rare);
	if (abi == "ad_coresampler") g.ad_coresampler = unlock_ability("Core Sampler", _legendary);
	if (abi == "ad_geologist") g.ad_geologist = unlock_ability("Field Geologist", _epic);

	// fleet
	if (abi == "ad_warptune")  g.ad_warptune  = unlock_ability("Warp Tuning", _common);
	if (abi == "ad_fuelcells") g.ad_fuelcells = unlock_ability("Fuel Cells", _common);
	if (abi == "ad_autopilot") g.ad_autopilot = unlock_ability("Autopilot", _rare);
	if (abi == "ad_deepspace") g.ad_deepspace = unlock_ability("Deep Space Antenna", _epic);
	if (abi == "ad_cargohold") g.ad_cargohold = unlock_ability("Cargo Hold", _common);
	if (abi == "ad_slingshot") g.ad_slingshot = unlock_ability("Gravity Sling", _uncommon);
	if (abi == "ad_hullplate") g.ad_hullplate = unlock_ability("Hull Plating", _uncommon);
	if (abi == "ad_starcharts") g.ad_starcharts = unlock_ability("Star Charts", _rare);
	if (abi == "ad_wormhole") g.ad_wormhole = unlock_ability("Wormhole Key", _epic);

	// tiles
	if (abi == "ad_automerger")  g.ad_automerger  = unlock_ability("Automerger", _common);
	if (abi == "ad_automerger2") g.ad_automerger2 = unlock_ability("Automerger+", _uncommon);
	if (abi == "ad_fabricator")  g.ad_fabricator  = unlock_ability("Fabrication", _common);
	if (abi == "ad_fabricator2") g.ad_fabricator2 = unlock_ability("Fabrication+", _uncommon);
	if (abi == "ad_duplicator")  g.ad_duplicator  = unlock_ability("Duplicator", _rare);
	if (abi == "ad_tilerarity")  g.ad_tilerarity  = unlock_ability("Refined Alloys", _legendary);
	if (abi == "ad_hotswap")     g.ad_hotswap     = unlock_ability("Hot Swap", _rare);
	if (abi == "ad_magnet") g.ad_magnet = unlock_ability("Tile Magnet", _common);
	if (abi == "ad_sorter") g.ad_sorter = unlock_ability("Sorting Arm", _uncommon);
	if (abi == "ad_smelter") g.ad_smelter = unlock_ability("Smelter", _rare);
	if (abi == "ad_overclock") g.ad_overclock = unlock_ability("Overclock", _legendary);
	if (abi == "ad_goldleaf") g.ad_goldleaf = unlock_ability("Gold Leaf", _epic);

	// colony
	if (abi == "ad_cityloans")   g.ad_cityloans   = unlock_ability("City Loans", _common);
	if (abi == "ad_nightshift")  g.ad_nightshift  = unlock_ability("Night Shift", _uncommon);
	if (abi == "ad_census")      g.ad_census      = unlock_ability("Census", _common);
	if (abi == "ad_terraformer") g.ad_terraformer = unlock_ability("Terraformers", _epic);
	if (abi == "ad_lanterns") g.ad_lanterns = unlock_ability("Lanterns", _common);
	if (abi == "ad_marketday") g.ad_marketday = unlock_ability("Market Day", _common);
	if (abi == "ad_aqueducts") g.ad_aqueducts = unlock_ability("Aqueducts", _uncommon);
	if (abi == "ad_observatory") g.ad_observatory = unlock_ability("Observatory", _rare);
	if (abi == "ad_guilds") g.ad_guilds = unlock_ability("Guilds", _rare);
	if (abi == "ad_capital") g.ad_capital = unlock_ability("Capital", _legendary);

	// combat
	if (abi == "ad_initiative")    g.ad_initiative    = unlock_ability("Initiative", _common);
	if (abi == "ad_counterschool") g.ad_counterschool = unlock_ability("Counter School", _uncommon);
	if (abi == "ad_fieldmedic")    g.ad_fieldmedic    = unlock_ability("Field Medic", _rare);
	if (abi == "ad_warcry")        g.ad_warcry        = unlock_ability("War Cry", _legendary);
	if (abi == "ad_drillsgt") g.ad_drillsgt = unlock_ability("Drill Sergeant", _common);
	if (abi == "ad_ambush") g.ad_ambush = unlock_ability("Ambush", _uncommon);
	if (abi == "ad_shieldwall") g.ad_shieldwall = unlock_ability("Shield Wall", _rare);
	if (abi == "ad_lastword") g.ad_lastword = unlock_ability("Last Word", _rare);
	if (abi == "ad_veterans") g.ad_veterans = unlock_ability("Veterans", _legendary);
	if (abi == "ad_ironwill") g.ad_ironwill = unlock_ability("Iron Will", _epic);

	// support
	if (abi == "ad_onefinger")  g.ad_onefinger  = unlock_ability("One Finger Mode", _rare);
	if (abi == "ad_autobuy")    g.ad_autobuy    = unlock_ability("Autobuy", _common);
	if (abi == "ad_aputilizer") g.ad_aputilizer = unlock_ability("AP Utilizer", _rare);
	if (abi == "ad_luckcharm")  g.ad_luckcharm  = unlock_ability("Lucky Charm", _uncommon);
	if (abi == "ad_notekeeper") g.ad_notekeeper = unlock_ability("Note Keeper", _common);
	if (abi == "ad_bargain")     g.ad_bargain     = unlock_ability("Bargain Hunter", _uncommon);
	if (abi == "ad_deeppockets") g.ad_deeppockets = unlock_ability("Deep Pockets", _rare);
	if (abi == "ad_scholar")     g.ad_scholar     = unlock_ability("Scholar", _legendary);
	if (abi == "ad_alarmclock") g.ad_alarmclock = unlock_ability("Alarm Clock", _common);
	if (abi == "ad_archivist") g.ad_archivist = unlock_ability("Archivist", _uncommon);
	if (abi == "ad_nightowl") g.ad_nightowl = unlock_ability("Night Owl", _uncommon);
	if (abi == "ad_tinkerer") g.ad_tinkerer = unlock_ability("Tinkerer", _rare);
	if (abi == "ad_secondwind") g.ad_secondwind = unlock_ability("Second Wind", _legendary);

	abi = "";
}
