/// @description grab_deck_tiles() - placeholder abilities for the
/// tile table. these mirror Myriad's module deck on purpose: when
/// they go live they wire straight into g.tiles (am_mult, fab_t,
/// bonus_rate) and g.tile_rarity. all no-ops for now.
function grab_deck_tiles() {

	ability(g.ad_title_tiles, "Tiles", 0, 0, "", false, false);

	ability(g.ad_automerger, "Automerger", common, 5,
		"the tile table merges\npairs on its own", false, false);

	_open = false;
	if (g.ad_automerger == 1) _open = true;
	if (g.ad_automerger == -1) _open = -1;
	ability(g.ad_automerger2, "Automerger+", uncommon, 6,
		"auto merge interval\nreduced by 20%", true, false);
	ability_flavor("-20%", "merge interval", "", -1);
	if (_open == false) ability_flavor("[requires automerger]", "", "", c_hred);
	_open = true;

	ability(g.ad_fabricator, "Fabrication", common, 2,
		"tiles fabricate\n10% faster", false, false);
	ability_flavor("-10%", "fab time", "", -1);

	_open = false;
	if (g.ad_fabricator == 1) _open = true;
	if (g.ad_fabricator == -1) _open = -1;
	ability(g.ad_fabricator2, "Fabrication+", uncommon, 3,
		"tiles fabricate another\n15% faster", true, false);
	ability_flavor("-15%", "fab time", "", -1);
	if (_open == false) ability_flavor("[requires fabrication]", "", "", c_hred);
	_open = true;

	ability(g.ad_duplicator, "Duplicator", rare, 4,
		"fabricated tiles have a 15%\nchance to arrive twice", false, false);
	ability_flavor("+15%", "dupe chance", "", -1);

	ability(g.ad_tilerarity, "Refined Alloys", legendary, 7,
		"tile rarity rate is\nraised by +400", false, false);
	ability_flavor("+400", "tile rarity", "",
		(g.ad_tilerarity == 1) ? -1 : c_gray);

	// LIVE rule-bender: changes how the tile table's drag works
	ability(g.ad_hotswap, "Hot Swap", rare, 3,
		"dropping a tile onto a\nmismatched tile swaps them\ninstead of bouncing home", false, false);

	// ---- the second half (2026-09-11): made up, unwired placeholders ----
	ability(g.ad_magnet, "Tile Magnet", common, 2,
		"a dropped tile snaps to\nthe nearest matching pair", false, false);

	ability(g.ad_sorter, "Sorting Arm", uncommon, 4,
		"the table tidies itself\nby tier once a minute", false, false);

	ability(g.ad_smelter, "Smelter", rare, 5,
		"three tiles of one tier\nmerge as a single pair", false, false);
	ability_flavor("3 > 1", "merges", "", -1);

	ability(g.ad_overclock, "Overclock", legendary, 7,
		"the fabricator runs at\ndouble speed for 30s\nafter every merge", false, false);
	ability_flavor("x2", "fab burst", "", -1);

	ability(g.ad_goldleaf, "Gold Leaf", epic, 9,
		"a merged tile has a 2%\nchance to skip a tier", false, false);
	ability_flavor("2%", "tier skip", "", -1);

	if (oo) if (a_ == -1) syst_rm_ability.batch_tiles = _a;
}
