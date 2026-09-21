/// @description cbt_fight_act(fight, actor, plan) - THE ACTION RESOLVED, the second half of a turn (q227): plan = cbt_ai's { skill (undefined = a basic), target } or one of cbt_fight_options' - a basic through cbt_hit or the skill spending its mp; then the closing (the threshold paid back, the ailment / buff / nerf clocks) and the end (won / routed / the 300-action rail). Clears f.actor
/// A plan whose target is down by the time it runs, or an actor down after
/// its opening, does nothing but the closing (the same guard as before the
/// split). An undefined plan (nothing legal) is the same: the pawn passes
function cbt_fight_act(_f, _actor, _plan) {
	_actor.guard = 0;   // (a guard lasts to the pawn's next action - this one; q246)
	var _pk = is_struct(_plan) ? (_plan[$ "kind"] ?? "") : "";
	// THE MENU'S PLANS (q246, the arena's step two): guard - half of every blow until this pawn's next action (cbt_hit
	// spends it); item - one of the pawn's potions on a chosen target (cbt_use_item); flee - the fight ends as a
	// withdrawal (the trip's rail has the shape). The ai never picks these; the arena's menu does
	if (_pk == "flee") {
		_f.over = true; _f.won = false; _f.withdrew = true; _f.actor = undefined;
		var _tf = _actor.name + " calls the retreat - the crew withdraws";
		cbt_log(_f, _tf); cbt_film(_f, undefined, 0, _tf);
		return;
	}
	if (_pk == "guard" && _actor.hp > 0) { _actor.guard = 1; var _tg = _actor.name + " guards"; cbt_log(_f, _tg); cbt_film(_f, undefined, 0, _tg); }
	else if (_pk == "item" && _actor.hp > 0) cbt_use_item(_f, _actor, _plan.item, _plan.target);
	else if (!is_undefined(_plan) && _pk != "guard" && _pk != "item" && _actor.hp > 0 && _plan.target.hp > 0) {
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
	_actor.tic -= _f.thr;   // (the threshold cbt_fight_next solved)
	// THE CLOCKS run in the actor's own actions (2026-09-17)
	if (is_struct(_actor[$ "ail"])) {
		_actor.ail.poison = max(0, _actor.ail.poison - 1);
		_actor.ail.slow   = max(0, _actor.ail.slow - 1);
		if (_actor.ail.leech > 0) { _actor.ail.leech -= 1; if (_actor.ail.leech <= 0) { _actor.leecher = undefined; cbt_log(_f, "the mark on " + _actor.name + " fades"); } }
	}
	if (is_struct(_actor[$ "bf"])) { _actor.bf.atk = max(0, _actor.bf.atk - 1); _actor.bf.def = max(0, _actor.bf.def - 1); _actor.bf.hit = max(0, _actor.bf.hit - 1); _actor.bf.spd = max(0, _actor.bf.spd - 1); _actor.bf.pres = max(0, (_actor.bf[$ "pres"] ?? 0) - 1); _actor.bf.mres = max(0, (_actor.bf[$ "mres"] ?? 0) - 1); }
	if (is_struct(_actor[$ "nf"])) { _actor.nf.atk = max(0, _actor.nf.atk - 1); _actor.nf.def = max(0, _actor.nf.def - 1); _actor.nf.hit = max(0, _actor.nf.hit - 1); _actor.nf.pres = max(0, (_actor.nf[$ "pres"] ?? 0) - 1); _actor.nf.mres = max(0, (_actor.nf[$ "mres"] ?? 0) - 1); }
	if (is_struct(_actor[$ "ail"])) { _actor.ail.silence = max(0, (_actor.ail[$ "silence"] ?? 0) - 1); }   // (q312's lanes: the silence, the smoke)
	_actor.evade = max(0, (_actor[$ "evade"] ?? 0) - 1);
	if ((_actor[$ "regen"] ?? 0) > 0) _actor.regen -= 1;
	// the end (or the rail: a fight two healers could drag on for ever
	// ends as a withdrawal at 300 actions - attrition should get there first)
	var _alive = [0, 0], _all = _f.all, _n = array_length(_all);
	for (var _i = 0; _i < _n; _i++) if (_all[_i].hp > 0) _alive[_all[_i].team]++;
	if (_f.turn >= 300 && _alive[0] > 0 && _alive[1] > 0) {
		// the rail: neither won nor routed - both sides walk away (bug hunt
		// 2026-09-15: it used to count as a rout, and a rout is a robbery)
		_f.over = true; _f.won = false; _f.withdrew = true; _f.actor = undefined;
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
	_f.actor = undefined;
}
