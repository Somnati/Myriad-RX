/// @description cbt_ai(fight, pawn) -> { skill (undefined = a basic), target } or undefined
/// The tech demo's utility ai, generic forever: enumerate every legal
/// (action, target) pair - the basic attack plus each affordable skill
/// - score each, add a little noise so fights do not loop, take the
/// best. Skills carry their own scoring, so a skill rolled a second
/// ago is played right.
function cbt_ai(_f, _u) {
	var _pawns = _f.all;
	var _best = undefined;
	var _bs = -infinity;
	// the basic: a baseline that favours finishing the wounded
	for (var _i = 0; _i < array_length(_pawns); _i++) {
		var _t = _pawns[_i];
		if (_t.team == _u.team || _t.hp <= 0) continue;
		var _sc = 50 + (1 - _t.hp / _t.maxhp) * 30 + random(12);
		if (_sc > _bs) { _bs = _sc; _best = { skill : undefined, target : _t }; }
	}
	// the skills: affordable + can_use, targets by the skill's own rule
	for (var _k = 0; _k < array_length(_u.skills); _k++) {
		var _s = _u.skills[_k];
		if (_u.mp < _s.cost) continue;
		if (!_s.can_use(_f, _u)) continue;
		for (var _i = 0; _i < array_length(_pawns); _i++) {
			var _t = _pawns[_i];
			if (_t.hp <= 0) continue;
			if (_s.targ == "enemy" && _t.team == _u.team) continue;
			if (_s.targ == "ally"  && _t.team != _u.team) continue;
			if (_s.targ == "self"  && _t != _u) continue;
			var _sc = _s.ai_score(_f, _u, _t);
			if (_sc <= 0) continue;
			_sc += random(10);
			if (_sc > _bs) { _bs = _sc; _best = { skill : _s, target : _t }; }
		}
	}
	return _best;
}
