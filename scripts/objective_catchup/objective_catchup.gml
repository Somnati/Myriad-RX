/// @description objective_catchup([all]) - a save that has played but
/// never had objectives (the nudge-era saves) walks the chain from
/// where it stands: every objective whose state-steps already hold is
/// marked done, its unlocks and rewards granted QUIETLY (no banners, no
/// "new"), and the walk stops at the first that does not hold - that
/// one becomes the current objective, with its already-true steps
/// ticked. A step the game can only SEE (a swipe, an open) is taken
/// as done during the walk - nobody is re-taught a swipe. all = true
/// completes the whole chain (a save from before the unfold itself:
/// unfold_reveal_all).
function objective_catchup(_all = false) {
	objective_init();
	var _ob = g.obj;
	var _c  = objective_config();
	for (var _i = _ob.i; _i < array_length(_c); _i++) {
		var _o = _c[_i];
		var _hold = true;
		var _st = _o.steps;
		if (!_all)
			for (var _j = 0; _j < array_length(_st); _j++) {
				var _s = _st[_j];
				if (variable_struct_exists(_s, "flag")) continue;
				if (!_s.done()) { _hold = false; break; }
			}
		_ob.act[$ _o.key] = true;
		if (!_hold) {
			// the current one: tick what already holds (state steps only)
			for (var _j = 0; _j < array_length(_st); _j++) {
				var _s = _st[_j];
				if (variable_struct_exists(_s, "flag")) continue;
				if (!_s.done()) continue;
				_ob.flags[$ _o.key + ":" + string(_j)] = true;
				if (variable_struct_exists(_s, "unlocks"))
					for (var _k = 0; _k < array_length(_s.unlocks); _k++) unfold_grant(_s.unlocks[_k], "", true);
			}
			_ob.i = _i;
			return;
		}
		for (var _j = 0; _j < array_length(_st); _j++) {
			var _s = _st[_j];
			_ob.flags[$ _o.key + ":" + string(_j)] = true;
			if (variable_struct_exists(_s, "flag")) _ob.flags[$ _s.flag] = true;
			if (variable_struct_exists(_s, "unlocks"))
				for (var _k = 0; _k < array_length(_s.unlocks); _k++) unfold_grant(_s.unlocks[_k], "", true);
		}
		if (variable_struct_exists(_o, "reward"))
			for (var _k = 0; _k < array_length(_o.reward); _k++) unfold_grant(_o.reward[_k], "", true);
		_ob.done[$ _o.key] = true;
		_ob.i = _i + 1;
	}
}
