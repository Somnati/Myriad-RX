/// @description grab_deck_upgrades() - the Upgrades section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_upgrades() {

	ability(g.ad_title_upgrades, "Upgrades", 0, 0, "", false, false);

	ability(g.ad_topgrade1, "Top Grade", common, 2,
		"rarer upgrades roll\n20% more often", false, false);

	_open = false;
	if (g.ad_topgrade1 == 1) _open = true;
	if (g.ad_topgrade1 == -1) _open = -1;
	ability(g.ad_topgrade2, "Top Grade+", uncommon, 3,
		"rarer upgrades roll\n30% more often still", true, false);
	if (_open == false) ability_flavor("[requires top grade]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_topgrade2 == 1) _open = true;
	if (g.ad_topgrade2 == -1) _open = -1;
	ability(g.ad_topgrade3, "Top Grade++", rare, 5,
		"rarer upgrades roll\n50% more often still", true, false);
	if (_open == false) ability_flavor("[requires top grade+]", "", "", c_hred);
	_open = true;

	ability(g.ad_upgradetier, "Upgrade Tier+", uncommon, 5,
		"upgrades roll with up to\ntwo more tiers", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_upgrades = _a;
}
