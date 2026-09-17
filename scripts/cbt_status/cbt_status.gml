/// @description cbt_status(fight, user, target, key) -> true if it landed
/// THE ONE PLACE an ailment, a buff or a nerf goes on (his design,
/// 2026-09-17). Keys: poison / slow / leech (the ailments: nature / water /
/// dark), regen, buf_atk / buf_def / buf_hit / haste (light), nerf_atk /
/// nerf_def / nerf_hit (dark).
///
/// THE COUNTER (his rule): light and dark cancel on a target. A nerf
/// landing on a buffed stat lifts the buff instead of stacking under it;
/// a buff landing on a nerfed stat lifts the nerf. Haste and slow are the
/// one pair across a school and an element: a hasted pawn slowed ends at
/// normal, a slowed pawn hasted is freed. Same-key reapplies REFRESH the
/// clock, never stack the bite. Clocks are in the VICTIM'S actions
/// (cbt_fight_turn counts them down as it acts).
///
/// Immunities: slimes and the undead ignore poison, the undead cannot be
/// leeched (nothing to give); a boss takes an ailment at boss_ail of the
/// turns. Everything ends with the fight - the pawns are the fight's.
function cbt_status(_f, _u, _t, _key) {
	var _b = cbt_balance();
	if (_t.hp <= 0) return false;
	if (!is_struct(_t[$ "ail"])) _t.ail = { poison : 0, slow : 0, leech : 0 };
	if (!is_struct(_t[$ "bf"]))  _t.bf  = { atk : 0, def : 0, hit : 0, spd : 0 };
	if (!is_struct(_t[$ "nf"]))  _t.nf  = { atk : 0, def : 0, hit : 0 };
	var _tags = is_array(_t[$ "tags"]) ? _t.tags : [];
	var _undead = array_contains(_tags, "undead"), _slime = array_contains(_tags, "slime");
	var _boss = (_t[$ "boss"] ?? false);
	var _turns = max(1, round(_b.ail_turns * (_boss ? _b.boss_ail : 1)));
	var _bturns = max(1, round(_b.buff_turns * ((_boss && _t.team == 1) ? _b.boss_ail : 1)));
	var _who = _t.name;
	switch (_key) {
		case "poison":
			if (_undead || _slime) { cbt_log(_f, _who + " does not mind the venom"); return false; }
			_t.ail.poison = _turns;
			cbt_log(_f, _who + " is poisoned"); cbt_film(_f, _t, 0, _who + " is poisoned");
			return true;
		case "slow":
			if (_t.bf.spd > 0) { _t.bf.spd = 0; cbt_log(_f, _who + "'s haste is undone"); return true; }
			_t.ail.slow = _turns;
			cbt_log(_f, _who + " is slowed"); cbt_film(_f, _t, 0, _who + " is slowed");
			return true;
		case "leech":
			if (_undead) { cbt_log(_f, _who + " has nothing to give"); return false; }
			_t.ail.leech = _turns; _t.leecher = _u;
			cbt_log(_f, _who + " is marked - " + _u.name + " feeds on every hit"); cbt_film(_f, _t, 0, _who + " is marked");
			return true;
		case "regen":
			_t.regen = _bturns;
			cbt_log(_f, _who + " mends a little each turn"); return true;
		case "haste":
			if (_t.ail.slow > 0) { _t.ail.slow = 0; cbt_log(_f, _who + " shakes the slow off"); return true; }
			_t.bf.spd = _bturns;
			cbt_log(_f, _who + " is hastened"); cbt_film(_f, _t, 0, _who + " is hastened");
			return true;
		case "buf_atk": case "buf_def": case "buf_hit": {
			var _k = string_delete(_key, 1, 4);
			if (_t.nf[$ _k] > 0) { _t.nf[$ _k] = 0; cbt_log(_f, "the " + _k + " nerf on " + _who + " lifts"); return true; }
			_t.bf[$ _k] = _bturns;
			cbt_log(_f, _who + "'s " + _k + " is raised"); cbt_film(_f, _t, 0, _who + "'s " + _k + " is raised");
			return true;
		}
		case "nerf_atk": case "nerf_def": case "nerf_hit": {
			var _k2 = string_delete(_key, 1, 5);
			if (_t.bf[$ _k2] > 0) { _t.bf[$ _k2] = 0; cbt_log(_f, "the " + _k2 + " buff on " + _who + " is undone"); return true; }
			_t.nf[$ _k2] = _bturns;
			cbt_log(_f, _who + "'s " + _k2 + " is lowered"); cbt_film(_f, _t, 0, _who + "'s " + _k2 + " is lowered");
			return true;
		}
	}
	return false;
}
