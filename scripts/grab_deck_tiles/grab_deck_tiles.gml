/// @description grab_deck_tiles() - the Tiles section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_tiles() {

	ability(g.ad_title_tiles, "Tiles", 0, 0, "", false, false);

	ability(g.ad_fabricator, "Fabrication", common, 2,
		"the fabricator runs\n15% faster", false, false);

	_open = false;
	if (g.ad_fabricator == 1) _open = true;
	if (g.ad_fabricator == -1) _open = -1;
	ability(g.ad_fabricator2, "Fabrication+", common, 2,
		"the fabricator runs\nanother 15% faster", true, false);
	if (_open == false) ability_flavor("[requires fabrication]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_fabricator2 == 1) _open = true;
	if (g.ad_fabricator2 == -1) _open = -1;
	ability(g.ad_fabricator3, "Fabrication++", uncommon, 3,
		"the fabricator runs\nanother 25% faster", true, false);
	if (_open == false) ability_flavor("[requires fabrication+]", "", "", c_hred);
	_open = true;

	ability(g.ad_automerger2, "Automerger+", uncommon, 6,
		"the automerger works\n25% faster", false, false);

	_open = false;
	if (g.ad_automerger2 == 1) _open = true;
	if (g.ad_automerger2 == -1) _open = -1;
	ability(g.ad_automerger3, "Automerger++", rare, 7,
		"the automerger works\nanother 40% faster", true, false);
	if (_open == false) ability_flavor("[requires automerger+]", "", "", c_hred);
	_open = true;

	ability(g.ad_duplicator, "Duplicator", common, 3,
		"+15% chance a fabricated\ntile arrives twice", false, false);

	_open = false;
	if (g.ad_duplicator == 1) _open = true;
	if (g.ad_duplicator == -1) _open = -1;
	ability(g.ad_duplicator2, "Duplicator+", uncommon, 5,
		"+20% more chance of\na second tile", true, false);
	if (_open == false) ability_flavor("[requires duplicator]", "", "", c_hred);
	_open = true;

	ability(g.ad_tiermerger1, "Tier Merger", common, 2,
		"+5% chance a merge climbs\nan extra tier", false, false);

	_open = false;
	if (g.ad_tiermerger1 == 1) _open = true;
	if (g.ad_tiermerger1 == -1) _open = -1;
	ability(g.ad_tiermerger2, "Tier Merger+", common, 3,
		"+5% more", true, false);
	if (_open == false) ability_flavor("[requires tier merger]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_tiermerger2 == 1) _open = true;
	if (g.ad_tiermerger2 == -1) _open = -1;
	ability(g.ad_tiermerger3, "Tier Merger++", uncommon, 5,
		"+8% more", true, false);
	if (_open == false) ability_flavor("[requires tier merger+]", "", "", c_hred);
	_open = true;

	ability(g.ad_mergecharger, "Merge Charger", uncommon, 3,
		"every merge charges the\nfabricator by 5%", false, false);

	_open = false;
	if (g.ad_mergecharger == 1) _open = true;
	if (g.ad_mergecharger == -1) _open = -1;
	ability(g.ad_mergecharge1, "Merge Charge+", common, 2,
		"a merge charges\n5% more", true, false);
	if (_open == false) ability_flavor("[requires merge charger]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_mergecharge1 == 1) _open = true;
	if (g.ad_mergecharge1 == -1) _open = -1;
	ability(g.ad_mergecharge2, "Merge Charge++", common, 3,
		"a merge charges\n10% more", true, false);
	if (_open == false) ability_flavor("[requires merge charge+]", "", "", c_hred);
	_open = true;

	ability(g.ad_raritymerger, "Rarity Merger", rare, 7,
		"tile rarity +1% for\nevery 500 merges", false, false);

	ability(g.ad_taptomerge, "Tap to Merge", legendary, 10,
		"every tap fully charges\nthe automerger", false, false);

	ability(g.ad_taptofab, "Tap to Forge", legendary, 10,
		"every tap fully charges\nthe fabricator", false, false);

	ability(g.ad_tilerarity, "Refined Alloys", legendary, 7,
		"tile rarity rate is\nraised by +400", false, false);

	ability(g.ad_hotswap, "Hot Swap", rare, 3,
		"dropping a tile onto a\nmismatched tile swaps them\ninstead of bouncing home", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_tiles = _a;
}
