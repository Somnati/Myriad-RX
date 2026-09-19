/// @description ex_haul_press(_e) -> true when the press is taken: THE HAUL page's presses - the roster, the loot, [read the diary], the swap (syst_exped_panel's Step, q220; self = the panel; e = g.exped)
function ex_haul_press(_e) {
	var _hi = __haul_i();
	if (land && !swap_pick) { var _hlr = __hlog_r(); if (point_in_rectangle(mouse_x, mouse_y, _hlr.x, _hlr.y, _hlr.x + _hlr.w, _hlr.y + _hlr.h)) { hl_open = !hl_open; log_follow = true; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; } }   // (2026-09-16)
	if (swap_pick) {
		// the roster: tap who retires
		for (var _k = 0; _k < array_length(g.sprites); _k++) {
			var _pr = __pick_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _pr.x, _pr.y, _pr.x + _pr.w, _pr.y + _pr.h)) {
				var _sid = g.sprites[_k].id;
				exped_collect(_hi, room_width * .5, room_height * .5, "swap:" + string(_sid));
				swap_pick = false;
				__page_go("planet");
				play_sound_ext(snd_apply, 1, 1.2, .5, 1);
				return true;
			}
		}
		return true;
	}
	var _h = _e.hauls[_hi];
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	var _recruit = (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP);
	if (_recruit) {
		var _sw = __swap_r(), _go = __go_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sw.x, _sw.y, _sw.x + _sw.w, _sw.y + _sw.h)) { swap_pick = true; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; }
		if (point_in_rectangle(mouse_x, mouse_y, _go.x, _go.y, _go.x + _go.w, _go.y + _go.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5, "letgo");
			__page_go("planet");
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			return true;
		}
	} else {
		var _cb = __col_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cb.x, _cb.y, _cb.x + _cb.w, _cb.y + _cb.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5);
			__page_go("planet");
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			return true;
		}
		// [SEND AGAIN] (2026-09-15): collect, wake this crew as they are (the
		// seat's rule), and off on the easiest open card
		var _ag = __again_r();
		if (point_in_rectangle(mouse_x, mouse_y, _ag.x, _ag.y, _ag.x + _ag.w, _ag.y + _ag.h)) {
			var _pl = __again_plan(_h);
			if (!_pl.ok) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); return true; }
			var _rgi2 = _h[$ "rgi"] ?? 0, _dest2 = _h.dest;
			exped_collect(_hi, room_width * .5, room_height * .5);
			for (var _c = 0; _c < array_length(_pl.crew); _c++) { var _csp = _pl.crew[_c]; if (_csp.asleep) { _csp.asleep = false; _csp.hurt = 0; } }
			if (exped_start(_pl.di, _pl.crew, _pl.mode, _pl.pick, _rgi2, _h[$ "stance"] ?? "steady")) {   // (the haul's stance again)
				if (_pl.mode == "quest" && _pl.slot >= 0) exped_offer_take(_dest2, _rgi2, _pl.slot, g.exped.seq, _pl.pick);
				play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
			save_mark_dirty();
			__page_go("planet");
			return true;
		}
	}
	return true;
}
