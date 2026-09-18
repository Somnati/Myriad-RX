/// @description ex_depart_press(_e) -> true when the press is taken: THE PREPARATION PAGE's presses - the crew chips, the brief, [depart], the sheet modal (syst_exped_panel's Step, q220; self = the panel; e = g.exped)
function ex_depart_press(_e) {
	// THE SHEET MODAL owns the page while it is up: its rows and popups, or a press off it closes it
	if (dp_sheet >= 0) {
		if (__sheet_tap()) return true;
		var _msr = __dp_sheet_r();
		if (point_in_rectangle(mouse_x, mouse_y, _msr.x, _msr.y, _msr.x + _msr.w, _msr.y + _msr.h)) return true;
		// off the sheet: it closes, and the press goes on to whatever it hit
		// (another banner opens its sheet in the same press - his ask
		// 2026-09-15); [depart] under the box only closes it
		dp_sheet = -1; it_pop = undefined; it_rects = [];
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		var _dr0 = __depart_r();
		if (point_in_rectangle(mouse_x, mouse_y, _dr0.x, _dr0.y, _dr0.x + _dr0.w, _dr0.y + _dr0.h)) return true;
	}
	var _dr = __depart_r();
	if (point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) {
		__dp_sync();
		var _crew = [];
		for (var _c = 0; _c < array_length(sel_crew); _c++) { var _sp = __sp_by_id(sel_crew[_c]); if (!is_undefined(_sp)) array_push(_crew, _sp); }
		var _di = -1;
		for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == pl_dest.seed) _di = _i;
		if (_di >= 0 && array_length(_crew) > 0 && exped_start(_di, _crew, dp_mode, dp_quest, rg_sel, dp_stance)) {   // (the stance rides along, 2026-09-16)
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			if (dp_mode == "quest" && dp_slot >= 0) exped_offer_take(pl_dest, rg_sel, dp_slot, g.exped.seq, dp_quest);   // (the board marks it taken - 2026-09-15; not if the slot turned over meanwhile)
			dp_slot = -1;
			sel_crew = []; dp_slots = array_create(exped_party_max(), -1); dp_pos = {};
			view_id = g.exped.seq;   // (the trip that just left - its page, his ask 2026-09-16)
			__dp_leave("trip");   // (the page swings out, then the trip's page with the diary)
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
		return true;
	}
	// THE STANCE pills (2026-09-16): a press picks the word
	for (var _si = 0; _si < array_length(dp_stance_rects); _si++) {
		var _sr2 = dp_stance_rects[_si];
		if (!point_in_rectangle(mouse_x, mouse_y, _sr2.x, _sr2.y, _sr2.x + _sr2.w, _sr2.y + _sr2.h)) continue;
		if (dp_stance != _sr2.key) { dp_stance = _sr2.key; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); }
		return true;
	}
	// a seat row: a press unseats it
	for (var _j = 0; _j < array_length(dp_slots); _j++) {
		if (dp_slots[_j] < 0) continue;
		var _mr2 = __dp_minus_r(_j);
		if (!point_in_rectangle(mouse_x, mouse_y, _mr2.x, _mr2.y, _mr2.x + _mr2.w, _mr2.y + _mr2.h)) continue;
		__dp_unseat(dp_slots[_j]);
		return true;
	}
	// the list: [+] seats a banner, [-] unseats it (the banner stays put); the banner itself opens its sheet
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		if (!__dp_row_in(_k)) continue;
		var _sp = g.sprites[_k];
		var _pr = __dp_plus_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _pr.x, _pr.y, _pr.x + _pr.w, _pr.y + _pr.h)) {
			if (__dp_seat_of(_sp.id) >= 0) __dp_unseat(_sp.id); else __dp_seat(_sp.id);
			return true;
		}
		var _rr = __dp_row_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) {
			// the sheet, as a modal over this page (his call: snappy, click off to close)
			dp_sheet = _sp.id; sheet_id = _sp.id; it_pop = undefined; it_rects = [];
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	return true;
	return false;
}
