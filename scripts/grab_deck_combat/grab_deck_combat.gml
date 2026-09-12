/// @description grab_deck_combat() - placeholder abilities for the
/// combat engine. these map onto real g.cbal knobs when they wire in.
function grab_deck_combat() {

	ability(g.ad_title_combat, "Combat", 0, 0, "", false, false);

	ability(g.ad_initiative, "Initiative", common, 2,
		"your team opens battles\nwith +20% tic", false, false);
	ability_flavor("+20%", "starting tic", "", -1);

	ability(g.ad_counterschool, "Counter School", uncommon, 4,
		"every pawn gains +3%\ncounter chance", false, false);
	ability_flavor("+3%", "counter", "", -1);

	ability(g.ad_fieldmedic, "Field Medic", rare, 6,
		"survivors mend 10% of max\nhp after each battle", false, false);
	ability_flavor("+10%", "post-battle mend", "", -1);

	ability(g.ad_warcry, "War Cry", legendary, 8,
		"the first attack of every\nbattle is a quality hit", false, false);

	// ---- the second half (2026-09-11): made up, unwired placeholders ----
	ability(g.ad_drillsgt, "Drill Sergeant", common, 2,
		"recruits arrive with\n+10% hp", false, false);
	ability_flavor("+10%", "recruit hp", "", -1);

	ability(g.ad_ambush, "Ambush", uncommon, 3,
		"the enemy's first turn\nis skipped", false, false);

	ability(g.ad_shieldwall, "Shield Wall", rare, 5,
		"pawns standing together\ntake 15% less", false, false);
	ability_flavor("-15%", "flanked damage", "", -1);

	ability(g.ad_lastword, "Last Word", rare, 6,
		"a falling pawn lands one\nfree strike first", false, false);

	ability(g.ad_veterans, "Veterans", legendary, 7,
		"survivors keep 5% of the\nxp they earned", false, false);
	ability_flavor("+5%", "xp kept", "", -1);

	ability(g.ad_ironwill, "Iron Will", epic, 9,
		"once a battle, a killing\nblow leaves 1 hp instead", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_combat = _a;
}
