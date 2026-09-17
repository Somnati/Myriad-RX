/// @description objective_tick() - THE ONE RUNNER (syst_production's
/// heartbeat calls it every frame; it is a handful of comparisons).
/// Works the current objective's steps LIVE (objective_step_done: a
/// step holds or it does not, this frame), grants a step's unlocks
/// while it holds (unfold_grant is idempotent - once seen, seen), and
/// when the last step holds completes the objective: its reward
/// unfolds, the banner says so, the chain moves on - after THE BREATH
/// (his ask, 2026-09-13: "about 5 seconds between objective batches"):
/// g.obj.gap counts down and the next objective is not worked, nor
/// shown, until it has. Nothing here blocks anything; the card
/// (syst_objectives) and the panel are views over g.obj.
function objective_tick() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	objective_init();
	if (!unfold_has("tap")) return;   // under the veil nothing has begun
	var _ob = g.obj;

	// the breath between batches
	if (_ob.gap > 0) { _ob.gap = max(0, _ob.gap - delta / 60); return; }

	var _c = objective_config();
	if (_ob.i >= array_length(_c)) return;
	var _o = _c[_ob.i];

	// activation, once (the card announces it)
	if (!(_ob.act[$ _o.key] ?? false)) { _ob.act[$ _o.key] = true; save_mark_dirty(); }

	var _all = true;
	for (var _i = 0; _i < array_length(_o.steps); _i++) {
		var _s = _o.steps[_i];
		if (!objective_step_done(_o, _i)) { _all = false; continue; }
		if (variable_struct_exists(_s, "unlocks")) {
			var _bn = _s[$ "banner"] ?? "";
			for (var _k = 0; _k < array_length(_s.unlocks); _k++) {
				unfold_grant(_s.unlocks[_k], _bn);
				_bn = "";   // one banner per step, on its first key
			}
		}
	}
	if (!_all) return;

	// ---- complete ----
	_ob.done[$ _o.key] = true;
	_ob.just = _o.key;
	_ob.i += 1;
	_ob.gap = OBJ_GAP;
	if (variable_struct_exists(_o, "reward")) {
		var _rt = _o[$ "reward_txt"] ?? "";
		for (var _k = 0; _k < array_length(_o.reward); _k++) {
			unfold_grant(_o.reward[_k], _rt);
			_rt = "";
		}
	}
	assign_banner("objective complete - " + _o.name, c_sgreen, c_black);
	ticket_grant("objective");   // every batch leaves a scratch ticket on the desk (2026-09-13)
	ticket_release();            // ...held until the chain is over, then all at once (2026-09-17)
	save_mark_dirty();
}
