/// @description deck_card_info(key) -> { name, rarity, ap, desc }
/// the whole deck's card face data by key, INDEPENDENT of the cursor
/// (which skips locked abilities) - the collection names what you
/// haven't found, the draft cards show what you're choosing between,
/// and meta abilities (Scholar) look costs up here.
/// (GENERATED from build_deck.py's table)
function deck_card_info(_key) {
	switch (_key) {
		// tapper
		case "ad_critrate1": return { name : "Critical Rate+", rarity : 0, ap : 3,
			desc : "the base critical chance\nis doubled" };
		case "ad_critrate2": return { name : "Critical Rate++", rarity : 0, ap : 2,
			desc : "all critical chance\n+200%" };
		case "ad_critrate3": return { name : "Critical Rate+++", rarity : 1, ap : 3,
			desc : "all critical chance\n+300%" };
		case "ad_critcut1": return { name : "Critical Cut", rarity : 0, ap : 4,
			desc : "halves the crit rate,\ndoubles the crit multiplier" };
		case "ad_critcut2": return { name : "Critical Cut+", rarity : 0, ap : 4,
			desc : "halves the crit rate again,\ndoubles the multiplier again" };
		case "ad_critcut3": return { name : "Critical Cut++", rarity : 0, ap : 4,
			desc : "and once more: half the\nrate, twice the multiplier" };
		case "ad_criticalsyphon": return { name : "Critical Syphon", rarity : 1, ap : 5,
			desc : "the dials share your\ncritical rate and multiplier" };
		case "ad_tappersyphon1": return { name : "Tapper Syphon", rarity : 2, ap : 7,
			desc : "a tap also pays 1% of what\nthe dials make a second" };
		case "ad_tappersyphon2": return { name : "Tapper Syphon+", rarity : 2, ap : 10,
			desc : "the syphon takes\nanother 10%" };
		case "ad_tappersyphon3": return { name : "Tapper Syphon++", rarity : 3, ap : 15,
			desc : "the syphon takes\nanother 50%" };
		// overcharge
		case "ad_chargercap": return { name : "Charger Cap+", rarity : 1, ap : 4,
			desc : "the overcharger climbs\nfive levels further" };
		case "ad_chargerate1": return { name : "Charge Rate+", rarity : 1, ap : 3,
			desc : "taps charge the overcharger\ntwice as fast" };
		// dials
		case "ad_patientpayload": return { name : "Patient Payload", rarity : 1, ap : 3,
			desc : "a dial pays +1% for every\nsecond its cycle takes" };
		// tiles
		case "ad_fabricator": return { name : "Fabrication", rarity : 0, ap : 2,
			desc : "the fabricator runs\n15% faster" };
		case "ad_fabricator2": return { name : "Fabrication+", rarity : 0, ap : 2,
			desc : "the fabricator runs\nanother 15% faster" };
		case "ad_fabricator3": return { name : "Fabrication++", rarity : 1, ap : 3,
			desc : "the fabricator runs\nanother 25% faster" };
		case "ad_automerger2": return { name : "Automerger+", rarity : 1, ap : 6,
			desc : "the automerger works\n25% faster" };
		case "ad_automerger3": return { name : "Automerger++", rarity : 2, ap : 7,
			desc : "the automerger works\nanother 40% faster" };
		case "ad_duplicator": return { name : "Duplicator", rarity : 0, ap : 3,
			desc : "+15% chance a fabricated\ntile arrives twice" };
		case "ad_duplicator2": return { name : "Duplicator+", rarity : 1, ap : 5,
			desc : "+20% more chance of\na second tile" };
		case "ad_tiermerger1": return { name : "Tier Merger", rarity : 1, ap : 5,
			desc : "+18% chance a merge climbs\nan extra tier" };
		case "ad_mergecharger": return { name : "Merge Charger", rarity : 1, ap : 4,
			desc : "every merge charges the\nfabricator by 20%" };
		case "ad_raritymerger": return { name : "Rarity Merger", rarity : 2, ap : 7,
			desc : "tile rarity +1% for\nevery 500 merges" };
		// puck
		case "ad_th_bounce1": return { name : "Bounce+", rarity : 0, ap : 5,
			desc : "a throw has seven more\nbounces in it" };
		case "ad_th_bouncegain2": return { name : "Bounce Earnings", rarity : 1, ap : 5,
			desc : "fast bounces pay x5,\nslow bounces x10" };
		// upgrades
		case "ad_topgrade1": return { name : "Top Grade", rarity : 0, ap : 2,
			desc : "rarer upgrades roll\n20% more often" };
		case "ad_topgrade2": return { name : "Top Grade+", rarity : 1, ap : 3,
			desc : "rarer upgrades roll\n30% more often still" };
		case "ad_topgrade3": return { name : "Top Grade++", rarity : 2, ap : 5,
			desc : "rarer upgrades roll\n50% more often still" };
		case "ad_upgradetier": return { name : "Upgrade Tier+", rarity : 1, ap : 5,
			desc : "upgrades roll with up to\ntwo more tiers" };
		// support
		case "ad_luckystrike": return { name : "Lucky Strike", rarity : 2, ap : 7,
			desc : "credits drop from taps\ntwice as often" };
		case "ad_jackpot1": return { name : "Jackpot", rarity : 0, ap : 3,
			desc : "every credit drop\npays one more" };
		case "ad_offlinecollect": return { name : "Autocollect", rarity : 0, ap : 2,
			desc : "profit earned while away\nis collected on arrival" };
		// rebirth
		case "ad_networth": return { name : "Networth", rarity : 3, ap : 5,
			desc : "rebirth counts the profit\nyou spent, not only what\nyou hold" };
		case "ad_resetbracer": return { name : "Reset Bracer", rarity : 2, ap : 5,
			desc : "every dial keeps one level\nthrough a rebirth" };
		case "ad_resetbracer2": return { name : "Reset Bracer+", rarity : 3, ap : 10,
			desc : "every dial keeps all its\nlevels through a rebirth" };
		case "ad_cheatpool1": return { name : "Cheat Points", rarity : 1, ap : 4,
			desc : "+20% to spend in\nthe cheat shop" };
		case "ad_cheatpool2": return { name : "Cheat Points+", rarity : 2, ap : 6,
			desc : "+30% more to spend in\nthe cheat shop" };
		case "ad_cheatpool3": return { name : "Cheat Points++", rarity : 4, ap : 10,
			desc : "+50% more to spend in\nthe cheat shop" };
		case "ad_cheatcap1": return { name : "Cheat Ceiling", rarity : 2, ap : 6,
			desc : "a cheat shop row may\nreach 140%" };
		case "ad_cheatcap2": return { name : "Cheat Ceiling+", rarity : 4, ap : 10,
			desc : "a cheat shop row may\nreach 170%" };
	}
	return { name : "???", rarity : 0, ap : 0, desc : "" };
}
