/// @description grab_deck_puck() - the Puck section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_puck() {

	ability(g.ad_title_puck, "Puck", 0, 0, "", false, false);

	ability(g.ad_th_bounce1, "Bounce+", common, 5,
		"a throw has seven more\nbounces in it", false, false);

	ability(g.ad_th_bouncegain2, "Bounce Earnings", uncommon, 5,
		"fast bounces pay x5,\nslow bounces x10", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_puck = _a;
}
