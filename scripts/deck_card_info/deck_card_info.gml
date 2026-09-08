/// @description deck_card_info(key) -> { name, rarity, ap, desc }
/// the whole deck's card face data by key, INDEPENDENT of the cursor
/// (which skips locked abilities) - the collection names what you
/// haven't found, the draft cards show what you're choosing between,
/// and meta abilities (Scholar) look costs up here.
/// touchpoint #6: keep in sync with the batches.
function deck_card_info(_key) {
	switch (_key) {
		// survey
		case "ad_probespeed":  return { name : "Fast Probes",  rarity : 0, ap : 2,
			desc : "survey probes travel\n25% faster" };
		case "ad_probespeed2": return { name : "Fast Probes+", rarity : 1, ap : 3,
			desc : "probes travel another\n25% faster" };
		case "ad_multiprobe":  return { name : "Twin Probes",  rarity : 2, ap : 5,
			desc : "two survey sites can run\nat the same time" };
		case "ad_deepscan":    return { name : "Deep Scan",    rarity : 1, ap : 3,
			desc : "completed surveys reveal\none extra discovery" };
		case "ad_autosurvey":  return { name : "Auto Survey",  rarity : 3, ap : 8,
			desc : "finished sites relaunch\ntheir probes automatically" };
		// fleet
		case "ad_warptune":  return { name : "Warp Tuning",        rarity : 0, ap : 2,
			desc : "warp travel on the starmap\nis 20% quicker" };
		case "ad_fuelcells": return { name : "Fuel Cells",         rarity : 0, ap : 2,
			desc : "system dives burn 15%\nless fuel" };
		case "ad_autopilot": return { name : "Autopilot",          rarity : 2, ap : 6,
			desc : "the ship climbs back to\norbit on its own" };
		case "ad_deepspace": return { name : "Deep Space Antenna", rarity : 4, ap : 9,
			desc : "idle gains keep flowing\nwhile in warp" };
		// tiles
		case "ad_automerger":  return { name : "Automerger",     rarity : 0, ap : 5,
			desc : "the tile table merges\npairs on its own" };
		case "ad_automerger2": return { name : "Automerger+",    rarity : 1, ap : 6,
			desc : "auto merge interval\nreduced by 20%" };
		case "ad_fabricator":  return { name : "Fabrication",    rarity : 0, ap : 2,
			desc : "tiles fabricate\n10% faster" };
		case "ad_fabricator2": return { name : "Fabrication+",   rarity : 1, ap : 3,
			desc : "tiles fabricate another\n15% faster" };
		case "ad_duplicator":  return { name : "Duplicator",     rarity : 2, ap : 4,
			desc : "fabricated tiles have a 15%\nchance to arrive twice" };
		case "ad_tilerarity":  return { name : "Refined Alloys", rarity : 3, ap : 7,
			desc : "tile rarity rate is\nraised by +400" };
		case "ad_hotswap":     return { name : "Hot Swap",       rarity : 2, ap : 3,
			desc : "dropping a tile onto a\nmismatched tile swaps them\ninstead of bouncing home" };
		// colony
		case "ad_cityloans":   return { name : "City Loans",   rarity : 0, ap : 2,
			desc : "settled cities pay 10%\nmore tribute" };
		case "ad_nightshift":  return { name : "Night Shift",  rarity : 1, ap : 4,
			desc : "night side cities produce\n25% more while dark" };
		case "ad_census":      return { name : "Census",       rarity : 0, ap : 1,
			desc : "city populations become\nvisible from orbit" };
		case "ad_terraformer": return { name : "Terraformers", rarity : 4, ap : 10,
			desc : "biome shifts crawl\ntwice as fast" };
		// combat
		case "ad_initiative":    return { name : "Initiative",     rarity : 0, ap : 2,
			desc : "your team opens battles\nwith +20% tic" };
		case "ad_counterschool": return { name : "Counter School", rarity : 1, ap : 4,
			desc : "every pawn gains +3%\ncounter chance" };
		case "ad_fieldmedic":    return { name : "Field Medic",    rarity : 2, ap : 6,
			desc : "survivors mend 10% of max\nhp after each battle" };
		case "ad_warcry":        return { name : "War Cry",        rarity : 3, ap : 8,
			desc : "the first attack of every\nbattle is a quality hit" };
		// support
		case "ad_onefinger":   return { name : "One Finger Mode", rarity : 2, ap : 0,
			desc : "hold-friendly input\neverywhere" };
		case "ad_autobuy":     return { name : "Autobuy",         rarity : 0, ap : 0,
			desc : "cheap purchases handle\nthemselves" };
		case "ad_aputilizer":  return { name : "AP Utilizer",     rarity : 2, ap : 4,
			desc : "raises max ap by +2" };
		case "ad_luckcharm":   return { name : "Lucky Charm",     rarity : 1, ap : 3,
			desc : "+5% to every roll that\nmentions luck" };
		case "ad_notekeeper":  return { name : "Note Keeper",     rarity : 0, ap : 1,
			desc : "the deck remembers the\nlast card you inspected" };
		case "ad_bargain":     return { name : "Bargain Hunter",  rarity : 1, ap : 3,
			desc : "discovering new abilities\ncosts 15% fewer units" };
		case "ad_deeppockets": return { name : "Deep Pockets",    rarity : 2, ap : 2,
			desc : "raises max ap by +4" };
		case "ad_scholar":     return { name : "Scholar",         rarity : 3, ap : 4,
			desc : "discovered abilities arrive\nalready enabled when the\nap can cover them" };
	}
	return { name : "???", rarity : 0, ap : 0, desc : "" };
}
