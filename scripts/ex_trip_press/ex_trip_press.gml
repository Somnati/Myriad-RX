/// @description ex_trip_press() -> true when the press is taken: THE TRIP page's presses - [recall], the fight, the sheet modal, the film's controls (syst_exped_panel's Step, q220; self = the panel)
function ex_trip_press() {
	var _tr = __trip();
	// THE SHEET MODAL owns the page while it is up (the preparation page's rule):
	// its rows and popups, a press on it stays, a press off it closes it and goes on
	if (tp_sheet >= 0) {
		if (__sheet_tap()) return true;
		var _tsr = __tp_sheet_r();
		if (point_in_rectangle(mouse_x, mouse_y, _tsr.x, _tsr.y, _tsr.x + _tsr.w, _tsr.y + _tsr.h)) return true;
		tp_sheet = -1; it_pop = undefined; it_rects = [];
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
	}
	// a tap on the replay's window skips the rest of it
	if (!is_undefined(rp)) {
		var _fw = __fight_r();
		if (point_in_rectangle(mouse_x, mouse_y, log_x, _fw.y, log_x + log_w, _fw.y + _fw.h)) {
			rp.r.seen = true; rp = undefined;
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
			return true;
		}
	}
	// [recall]: an exploring crew comes home
	if (!is_undefined(_tr) && (_tr[$ "mode"] ?? "quest") == "explore" && !(_tr[$ "recall"] ?? false)) {
		var _rr2 = __recall_r();
		if (point_in_rectangle(mouse_x, mouse_y, _rr2.x, _rr2.y, _rr2.x + _rr2.w, _rr2.y + _rr2.h)) {
			exped_recall(_tr);
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			return true;
		}
	}
	// [crew]: this trip's crew, in the crew menu (his ask: only the sprites on the quest)
	if (!is_undefined(_tr)) {
		var _tcr = __trip_crew_r();
		if (point_in_rectangle(mouse_x, mouse_y, _tcr.x, _tcr.y, _tcr.x + _tcr.w, _tcr.y + _tcr.h)) {
			crew_trip = _tr.id; sheet_id = _tr.sids[0]; __page_go("crew"); it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	// [abort]: the question first (the confirm popup); the crew comes home
	if (!is_undefined(_tr) && !(_tr[$ "aborted"] ?? false) && _tr.stage != 2) {
		var _abr = __trip_abort_r();
		if (point_in_rectangle(mouse_x, mouse_y, _abr.x, _abr.y, _abr.x + _abr.w, _abr.y + _abr.h)) {
			confirm = "abort";
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
			return true;
		}
	}
	// a crew row opens that sprite's sheet (this crew only)
	if (!is_undefined(_tr)) {
		for (var _k = 0; _k < array_length(_tr.sids); _k++) {
			var _cr = __crew_row_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) {
				// (the sheet as a modal here, not the crew menu - his ask, 2026-09-16)
				tp_sheet = _tr.sids[_k]; sheet_id = _tr.sids[_k]; it_pop = undefined; it_rects = [];
				play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
				return true;
			}
		}
	}
	if (!is_undefined(_tr) && !is_undefined(_tr.fight) && !_tr.fight.over) {
		var _sr = __step_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sr.x, _sr.y, _sr.x + _sr.w, _sr.y + _sr.h)) {
			exped_fight_turn(_tr.fight);
			play_sound_ext(snd_matclick2, .9, 1.1, .4, 1);
		}
	}
	return true;
}
