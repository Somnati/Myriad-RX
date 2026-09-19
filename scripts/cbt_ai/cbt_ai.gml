/// @description cbt_ai(fight, pawn) -> { skill (undefined = a basic), target } or undefined
/// The tech demo's utility ai, generic forever: enumerate every legal
/// (action, target) pair - the basic attack plus each affordable skill
/// - score each, add a little noise so fights do not loop, take the
/// best. Skills carry their own scoring, so a skill rolled a second
/// ago is played right.
function cbt_ai(_f, _u) {
	if (_u[$ "still"] ?? false) return undefined;   // (a training dummy that stands there - q246)
	// OVER THE ONE LIST (q246, step 1b): cbt_fight_options enumerates what is legal - the basic against every living enemy,
	// each affordable skill against every pawn its targ allows - in the same order this loop always walked, so the rolls
	// below land on the same pawns as before; the menu and the ai can never disagree about what a pawn may do
	var _opts = cbt_fight_options(_f, _u);
	var _best = undefined;
	var _bs = -infinity;
	for (var _o = 0; _o < array_length(_opts); _o++) {
		var _op = _opts[_o];
		for (var _i = 0; _i < array_length(_op.targets); _i++) {
			var _t = _op.targets[_i], _sc;
			if (_op.kind == "basic") _sc = 50 + (1 - _t.hp / _t.maxhp) * 30 + random(12);   // the basic: a baseline that favours finishing the wounded
			else {
				_sc = _op.skill.ai_score(_f, _u, _t);   // skills carry their own scoring, so a skill rolled a second ago is played right
				if (_sc <= 0) continue;
				_sc += random(10);
			}
			if (_sc > _bs) { _bs = _sc; _best = { skill : (_op.kind == "basic") ? undefined : _op.skill, target : _t }; }
		}
	}
	return _best;
}
