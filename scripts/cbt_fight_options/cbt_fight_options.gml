/// @description cbt_fight_options(fight, pawn) -> [{ kind : "basic" | "skill", skill (undefined for the basic), targets : [pawns] }] - EVERY LEGAL PLAN the pawn has this action (q227, the arena's menu): the basic against every living enemy; each skill the pawn can afford (cbt_skill_cost) and can_use, against every living pawn its targ allows (enemy / ally / self)
/// cbt_ai's enumeration with the scoring left out - the one legality rule
/// the menu reads. (cbt_ai keeps its own loop until the arena is tested;
/// step 1b folds it over this list - then a plan the menu offers is exactly
/// one the ai could have picked.) A row with no targets is left out
function cbt_fight_options(_f, _u) {
	var _pawns = _f.all, _out = [];
	var _bt = [];
	for (var _i = 0; _i < array_length(_pawns); _i++) { var _t = _pawns[_i]; if (_t.team == _u.team || _t.hp <= 0) continue; array_push(_bt, _t); }
	if (array_length(_bt) > 0) array_push(_out, { kind : "basic", skill : undefined, targets : _bt });
	for (var _k = 0; _k < array_length(_u.skills); _k++) {
		var _s = _u.skills[_k];
		if (_u.mp < cbt_skill_cost(_u, _s)) continue;
		if (!_s.can_use(_f, _u)) continue;
		if (_s.magic && is_struct(_u[$ "ail"]) && (_u.ail[$ "silence"] ?? 0) > 0) continue;   // (silenced: no magic skill - q312)
		var _ts = [];
		for (var _i = 0; _i < array_length(_pawns); _i++) {
			var _t = _pawns[_i];
			if (_t.hp <= 0) continue;
			if (_s.targ == "enemy" && _t.team == _u.team) continue;
			if (_s.targ == "ally"  && _t.team != _u.team) continue;
			if (_s.targ == "self"  && _t != _u) continue;
			array_push(_ts, _t);
		}
		if (array_length(_ts) > 0) array_push(_out, { kind : "skill", skill : _s, targets : _ts });
	}
	return _out;
}
