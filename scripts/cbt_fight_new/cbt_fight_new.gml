/// @description cbt_fight_new(party, foes) -> a fight struct
/// party / foes: arrays of pawns (sprite_pawn / foe_gen). The struct is
/// what the combat window reads (syst_exped_panel): party[k] and b (the
/// first foe) with hp / hpmax / name / col, turn, over, won, log, ev
/// (the film), last (the flash), t (the clock toward the next action).
/// thr = the ATB threshold: the fastest living pawn's rate (the demo's
/// dynamic threshold). all = everyone, for the ai.
function cbt_fight_new(_party, _foes) {
	cbt_balance();
	var _all = [];
	for (var _i = 0; _i < array_length(_party); _i++) { _party[_i].k = _i; _party[_i].team = 0; array_push(_all, _party[_i]); }
	for (var _i = 0; _i < array_length(_foes);  _i++) { _foes[_i].k  = _i; _foes[_i].team  = 1; array_push(_all, _foes[_i]); }
	var _f = {
		party : _party, foes : _foes, all : _all,
		b : _foes[0],
		turn : 0, over : false, won : false,
		log : [], ev : [], t : 0, last : undefined,
		thr : 1,
	};
	return _f;
}
