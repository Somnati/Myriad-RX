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

	if (oo) if (a_ == -1) syst_rm_ability.batch_combat = _a;
}
