/// @description grab_deck_support() - placeholder QoL/automation
/// abilities (the Myriad support section's spirit).
function grab_deck_support() {

	ability(g.ad_title_support, "Support", 0, 0, "", false, false);

	ability(g.ad_onefinger, "One Finger Mode", rare, 0,
		"hold-friendly input\neverywhere", false, false);

	ability(g.ad_autobuy, "Autobuy", common, 0,
		"cheap purchases handle\nthemselves", false, false);

	ability(g.ad_aputilizer, "AP Utilizer", rare, 4,
		"raises max ap by +2", false, false);
	ability_flavor("+2", "max ap", "", c_ap);

	ability(g.ad_luckcharm, "Lucky Charm", uncommon, 3,
		"+5% to every roll that\nmentions luck", false, false);
	ability_flavor("+5%", "luck", "", -1);

	ability(g.ad_notekeeper, "Note Keeper", common, 1,
		"the deck remembers the\nlast card you inspected", false, false);

	// the meta trio - all LIVE, all about the deck itself
	ability(g.ad_bargain, "Bargain Hunter", uncommon, 3,
		"discovering new abilities\ncosts 15% fewer units", false, false);
	ability_flavor("-15%", "discovery cost",
		(g.ad_bargain == 1) ? "(active)" : "", -1);

	ability(g.ad_deeppockets, "Deep Pockets", rare, 2,
		"raises max ap by +4", false, false);
	ability_flavor("+4", "max ap", "", c_ap);

	ability(g.ad_scholar, "Scholar", legendary, 4,
		"discovered abilities arrive\nalready enabled when the\nap can cover them", false, false);

	// ---- the second half (2026-09-11): made up, unwired placeholders ----
	ability(g.ad_alarmclock, "Alarm Clock", common, 1,
		"the welcome-back card\nsays what ran dry, and when", false, false);

	ability(g.ad_archivist, "Archivist", uncommon, 2,
		"the statistics remember\ntwice as far back", false, false);
	ability_flavor("x2", "history", "", -1);

	ability(g.ad_nightowl, "Night Owl", uncommon, 3,
		"the battery drains 10%\nslower while you are away", false, false);
	ability_flavor("-10%", "offline draw", "", -1);

	ability(g.ad_tinkerer, "Tinkerer", rare, 4,
		"the crank charges 25%\nmore per turn", false, false);
	ability_flavor("+25%", "crank", "", -1);

	ability(g.ad_secondwind, "Second Wind", legendary, 6,
		"the time bank fills 20%\nfaster while it is empty", false, false);
	ability_flavor("+20%", "bank fill", "", -1);

	if (oo) if (a_ == -1) syst_rm_ability.batch_support = _a;
}
