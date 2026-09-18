/// @description cbt_fight_next(fight) -> the pawn whose action it is (or undefined: the fight is over, or nobody can cross) - THE ATB SOLVED AND THE ACTOR'S OPENING, the first half of a turn (q227, the arena's step one: cbt_fight_turn = next -> cbt_ai -> act)
/// The ATB runs until the next pawn crosses the threshold (solved, not
/// stepped: the time to the nearest crossing, everyone advanced by it; ties
/// break at random - the demo's shuffle); that pawn's opening runs - the
/// venom bites, the regen mends, the mending ability, mp haste, the pocket's
/// potion - and the pawn is handed back as f.actor. Nothing here reads the
/// wall clock, so a caller may hold the actor for as long as it likes
/// (the arena's menu) before cbt_fight_act resolves the plan. The actor
/// may be DOWN after its opening (the venom): the wrapper still asks the
/// ai and the act's guard skips the blow - the same rolls as before the split
function cbt_fight_next(_f) {
	if (_f.over) return undefined;
	var _b = cbt_balance();
	var _all = _f.all;
	var _n = array_length(_all);
	// the threshold: the fastest living pawn's rate (its base - slow and
	// haste bend a pawn's own fill, below, not the bar)
	var _th = 1;
	for (var _i = 0; _i < _n; _i++) if (_all[_i].hp > 0 && _all[_i].tic_spd > _th) _th = _all[_i].tic_spd;
	_f.thr = _th;
	// each pawn's LIVE rate: slowed (water's ailment) fills at slow_rate,
	// hastened (light) at haste_rate (2026-09-17)
	var _rts = array_create(_n, 0);
	for (var _i = 0; _i < _n; _i++) {
		var _p0 = _all[_i];
		var _rt = _p0.tic_spd;
		if (is_struct(_p0[$ "ail"]) && _p0.ail.slow > 0) _rt *= _b.slow_rate;
		if (is_struct(_p0[$ "bf"]) && _p0.bf.spd > 0) _rt *= _b.haste_rate;
		_rts[_i] = _rt;
	}
	// the time to the next crossing, and the crossing
	var _dt = infinity;
	for (var _i = 0; _i < _n; _i++) {
		var _p = _all[_i];
		if (_p.hp <= 0) continue;
		var _need = max(0, (_th - _p.tic) / max(.01, _rts[_i]));
		if (_need < _dt) _dt = _need;
	}
	if (_dt == infinity) { _f.over = true; return undefined; }
	var _ready = [];
	for (var _i = 0; _i < _n; _i++) {
		var _p = _all[_i];
		if (_p.hp <= 0) continue;
		_p.tic += _rts[_i] * _dt;
		if (_p.tic >= _th - .0001) array_push(_ready, _p);
	}
	if (array_length(_ready) == 0) return undefined;
	var _actor = _ready[irandom(array_length(_ready) - 1)];
	_f.turn += 1;
	// THE ACTION'S OPENING: the venom bites, the regen mends (2026-09-17)
	if (is_struct(_actor[$ "ail"]) && _actor.ail.poison > 0 && _actor.hp > 0) {
		var _pd = max(1, round(_actor.maxhp * _b.poison_pct));
		_actor.hp = max(0, _actor.hp - _pd);
		_actor.dt = (_actor[$ "dt"] ?? 0) + _pd;
		var _tp = _actor.name + " is hurt by the venom for " + string(_pd);
		cbt_log(_f, _tp); cbt_film(_f, _actor, _pd, _tp);
		if (_actor.hp <= 0) { cbt_log(_f, _actor.name + " is down"); cbt_film(_f, undefined, 0, _actor.name + " is down"); }
	}
	if (_actor.hp > 0 && (_actor[$ "regen"] ?? 0) > 0) cbt_heal(_f, _actor, _actor.maxhp * _b.regen_pct, "regen");
	if (_actor.hp > 0 && is_struct(_actor[$ "ab"]) && _actor.ab.regen > 0) cbt_heal(_f, _actor, _actor.maxhp * _actor.ab.regen / 100, "");   // (the mending ability, 2026-09-17)
	if (_actor.hp > 0 && is_struct(_actor[$ "ab"]) && _actor.ab.mp_haste != 0) _actor.mp = clamp(_actor.mp + _actor.maxmp * _actor.ab.mp_haste / 100, 0, _actor.maxmp);   // (mp haste: a little every action; leaky: a little less)
	if (_actor.team == 0 && is_struct(_f[$ "tr"])) exped_drink(_f.tr, _actor, _f);   // the pocket first: a potion when low, a free action (2026-09-16)
	_f.actor = _actor;
	return _actor;
}
