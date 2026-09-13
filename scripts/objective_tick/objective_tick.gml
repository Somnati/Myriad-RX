/// @description objective_tick() - THE ONE RUNNER (syst_production's
/// heartbeat calls it every frame; it is a few instance_exists and a
/// handful of comparisons). Watches what the player DOES (the drawer's
/// stages, the menu, the panels - the flags), works the current
/// objective's steps, grants a step's unlocks the moment it ticks, and
/// on the last tick completes the objective: its reward unfolds, the
/// banner says so, the chain moves on. Nothing here blocks anything;
/// the card (syst_objectives) and the panel are views over g.obj.
function objective_tick() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	objective_init();
	if (!unfold_has("tap")) return;   // under the veil nothing has begun
	var _ob = g.obj;

	// ---- what the game has seen ----
	if (instance_exists(syst_dials)) {
		if (syst_dials.stage >= 1) _ob.flags.drawer1 = true;
		if (syst_dials.stage >= 2) _ob.flags.drawer2 = true;
	}
	if (instance_exists(syst_menu2))            _ob.flags.menu         = true;
	if (instance_exists(syst_upgrades))         _ob.flags.upg_open     = true;
	if (instance_exists(syst_automation_panel)) _ob.flags.autom_open   = true;
	if (instance_exists(syst_tiles))            _ob.flags.tiles_open   = true;
	if (instance_exists(syst_rm_ability))       _ob.flags.abil_open    = true;
	if (instance_exists(syst_ccore_panel))      _ob.flags.ccore_open   = true;
	if (instance_exists(syst_rebirth) && syst_rebirth.open) _ob.flags.rebirth_open = true;

	// ---- the objective being worked ----
	var _c = objective_config();
	if (_ob.i >= array_length(_c)) return;
	var _o = _c[_ob.i];

	// activation, once: the card arrives; nothing else happens here -
	// unlocks ride the STEPS, so a feature appears when the step that
	// earns it ticks, not when the objective is merely reached
	if (!(_ob.act[$ _o.key] ?? false)) { _ob.act[$ _o.key] = true; save_mark_dirty(); }

	var _all = true;
	for (var _i = 0; _i < array_length(_o.steps); _i++) {
		var _s  = _o.steps[_i];
		var _fk = _o.key + ":" + string(_i);
		if (_ob.flags[$ _fk] ?? false) continue;   // ticked, and it stays ticked
		var _d = variable_struct_exists(_s, "flag") ? (_ob.flags[$ _s.flag] ?? false) : _s.done();
		if (!_d) { _all = false; continue; }
		_ob.flags[$ _fk] = true;
		if (variable_struct_exists(_s, "unlocks")) {
			var _bn = _s[$ "banner"] ?? "";
			for (var _k = 0; _k < array_length(_s.unlocks); _k++) {
				unfold_grant(_s.unlocks[_k], _bn);
				_bn = "";   // one banner per step, on its first key
			}
		}
		save_mark_dirty();
	}
	if (!_all) return;

	// ---- complete ----
	_ob.done[$ _o.key] = true;
	_ob.just = _o.key;
	_ob.i += 1;
	if (variable_struct_exists(_o, "reward")) {
		var _rt = _o[$ "reward_txt"] ?? "";
		for (var _k = 0; _k < array_length(_o.reward); _k++) {
			unfold_grant(_o.reward[_k], _rt);
			_rt = "";
		}
	}
	assign_banner("objective complete - " + _o.name, c_sgreen, c_black);
	play_sound_ext(snd_apply, 1.05, 1.2, .55, 1);
	save_mark_dirty();
}
