/// @description grab_deck_overcharge() - the Overcharge section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_overcharge() {

	ability(g.ad_title_overcharge, "Overcharge", 0, 0, "", false, false);

	ability(g.ad_chargercap, "Charger Cap+", uncommon, 4,
		"the overcharger climbs\nfive levels further", false, false);

	ability(g.ad_chargerate1, "Charge Rate+", uncommon, 3,
		"taps charge the overcharger\ntwice as fast", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_overcharge = _a;
}
