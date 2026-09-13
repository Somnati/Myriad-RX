/// @description objective_catchup([all]) - a save that has played but
/// never had objectives (the nudge-era saves) walks the chain from
/// where it stands: every objective whose steps hold RIGHT NOW is
/// marked done, its unlocks and rewards granted QUIETLY (no banners,
/// no "new"), and the walk stops at the first that does not hold -
/// that one becomes the current objective (its holding steps' unlocks
/// granted). Steps are live, so "open X" never holds at load - but a
/// later step's state implies it (objective_step_done), which is what
/// lets a save that rolled an upgrade count "open upgrades" done.
/// all = true completes the whole chain (a save from before the unfold
/// itself: unfold_reveal_all).
function objective_catchup(_all = false) {
	objective_init();
	var _ob = g.obj;
	var _c  = objective_config();
	for (var _i = _ob.i; _i < array_length(_c); _i++) {
		var _o = _c[_i];
		var _st = _o.steps;
		_ob.act[$ _o.key] = true;
		var _hold = true;
		if (!_all)
			for (var _j = 0; _j < array_length(_st); _j++)
				if (!objective_step_done(_o, _j)) { _hold = false; break; }
		if (!_hold) {
			for (var _j = 0; _j < array_length(_st); _j++) {
				var _s = _st[_j];
				if (!objective_step_done(_o, _j)) continue;
				if (variable_struct_exists(_s, "unlocks"))
					for (var _k = 0; _k < array_length(_s.unlocks); _k++) unfold_grant(_s.unlocks[_k], "", true);
			}
			_ob.i = _i;
			return;
		}
		for (var _j = 0; _j < array_length(_st); _j++) {
			var _s = _st[_j];
			if (variable_struct_exists(_s, "unlocks"))
				for (var _k = 0; _k < array_length(_s.unlocks); _k++) unfold_grant(_s.unlocks[_k], "", true);
		}
		if (variable_struct_exists(_o, "reward"))
			for (var _k = 0; _k < array_length(_o.reward); _k++) unfold_grant(_o.reward[_k], "", true);
		_ob.done[$ _o.key] = true;
		_ob.i = _i + 1;
	}
}
