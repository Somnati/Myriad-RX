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

	if (oo) if (a_ == -1) syst_rm_ability.batch_rebirth = _a;
}
