/// @description grab_deck_rebirth() - the Rebirth section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_rebirth() {

	ability(g.ad_title_rebirth, "Rebirth", 0, 0, "", false, false);

	ability(g.ad_networth, "Networth", legendary, 5,
		"rebirth counts the profit\nyou spent, not only what\nyou hold", false, false);

	ability(g.ad_resetbracer, "Reset Bracer", rare, 5,
		"every dial keeps one level\nthrough a rebirth", false, false);

	_open = false;
	if (g.ad_resetbracer == 1) _open = true;
	if (g.ad_resetbracer == -1) _open = -1;
	ability(g.ad_resetbracer2, "Reset Bracer+", legendary, 10,
		"every dial keeps all its\nlevels through a rebirth", true, false);
	if (_open == false) ability_flavor("[requires reset bracer]", "", "", c_hred);
	_open = true;

	ability(g.ad_cheatpool1, "Cheat Points", uncommon, 4,
		"+20% to spend in\nthe cheat shop", false, false);

	_open = false;
	if (g.ad_cheatpool1 == 1) _open = true;
	if (g.ad_cheatpool1 == -1) _open = -1;
	ability(g.ad_cheatpool2, "Cheat Points+", rare, 6,
		"+30% more to spend in\nthe cheat shop", true, false);
	if (_open == false) ability_flavor("[requires cheat points]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_cheatpool2 == 1) _open = true;
	if (g.ad_cheatpool2 == -1) _open = -1;
	ability(g.ad_cheatpool3, "Cheat Points++", epic, 10,
		"+50% more to spend in\nthe cheat shop", true, false);
	if (_open == false) ability_flavor("[requires cheat points+]", "", "", c_hred);
	_open = true;

	ability(g.ad_cheatcap1, "Cheat Ceiling", rare, 6,
		"a cheat shop row may\nreach 140%", false, false);

	_open = false;
	if (g.ad_cheatcap1 == 1) _open = true;
	if (g.ad_cheatcap1 == -1) _open = -1;
	ability(g.ad_cheatcap2, "Cheat Ceiling+", epic, 10,
		"a cheat shop row may\nreach 170%", true, false);
	if (_open == false) ability_flavor("[requires cheat ceiling]", "", "", c_hred);
	_open = true;

	if (oo) if (a_ == -1) syst_rm_ability.batch_rebirth = _a;
}
