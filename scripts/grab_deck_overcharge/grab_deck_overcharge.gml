/// @description grab_deck_overcharge() - the Overcharge section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_overcharge() {

	ability(g.ad_title_overcharge, "Overcharge", 0, 0, "", false, false);

	ability(g.ad_overtapper, "Overcharge", common, 3,
		"keep tapping to charge a\nmultiplier on every tap -\nstop, and it drains", false, false);

	_open = false;
	if (g.ad_overtapper == 1) _open = true;
	if (g.ad_overtapper == -1) _open = -1;
	ability(g.ad_chargercap, "Charger Cap+", uncommon, 4,
		"the overcharger climbs\nfive levels further", true, false);
	if (_open == false) ability_flavor("[requires overcharge]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_overtapper == 1) _open = true;
	if (g.ad_overtapper == -1) _open = -1;
	ability(g.ad_chargerate1, "Charge Rate+", uncommon, 3,
		"taps charge the overcharger\ntwice as fast", true, false);
	if (_open == false) ability_flavor("[requires overcharge]", "", "", c_hred);
	_open = true;

	if (oo) if (a_ == -1) syst_rm_ability.batch_overcharge = _a;
}
