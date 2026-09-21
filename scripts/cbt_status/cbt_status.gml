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
	if (!is_struct(_t[$ "ail"])) _t.ail = { poison : 0, slow : 0, leech : 0, silence : 0 };
	if (!is_struct(_t[$ "bf"]))  _t.bf  = { atk : 0, def : 0, hit : 0, spd : 0, pres : 0, mres : 0 };
	if (!is_struct(_t[$ "nf"]))  _t.nf  = { atk : 0, def : 0, hit : 0, pres : 0, mres : 0 };
	// (the lanes q312 added, on a pawn made before them)
	if (is_undefined(_t.ail[$ "silence"])) _t.ail.silence = 0;
	if (is_undefined(_t.bf[$ "pres"])) { _t.bf.pres = 0; _t.bf.mres = 0; }
	if (is_undefined(_t.nf[$ "pres"])) { _t.nf.pres = 0; _t.nf.mres = 0; }
	var _tags = is_array(_t[$ "tags"]) ? _t.tags : [];
	var _undead = array_contains(_tags, "undead"), _slime = array_contains(_tags, "slime");
	// the abilities' immunities (antidote / sure-footed / unmarkable, 2026-09-17)
	if (array_contains(_tags, "immune_" + _key)) { cbt_log(_f, _t.name + " shrugs it off"); return false; }
	var _boss = (_t[$ "boss"] ?? false);
	var _turns = max(1, round(_b.ail_turns * (_boss ? _b.boss_ail : 1)));
	if (is_struct(_u) && is_struct(_u[$ "ab"]) && _u.ab.ail_dur > 0) _turns += round(_u.ab.ail_dur);   // (lingering, 2026-09-17)
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
		// THE BARRIER AND THE WARD (q312, his ask - ff7 remake's pair): light; blows through a barrier, spells through a ward,
		// land at barrier_pct less. Their dark mirrors below tear them, and they lift those - the counter, as ever
		case "barrier": case "manaward": {
			var _kb = (_key == "barrier") ? "pres" : "mres";
			if (_t.nf[$ _kb] > 0) { _t.nf[$ _kb] = 0; cbt_log(_f, _who + ((_kb == "pres") ? "'s guard is made whole" : " is warded again")); return true; }
			_t.bf[$ _kb] = _bturns;
			var _tb = _who + ((_kb == "pres") ? " is shielded against blows" : " is warded against magic");
			cbt_log(_f, _tb); cbt_film(_f, _t, 0, _tb);
			return true;
		}
		case "breach": case "unward": {
			var _kn = (_key == "breach") ? "pres" : "mres";
			if (_t.bf[$ _kn] > 0) { _t.bf[$ _kn] = 0; cbt_log(_f, "the " + ((_kn == "pres") ? "barrier" : "ward") + " on " + _who + " is torn away"); return true; }
			_t.nf[$ _kn] = _bturns;
			var _tn = _who + ((_kn == "pres") ? "'s guard is breached" : " is laid open to magic");
			cbt_log(_f, _tn); cbt_film(_f, _t, 0, _tn);
			return true;
		}
		// THE SILENCE (dark, q312): no magic skill while it runs (cbt_fight_options); the SMOKE: half the chance to be hit
		case "silence": {
			_t.ail.silence = _turns;
			cbt_log(_f, _who + " is silenced"); cbt_film(_f, _t, 0, _who + " is silenced");
			return true;
		}
		case "evade": {
			_t.evade = _bturns;
			cbt_log(_f, _who + " slips into the smoke"); cbt_film(_f, _t, 0, _who + " is hard to see");
			return true;
		}
	}
	return false;
}
