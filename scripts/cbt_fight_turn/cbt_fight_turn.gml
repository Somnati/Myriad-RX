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
	if (_dt == infinity) { _f.over = true; return; }
	var _ready = [];
	for (var _i = 0; _i < _n; _i++) {
		var _p = _all[_i];
		if (_p.hp <= 0) continue;
		_p.tic += _rts[_i] * _dt;
		if (_p.tic >= _th - .0001) array_push(_ready, _p);
	}
	if (array_length(_ready) == 0) return;
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
	if (_actor.hp > 0 && is_struct(_actor[$ "ab"]) && _actor.ab.mp_haste > 0) _actor.mp = min(_actor.maxmp, _actor.mp + _actor.maxmp * _actor.ab.mp_haste / 100);   // (mp haste: a little every action)
	if (_actor.team == 0 && is_struct(_f[$ "tr"])) exped_drink(_f.tr, _actor, _f);   // the pocket first: a potion when low, a free action (2026-09-16)
	var _plan = cbt_ai(_f, _actor);
	if (!is_undefined(_plan) && _actor.hp > 0 && _plan.target.hp > 0) {
		if (is_undefined(_plan.skill)) cbt_hit(_f, _actor, _plan.target, 1, "", 0, _actor.magic);
		else {
			// a skill: its cost through cbt_skill_cost (frugal), the school on
			// the actor while it runs (dark-touched reads it), the ruse's heal
			// after, the count of skills used (the opening salvo) - 2026-09-17
			var _cost = cbt_skill_cost(_actor, _plan.skill);
			_actor.mp -= _cost;
			_actor.cur_school = _plan.skill[$ "school"] ?? "";
			_plan.skill.effect(_f, _actor, _plan.target);
			_actor.cur_school = "";
			_actor.sk_used = (_actor[$ "sk_used"] ?? 0) + 1;
			if (is_struct(_actor[$ "ab"]) && _actor.ab.ruse > 0 && _actor.hp > 0) cbt_heal(_f, _actor, _actor.maxhp * (_cost / max(1, _actor.maxmp)) * _actor.ab.ruse / 100, "the ruse");
		}
	}
	_actor.acts = (_actor[$ "acts"] ?? 0) + 1;   // (first blood reads it)
	_actor.tic -= _th;
	// THE CLOCKS run in the actor's own actions (2026-09-17)
	if (is_struct(_actor[$ "ail"])) {
		_actor.ail.poison = max(0, _actor.ail.poison - 1);
		_actor.ail.slow   = max(0, _actor.ail.slow - 1);
		if (_actor.ail.leech > 0) { _actor.ail.leech -= 1; if (_actor.ail.leech <= 0) { _actor.leecher = undefined; cbt_log(_f, "the mark on " + _actor.name + " fades"); } }
	}
	if (is_struct(_actor[$ "bf"])) { _actor.bf.atk = max(0, _actor.bf.atk - 1); _actor.bf.def = max(0, _actor.bf.def - 1); _actor.bf.hit = max(0, _actor.bf.hit - 1); _actor.bf.spd = max(0, _actor.bf.spd - 1); }
	if (is_struct(_actor[$ "nf"])) { _actor.nf.atk = max(0, _actor.nf.atk - 1); _actor.nf.def = max(0, _actor.nf.def - 1); _actor.nf.hit = max(0, _actor.nf.hit - 1); }
	if ((_actor[$ "regen"] ?? 0) > 0) _actor.regen -= 1;
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
