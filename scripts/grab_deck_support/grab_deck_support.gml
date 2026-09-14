/// @description grab_deck_support() - the Support section of the deck, Myriad DE's
/// abilities (GENERATED from scratchpad/build_deck.py's table).
function grab_deck_support() {

	ability(g.ad_title_support, "Support", 0, 0, "", false, false);

	ability(g.ad_luckystrike, "Lucky Strike", rare, 7,
		"credits drop from taps\ntwice as often", false, false);

	ability(g.ad_jackpot1, "Jackpot", common, 3,
		"every credit drop\npays one more", false, false);

	ability(g.ad_offlinecollect, "Autocollect", common, 2,
		"profit earned while away\nis collected on arrival", false, false);

	ability(g.ad_bargain, "Bargain Hunter", uncommon, 3,
		"discovering new abilities\ncosts 15% fewer units", false, false);

	ability(g.ad_scholar, "Scholar", legendary, 4,
		"discovered abilities arrive\nalready enabled when the\nap can cover them", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_support = _a;
}
