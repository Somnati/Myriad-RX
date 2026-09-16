/// @description cbt_fight_turn(fight) - ONE ACTION: the ATB runs until
/// the next pawn crosses the threshold (solved, not stepped: the time
/// to the nearest crossing, everyone advanced by it; ties break at
/// random - the demo's shuffle), that pawn acts by the ai (a basic
/// through cbt_hit or a skill spending its mp), pays the threshold
/// back, and the fight checks for an end: every foe down = won, every
/// member down = routed. Headless and clockless - the caller decides
/// how much wall time an action takes (EXPED_FIGHT_T).
function cbt_fight_turn(_f) {
	if (_f.over) return;
	var _all = _f.all;
	var _n = array_length(_all);
	// the threshold: the fastest living pawn's rate
	var _th = 1;
	for (var _i = 0; _i < _n; _i++) if (_all[_i].hp > 0 && _all[_i].tic_spd > _th) _th = _all[_i].tic_spd;
	_f.thr = _th;
	// the time to the next crossing, and the crossing
	var _dt = infinity;
	for (var _i = 0; _i < _n; _i++) {
		var _p = _all[_i];
		if (_p.hp <= 0) continue;
		var _need = max(0, (_th - _p.tic) / max(.01, _p.tic_spd));
		if (_need < _dt) _dt = _need;
	}
	if (_dt == infinity) { _f.over = true; return; }
	var _ready = [];
	for (var _i = 0; _i < _n; _i++) {
		var _p = _all[_i];
		if (_p.hp <= 0) continue;
		_p.tic += _p.tic_spd * _dt;
		if (_p.tic >= _th - .0001) array_push(_ready, _p);
	}
	if (array_length(_ready) == 0) return;
	var _actor = _ready[irandom(array_length(_ready) - 1)];
	_f.turn += 1;
	if (_actor.team == 0 && is_struct(_f[$ "tr"])) exped_drink(_f.tr, _actor, _f);   // the pocket first: a potion when low, a free action (2026-09-16)
	var _plan = cbt_ai(_f, _actor);
	if (!is_undefined(_plan) && _actor.hp > 0 && _plan.target.hp > 0) {
		if (is_undefined(_plan.skill)) cbt_hit(_f, _actor, _plan.target, 1, "", 0, _actor.magic);
		else { _actor.mp -= _plan.skill.cost; _plan.skill.effect(_f, _actor, _plan.target); }
	}
	_actor.tic -= _th;
	// the end (or the rail: a fight two healers could drag on for ever
	// ends as a withdrawal at 300 actions - attrition should get there first)
	var _alive = [0, 0];
	for (var _i = 0; _i < _n; _i++) if (_all[_i].hp > 0) _alive[_all[_i].team]++;
	if (_f.turn >= 300 && _alive[0] > 0 && _alive[1] > 0) {
		// the rail: neither won nor routed - both sides walk away (bug hunt
		// 2026-09-15: it used to count as a rout, and a rout is a robbery)
		_f.over = true; _f.won = false; _f.withdrew = true;
		var _t7 = "the fight drags on - both sides withdraw";
		cbt_log(_f, _t7);
		cbt_film(_f, undefined, 0, _t7);
		return;
	}
	if (_alive[0] == 0 || _alive[1] == 0) {
		_f.over = true;
		_f.won  = (_alive[0] > 0);
		var _t6 = _f.won ? ((array_length(_f.foes) > 1) ? "the last of them falls" : (_f.b.name + " falls")) : "the crew is routed";
		cbt_log(_f, _t6);
		cbt_film(_f, undefined, 0, _t6);
	}
}
