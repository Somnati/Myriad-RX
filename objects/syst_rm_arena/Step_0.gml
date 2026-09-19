// THE FIGHT'S LOOP (the spec's 1.2): next -> the menu (a party pawn) or the ai after a beat -> act; pauses at every party action by construction
if (page == "fight" && is_struct(f)) {
	if (f.over) { res = __result(); page = "result"; }
	else if (beat > 0) beat -= delta;
	else if (is_undefined(f.actor)) {
		var _a = cbt_fight_next(f);
		if (!is_undefined(_a)) {
			if (_a.team == 1 || auto || _a.hp <= 0) { pending = true; beat = __beat(); }
			else __menu_open();
		}
	}
	else if (pending) { pending = false; cbt_fight_act(f, f.actor, cbt_ai(f, f.actor)); beat = __beat(); }
	if (is_struct(f) && array_length(f.log) > log_n) { last_line = f.log[array_length(f.log) - 1]; last_t = 40; log_n = array_length(f.log); }
}
if (last_t > 0) last_t -= delta;

// ---- input (region pattern, arbitrated) ----
if (!input_free()) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
// the wheel: the crew list under the left column, the creature grid under the right (q257)
if (page == "setup" && mouse_x < 164) {
	if (mouse_wheel_up()) crew_scroll = max(0, crew_scroll - 13);
	if (mouse_wheel_down()) crew_scroll = min(max(0, array_length(__crew_list()) * 13 - 150), crew_scroll + 13);
} else if (page == "setup" && tab == "opponent" && opp == "creature") {
	var _krows = ceil(array_length(foe_roster()) / 3), _kvis = floor((room_height - 30 - (bby + 74)) / 13);
	if (mouse_wheel_up()) kind_scroll = max(0, kind_scroll - 1);
	if (mouse_wheel_down()) kind_scroll = clamp(kind_scroll + 1, 0, max(0, _krows - _kvis));
}
if (!mouse_check_button_pressed(mb_left)) exit;

if (__hit(__back_r())) { play_sound_ext(snd_matclick2, .8, .9, .5, 1); back_room(); exit; }

if (page == "setup") {
	// the crew: a tap picks / unpicks, up to the party's size (the customs listed first - q257)
	var _cl = __crew_list();
	for (var _i = 0; _i < array_length(_cl); _i++) {
		var _cr = __crew_r(_i);
		if (_cr.y < bby + 34 || _cr.y > room_height - 40) continue;
		if (!__hit(_cr)) continue;
		var _id = _cl[_i].id, _at = -1;
		for (var _k = 0; _k < array_length(picked); _k++) if (picked[_k] == _id) _at = _k;
		if (_at >= 0) array_delete(picked, _at, 1); else if (array_length(picked) < exped_party_max()) array_push(picked, _id);
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		exit;
	}
	// the tabs (q257)
	var _tabs = ["opponent", "place", "custom"];
	for (var _t = 0; _t < 3; _t++) if (__hit(__tab_r(_t))) { tab = _tabs[_t]; if (tab == "custom" && is_undefined(cu_preview)) cu_preview = __custom_make(); play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	if (tab == "opponent") {
		if (__hit(__opp_pill_r(0))) { opp = "dummy"; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
		if (__hit(__opp_pill_r(1))) { opp = "creature"; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
		if (opp == "dummy") {
			if (__hit(__dum_r(0, 1))) { d_hp = max(1, d_hp - 1); exit; }
			if (__hit(__dum_r(0, 2))) { d_hp = min(5, d_hp + 1); exit; }
			if (__hit(__dum_r(1, 1))) { d_arm = max(0, d_arm - 1); exit; }
			if (__hit(__dum_r(1, 2))) { d_arm = min(3, d_arm + 1); exit; }
			if (__hit(__dum_r(2, 0)) || __hit(__dum_r(2, 1)) || __hit(__dum_r(2, 2))) { d_hits = !d_hits; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
		} else {
			if (__hit(__clv_r(1))) { c_lv = max(1, c_lv - 1); exit; }
			if (__hit(__clv_r(2))) { c_lv = min(30, c_lv + 1); exit; }
			if (__hit(__cn_r(1))) { c_n = max(1, c_n - 1); exit; }
			if (__hit(__cn_r(2))) { c_n = min(3, c_n + 1); exit; }
			var _ros = foe_roster();
			for (var _i = 0; _i < array_length(_ros); _i++) {
				var _kr = __kind_r(_i); _kr.y -= kind_scroll * 13;
				if (_kr.y < bby + 74 || _kr.y + _kr.h > room_height - 30) continue;
				if (__hit(_kr)) { c_kind = _i; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
			}
		}
	} else if (tab == "place") {
		for (var _i = 0; _i < array_length(p_lands); _i++) if (__hit(__land_r(_i))) { p_land = p_lands[_i]; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
		for (var _k = 0; _k < 5; _k++) if (__hit(__seas_r(_k))) { p_season = _k - 1; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
		// a native chip: that kind becomes the opponent
		var _nat = foe_kinds_at(p_land, p_season), _ros2 = foe_roster();
		for (var _i = 0; _i < array_length(_nat); _i++) if (__hit(__nat_r(_i))) {
			for (var _r = 0; _r < array_length(_ros2); _r++) if (_ros2[_r].name == _nat[_i]) { c_kind = _r; opp = "creature"; }
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit;
		}
	} else {
		// THE CUSTOM SPRITE's knobs: every turn rebuilds the preview off the same seed
		var _dirty = false;
		for (var _k = 0; _k < array_length(sprite_classes()); _k++) if (__hit(__ccls_r(_k))) { cu_cls = _k; _dirty = true; }
		if (__hit(__cu_r(0, 1))) { cu_lv = max(1, cu_lv - 1); _dirty = true; }
		if (__hit(__cu_r(0, 2))) { cu_lv = min(30, cu_lv + 1); _dirty = true; }
		if (__hit(__cu_r(1, 1))) { cu_rar = max(-1, cu_rar - 1); _dirty = true; }
		if (__hit(__cu_r(1, 2))) { cu_rar = min(7, cu_rar + 1); _dirty = true; }
		if (__hit(__cu_r(2, 1))) { cu_skills = max(0, cu_skills - 1); _dirty = true; }
		if (__hit(__cu_r(2, 2))) { cu_skills = min(SPRITE_SKILLS - 1, cu_skills + 1); _dirty = true; }
		if (__hit(__cu_r(3, 1))) { cu_pots = max(0, cu_pots - 1); _dirty = true; }
		if (__hit(__cu_r(3, 2))) { cu_pots = min(3, cu_pots + 1); _dirty = true; }
		if (__hit(__cubtn_r(0))) { cu_seed = irandom($7fffffff); _dirty = true; }
		if (__hit(__cubtn_r(1)) && is_struct(cu_preview)) {
			// into the crew list, and into the party if there is room; the next preview takes a fresh seed
			array_push(customs, cu_preview);
			if (array_length(picked) < exped_party_max()) array_push(picked, cu_preview.id);
			cu_seed = irandom($7fffffff); cu_preview = __custom_make();
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit;
		}
		if (__hit(__cubtn_r(2)) && array_length(customs) > 0) {
			// the last custom out of the list (and the party)
			var _gone = array_pop(customs);
			for (var _k = array_length(picked) - 1; _k >= 0; _k--) if (picked[_k] == _gone.id) array_delete(picked, _k, 1);
			cu_preview = __custom_make();
			play_sound_ext(snd_matclick2, .8, .9, .5, 1); exit;
		}
		if (_dirty) { cu_preview = __custom_make(); play_sound_ext(snd_softclick, .95, 1.05, .35, 1); exit; }
	}
	if (__hit(__fight_r()) && array_length(picked) > 0) { __start(); exit; }
	exit;
}

if (page == "fight" && is_struct(f)) {
	// the strip's controls
	if (__hit(__spd_r(0))) { spd = 1; exit; }
	if (__hit(__spd_r(1))) { spd = 4; exit; }
	if (__hit(__spd_r(2))) { spd = 0; exit; }
	if (__hit(__auto_r())) { auto = !auto; if (auto && mn.open) { mn.open = false; pending = true; beat = 0; } play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	if (__hit(__quit_r())) { f.over = true; f.won = false; f.withdrew = true; play_sound_ext(snd_softclick, .9, 1.0, .4, 1); exit; }
	// THE MENU (the actor's turn, held by cbt_fight_next until a plan is chosen)
	if (mn.open && !is_undefined(f.actor)) {
		var _ac = f.actor;
		if (mn.stage == "root") {
			for (var _i = 0; _i < 5; _i++) {
				if (!__hit(__menu_r(_i))) continue;
				if (_i == 0) { mn.kind = "basic"; mn.stage = "target"; mn.list = __alive(1); }
				else if (_i == 1) { var _op = cbt_fight_options(f, _ac); mn.list = []; for (var _k = 0; _k < array_length(_op); _k++) if (_op[_k].kind == "skill") array_push(mn.list, _op[_k]); mn.stage = "skill"; }
				else if (_i == 2) { mn.list = is_array(_ac[$ "items"]) ? _ac.items : []; mn.stage = "item"; }
				else if (_i == 3) __commit({ kind : "guard" });
				else __commit({ kind : "flee" });
				play_sound_ext(snd_softclick, .95, 1.05, .35, 1);
				exit;
			}
		} else {
			// a row of the list, or back to the root (a tap outside the list)
			for (var _i = 0; _i < min(6, array_length(mn.list)); _i++) {
				if (!__hit(__list_r(_i))) continue;
				var _row = mn.list[_i];
				if (mn.stage == "skill") { mn.skill = _row.skill; mn.kind = "skill"; mn.list = _row.targets; mn.stage = "target"; }
				else if (mn.stage == "item") { mn.item = _row; mn.kind = "item"; mn.list = __alive(0); mn.stage = "target"; }
				else if (mn.stage == "target") {
					if (mn.kind == "basic") __commit({ skill : undefined, target : _row });
					else if (mn.kind == "skill") __commit({ skill : mn.skill, target : _row });
					else __commit({ kind : "item", item : mn.item, target : _row });
				}
				play_sound_ext(snd_softclick, .95, 1.05, .35, 1);
				exit;
			}
			if (__hit(__menu_r(0)) || __hit(__menu_r(1)) || __hit(__menu_r(2)) || __hit(__menu_r(3)) || __hit(__menu_r(4))) { mn.stage = "root"; mn.list = []; exit; }
		}
	}
	exit;
}

if (page == "result") {
	if (__hit(__again_r())) { __start(); exit; }
	if (__hit(__setup_r())) { page = "setup"; f = undefined; exit; }
}
