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
		// ---- the second half (2026-09-11): made up, unwired placeholders ----
		// survey
		case "ad_signalboost": return { name : "Signal Boost", rarity : 0, ap : 2,
			desc : "probe reports arrive\n30% sooner" };
		case "ad_orbitalmap": return { name : "Orbital Cartography", rarity : 1, ap : 3,
			desc : "surveyed sites stay marked\nfrom orbit forever" };
		case "ad_probeswarm": return { name : "Probe Swarm", rarity : 2, ap : 5,
			desc : "one launch sends three\nprobes toward a site" };
		case "ad_coresampler": return { name : "Core Sampler", rarity : 3, ap : 7,
			desc : "surveys can strike the\nmantle: rare finds doubled" };
		case "ad_geologist": return { name : "Field Geologist", rarity : 4, ap : 9,
			desc : "every tenth survey is a\nguaranteed discovery" };
		// fleet
		case "ad_cargohold": return { name : "Cargo Hold", rarity : 0, ap : 2,
			desc : "the ship carries 25%\nmore between systems" };
		case "ad_slingshot": return { name : "Gravity Sling", rarity : 1, ap : 3,
			desc : "a warp that passes a star\ncosts nothing" };
		case "ad_hullplate": return { name : "Hull Plating", rarity : 1, ap : 4,
			desc : "re-entry wear on the\nhull is halved" };
		case "ad_starcharts": return { name : "Star Charts", rarity : 2, ap : 5,
			desc : "unvisited systems show\ntheir planet count" };
		case "ad_wormhole": return { name : "Wormhole Key", rarity : 4, ap : 10,
			desc : "one free jump to any\nvisited star, once a day" };
		// tiles
		case "ad_magnet": return { name : "Tile Magnet", rarity : 0, ap : 2,
			desc : "a dropped tile snaps to\nthe nearest matching pair" };
		case "ad_sorter": return { name : "Sorting Arm", rarity : 1, ap : 4,
			desc : "the table tidies itself\nby tier once a minute" };
		case "ad_smelter": return { name : "Smelter", rarity : 2, ap : 5,
			desc : "three tiles of one tier\nmerge as a single pair" };
		case "ad_overclock": return { name : "Overclock", rarity : 3, ap : 7,
			desc : "the fabricator runs at\ndouble speed for 30s\nafter every merge" };
		case "ad_goldleaf": return { name : "Gold Leaf", rarity : 4, ap : 9,
			desc : "a merged tile has a 2%\nchance to skip a tier" };
		// colony
		case "ad_lanterns": return { name : "Lanterns", rarity : 0, ap : 1,
			desc : "city lights reach further\ninto the night side" };
		case "ad_marketday": return { name : "Market Day", rarity : 0, ap : 2,
			desc : "tribute collects 10%\nfaster on the day side" };
		case "ad_aqueducts": return { name : "Aqueducts", rarity : 1, ap : 3,
			desc : "cities grow one size past\nwhat their biome allows" };
		case "ad_observatory": return { name : "Observatory", rarity : 2, ap : 4,
			desc : "a city with an observatory\nreveals its whole system" };
		case "ad_guilds": return { name : "Guilds", rarity : 2, ap : 5,
			desc : "settled cities trade with\neach other: +15% tribute" };
		case "ad_capital": return { name : "Capital", rarity : 3, ap : 8,
			desc : "name one city the capital:\nit pays double" };
		// combat
		case "ad_drillsgt": return { name : "Drill Sergeant", rarity : 0, ap : 2,
			desc : "recruits arrive with\n+10% hp" };
		case "ad_ambush": return { name : "Ambush", rarity : 1, ap : 3,
			desc : "the enemy's first turn\nis skipped" };
		case "ad_shieldwall": return { name : "Shield Wall", rarity : 2, ap : 5,
			desc : "pawns standing together\ntake 15% less" };
		case "ad_lastword": return { name : "Last Word", rarity : 2, ap : 6,
			desc : "a falling pawn lands one\nfree strike first" };
		case "ad_veterans": return { name : "Veterans", rarity : 3, ap : 7,
			desc : "survivors keep 5% of the\nxp they earned" };
		case "ad_ironwill": return { name : "Iron Will", rarity : 4, ap : 9,
			desc : "once a battle, a killing\nblow leaves 1 hp instead" };
		// support
		case "ad_alarmclock": return { name : "Alarm Clock", rarity : 0, ap : 1,
			desc : "the welcome-back card\nsays what ran dry, and when" };
		case "ad_archivist": return { name : "Archivist", rarity : 1, ap : 2,
			desc : "the statistics remember\ntwice as far back" };
		case "ad_nightowl": return { name : "Night Owl", rarity : 1, ap : 3,
			desc : "the battery drains 10%\nslower while you are away" };
		case "ad_tinkerer": return { name : "Tinkerer", rarity : 2, ap : 4,
			desc : "the crank charges 25%\nmore per turn" };
		case "ad_secondwind": return { name : "Second Wind", rarity : 3, ap : 6,
			desc : "the time bank fills 20%\nfaster while it is empty" };
	}
	return { name : "???", rarity : 0, ap : 0, desc : "" };
}
