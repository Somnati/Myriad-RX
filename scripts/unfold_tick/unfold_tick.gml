/// @description unfold_tick() - once a second (syst_production's
/// heartbeat calls it every frame; it paces itself): every time-gated
/// row not yet seen is asked; the first whose need is met unfolds -
/// seen for good (unfold_grant: banner, "new" on its menu line), its
/// on() run. One arrival a second - they should not pile up.
function unfold_tick() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	unfold_init();
	var _u = g.unf;
	// "NEW" CLEARS ON THE VISIT (his report, 2026-09-13: it was never going
	// away - the nudge era cleared it on the menu's open, and that code
	// went with the nudges): the moment a fresh feature's panel is up, its
	// line stops saying new
	if (array_length(_u.fresh) > 0) {
		var _vis = "";
		if (instance_exists(syst_upgrades))         _vis = "upgrades";
		else if (instance_exists(syst_tiles))            _vis = "tiles";
		else if (instance_exists(syst_automation_panel)) _vis = "automation";
		else if (instance_exists(syst_rm_ability))       _vis = "abilities";
		else if (instance_exists(syst_timebank_panel))   _vis = "timebank";
		else if (instance_exists(syst_battery_panel))    _vis = "battery";
		else if (instance_exists(syst_ccore_panel))      _vis = "ccore";
		else if (instance_exists(syst_gift_panel))       _vis = "gift";
		else if (instance_exists(syst_exped_panel))      _vis = "expeditions";
		else if (instance_exists(syst_statistics_v2))    _vis = "statistics";
		else if (instance_exists(syst_offlog))           _vis = "offlog";
		else if (instance_exists(syst_rebirth) && syst_rebirth.open) _vis = "rebirth";
		if (_vis != "") {
			var _at = array_get_index(_u.fresh, _vis);
			if (_at >= 0) { array_delete(_u.fresh, _at, 1); save_mark_dirty(); }
		}
	}
	// the veil first: nothing unfolds under it
	if (!unfold_has("tap")) return;
	_u.tic -= delta;
	if (_u.tic > 0) return;
	_u.tic = 60;
	var _c = unfold_config();
	for (var _i = 0; _i < array_length(_c); _i++) {
		var _r = _c[_i];
		if (_u.seen[$ _r.key] ?? false) continue;
		if (!_r.need()) continue;
		unfold_grant(_r.key, _r.banner);
		if (variable_struct_exists(_r, "on") && !is_undefined(_r.on)) _r.on();
		break;
	}
}
