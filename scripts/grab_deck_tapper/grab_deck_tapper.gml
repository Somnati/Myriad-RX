/// @description grab_deck_tapper() - the Tapper section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_tapper() {

	ability(g.ad_title_tapper, "Tapper", 0, 0, "", false, false);

	ability(g.ad_critical, "Critical Taps", common, 2,
		"the tapper can land\ncritical hits", false, false);

	_open = false;
	if (g.ad_critical == 1) _open = true;
	if (g.ad_critical == -1) _open = -1;
	ability(g.ad_critrate1, "Critical Rate+", common, 3,
		"the base critical chance\nis doubled", true, false);
	if (_open == false) ability_flavor("[requires critical taps]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_critrate1 == 1) _open = true;
	if (g.ad_critrate1 == -1) _open = -1;
	ability(g.ad_critrate2, "Critical Rate++", common, 2,
		"all critical chance\n+200%", true, false);
	if (_open == false) ability_flavor("[requires critical rate+]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_critrate2 == 1) _open = true;
	if (g.ad_critrate2 == -1) _open = -1;
	ability(g.ad_critrate3, "Critical Rate+++", uncommon, 3,
		"all critical chance\n+300%", true, false);
	if (_open == false) ability_flavor("[requires critical rate++]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_critical == 1) _open = true;
	if (g.ad_critical == -1) _open = -1;
	ability(g.ad_critcut1, "Critical Cut", common, 4,
		"halves the crit rate,\ndoubles the crit multiplier", true, false);
	if (_open == false) ability_flavor("[requires critical taps]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_critcut1 == 1) _open = true;
	if (g.ad_critcut1 == -1) _open = -1;
	ability(g.ad_critcut2, "Critical Cut+", common, 4,
		"halves the crit rate again,\ndoubles the multiplier again", true, false);
	if (_open == false) ability_flavor("[requires critical cut]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_critcut2 == 1) _open = true;
	if (g.ad_critcut2 == -1) _open = -1;
	ability(g.ad_critcut3, "Critical Cut++", common, 4,
		"and once more: half the\nrate, twice the multiplier", true, false);
	if (_open == false) ability_flavor("[requires critical cut+]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_critical == 1) _open = true;
	if (g.ad_critical == -1) _open = -1;
	ability(g.ad_criticalsyphon, "Critical Syphon", uncommon, 5,
		"the dials share your\ncritical rate and multiplier", true, false);
	if (_open == false) ability_flavor("[requires critical taps]", "", "", c_hred);
	_open = true;

	ability(g.ad_tappersyphon1, "Tapper Syphon", rare, 7,
		"a tap also pays 1% of what\nthe dials make a second", false, false);

	_open = false;
	if (g.ad_tappersyphon1 == 1) _open = true;
	if (g.ad_tappersyphon1 == -1) _open = -1;
	ability(g.ad_tappersyphon2, "Tapper Syphon+", rare, 10,
		"the syphon takes\nanother 10%", true, false);
	if (_open == false) ability_flavor("[requires tapper syphon]", "", "", c_hred);
	_open = true;

	_open = false;
	if (g.ad_tappersyphon2 == 1) _open = true;
	if (g.ad_tappersyphon2 == -1) _open = -1;
	ability(g.ad_tappersyphon3, "Tapper Syphon++", legendary, 15,
		"the syphon takes\nanother 50%", true, false);
	if (_open == false) ability_flavor("[requires tapper syphon+]", "", "", c_hred);
	_open = true;

	if (oo) if (a_ == -1) syst_rm_ability.batch_tapper = _a;
}
