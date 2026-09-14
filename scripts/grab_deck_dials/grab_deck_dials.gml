/// @description grab_deck_dials() - the Dials section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_dials() {

	ability(g.ad_title_dials, "Dials", 0, 0, "", false, false);

	ability(g.ad_patientpayload, "Patient Payload", uncommon, 3,
		"a dial pays +1% for every\nsecond its cycle takes", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_dials = _a;
}
