// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

var _e = g.exped;
// the worlds are built a few rows a frame (planet_gen_step, __worlds_step:
// the board's, the trips', the planet window's), so every portrait is the
// full world within a second or two, without a hitch
__worlds_step();
// THE REPLAY: a trip page with an unseen film (and no live fight)
// plays it in the combat window, a swing every half second; the last
// frame holds a moment, then it is seen. A tap on the window skips it
if (view == "trip") {
	var _tvr = __trip();
	if (!is_undefined(_tvr)) {
		var _rr = _tvr[$ "replay"];
		// a fight watched LIVE on this page is not replayed after
		if (!is_undefined(_tvr.fight)) seen_live = string(_tvr.id) + ":" + string(_tvr[$ "fights"] ?? 0);
		if (!is_undefined(_rr) && !_rr.seen && seen_live == string(_tvr.id) + ":" + string(_rr.room)) _rr.seen = true;
		if (is_undefined(rp) && !is_undefined(_rr) && !_rr.seen && is_undefined(_tvr.fight) && array_length(_rr.ev) > 0)
			rp = { i : 0, t : 0, r : _rr, id : _tvr.id };
		if (!is_undefined(rp)) {
			if (rp.id != _tvr.id || !is_undefined(_tvr.fight)) rp = undefined;
			else {
				rp.t += delta / 60;
				var _step = (rp.i < array_length(rp.r.ev) - 1) ? .5 : 1.6;
				if (rp.t >= _step) {
					rp.t = 0;
					if (rp.i < array_length(rp.r.ev) - 1) rp.i += 1;
					else { rp.r.seen = true; rp = undefined; }
				}
			}
		}
	} else rp = undefined;
} else rp = undefined;
// a trip that got home while its page was open: the page turns to the haul
if (view == "trip" && is_undefined(__trip())) view = (__haul_i() >= 0) ? "haul" : "hub";
if (view == "haul" && __haul_i() < 0) { view = "hub"; swap_pick = false; }
if (view == "sheet") view = "crew";
if (view == "crew" && is_undefined(__sp_by_id(sheet_id)) && array_length(g.sprites) > 0) sheet_id = g.sprites[0].id;
if (view == "map" && !is_struct(map_dest)) view = "hub";
if ((view == "planet" || view == "region" || view == "depart") && !is_struct(pl_dest)) view = "hub";

// THE WORLD'S TURN (his ask, 2026-09-15): focused on a region, the spin
// eases to the spot's and the view zooms in; unfocused, the ambient spin
// resumes from where it was (an offset, so nothing jumps)
if (is_struct(pl_dest)) {
	var _pn2 = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
	var _amb = (current_time / 1000) * 60 * _pn2.spin + pl_spin_off;
	if (pl_focus >= 0) {
		var _dd = angle_difference(pl_spin_t, pl_spin);
		pl_spin += _dd * (1 - power(.9, delta));
		pl_zoom = lerp(pl_zoom, PL_ZOOM_IN, 1 - power(.9, delta));
	} else {
		pl_spin_off = pl_spin - (current_time / 1000) * 60 * _pn2.spin;   // (keep the drawn spin continuous)
		pl_spin = _amb;
		pl_zoom = lerp(pl_zoom, 1, 1 - power(.9, delta));
	}
}

if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
// ---- THE CONFIRM POPUP owns the panel while it is up (abort) ----
if (view != "trip") confirm = "";   // (the page turned under it - a trip got home)
conf_a = move_to(conf_a, (confirm != "") ? 1 : 0, 5);
if (confirm != "") {
	var _cb = __conf_btns();
	conf_hot = 0;
	for (var _ci = 0; _ci < 2; _ci++) {
		var _cbb = _cb[_ci];
		if (point_in_rectangle(mouse_x, mouse_y, _cbb.x, _cbb.y, _cbb.x + _cbb.w, _cbb.y + _cbb.h)) conf_hot = _ci + 1;
	}
	if (keyboard_check_pressed(vk_escape)) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); exit; }
	if (conf_a > .9 && mouse_check_button_pressed(mb_left)) {
		if (conf_hot == 1) {
			if (confirm == "abort") { var _atr = __trip(); if (!is_undefined(_atr)) exped_abort(_atr); }
			confirm = "";
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
		} else if (conf_hot == 2) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); }
	}
	exit;
}
if (conf_a > .01) exit;   // (fading out: nothing under it acts yet)
// ---- [back], and escape: one step up the chain (__back, the Create) ----
if (keyboard_check_pressed(vk_escape)) {
	if (view != "hub") __back(); else exped_close();
	exit;
}
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;   // EVERYTHING BELOW IS A PRESS

// the debug clock: x1 / x10 / x100
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	if (point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) {
		_e.spd = [1, 10, 100][_k];
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
}
// [back] from any page (drawn on the right, syst_exped_panel's Draw)
if (view != "hub") {
	var _bk = __back_r();
	if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) { __back(); exit; }
}

// ======================= THE CREW MENU: tabs on the left =======================
if (view == "crew") {
	// a popup up: any press closes it
	if (is_struct(it_pop)) { it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	var _cl = __crew_list();
	for (var _k = 0; _k < array_length(_cl); _k++) {
		var _tb = __tab_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _tb.x, _tb.y, _tb.x + _tb.w, _tb.y + _tb.h)) {
			sheet_id = _cl[_k].id;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// an item row: its popup (the rects the Draw laid down)
	for (var _k = 0; _k < array_length(it_rects); _k++) {
		var _ir = it_rects[_k];
		if (point_in_rectangle(mouse_x, mouse_y, _ir.x, _ir.y, _ir.x + _ir.w, _ir.y + _ir.h)) {
			it_pop = { it : _ir.it, sp : __sp_by_id(sheet_id), worn : _ir.worn, x : _ir.x, y : _ir.y + _ir.h + 2 };
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	exit;
}

// ======================= THE MAP =======================
if (view == "map") exit;

// ======================= THE PLANET: its regions =======================
if (view == "planet") {
	// [view region]: the picked one's window (his ask, 2026-09-15: a pick
	// first, the world pulls over to it, then the button)
	if (pl_focus >= 0) {
		var _vr = __view_rg_r();
		if (point_in_rectangle(mouse_x, mouse_y, _vr.x, _vr.y, _vr.x + _vr.w, _vr.y + _vr.h)) {
			rg_sel = pl_focus;
			view = "region";
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// a region row: the world turns to it (a second tap on the same row
	// changes nothing - it stays picked)
	for (var _i = 0; _i < EXPED_REGIONS; _i++) {
		var _pr0 = __pl_row(_i);
		if (!point_in_rectangle(mouse_x, mouse_y, _pr0.x, _pr0.y, _pr0.x + _pr0.w, _pr0.y + _pr0.h)) continue;
		if (pl_focus == _i) { play_sound_ext(snd_softclick, .95, 1.05, .3, 1); exit; }
		rg_sel = _i;
		var _rgs = region_get(pl_dest, _i);
		var _pn3 = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
		pl_focus = _i; pl_spin_t = __spin_for(_pn3, _rgs.spot.lon, _rgs.spot.lat);
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	exit;
}

// ======================= THE REGION: the quests, or explore =======================
if (view == "region") {
	var _mr0 = __rg_map_r();
	if (point_in_rectangle(mouse_x, mouse_y, _mr0.x, _mr0.y, _mr0.x + _mr0.w, _mr0.y + _mr0.h)) {
		map_dest = pl_dest; map_rgi = rg_sel; map_from = "region"; view = "map";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	var _ql = exped_region_quests(pl_dest, rg_sel);
	for (var _i = 0; _i <= array_length(_ql); _i++) {
		var _qr = __q_row(_i);
		if (!point_in_rectangle(mouse_x, mouse_y, _qr.x, _qr.y, _qr.x + _qr.w, _qr.y + _qr.h)) continue;
		if (_i < array_length(_ql)) { dp_quest = _ql[_i]; dp_mode = "quest"; }
		else { dp_quest = undefined; dp_mode = "explore"; }
		view = "depart";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	exit;
}

// ======================= THE DEPARTURE: the crew, the brief, [depart] =======================
if (view == "depart") {
	var _dr = __depart_r();
	if (point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) {
		var _crew = [];
		for (var _c = 0; _c < array_length(sel_crew); _c++) { var _sp = __sp_by_id(sel_crew[_c]); if (!is_undefined(_sp)) array_push(_crew, _sp); }
		var _di = -1;
		for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == pl_dest.seed) _di = _i;
		if (_di >= 0 && array_length(_crew) > 0 && exped_start(_di, _crew, dp_mode, dp_quest, rg_sel)) {
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			sel_crew = [];
			view = "hub";
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
		exit;
	}
	// the crew: tap to add to the party, tap again to drop; up to EXPED_PARTY
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		var _cr = __dchip_r(_k);
		if (!point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) continue;
		var _sp = g.sprites[_k];
		var _at = array_get_index(sel_crew, _sp.id);
		if (_at >= 0) { array_delete(sel_crew, _at, 1); play_sound_ext(snd_softclick, .9, 1, .4, 1); exit; }
		if (_sp.asleep || (_sp[$ "trip"] ?? false) || array_length(sel_crew) >= EXPED_PARTY) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
		array_push(sel_crew, _sp.id);
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	exit;
}

// ======================= THE HAUL: collect, or the recruit moment =======================
if (view == "haul") {
	var _hi = __haul_i();
	if (swap_pick) {
		// the roster: tap who retires
		for (var _k = 0; _k < array_length(g.sprites); _k++) {
			var _pr = __pick_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _pr.x, _pr.y, _pr.x + _pr.w, _pr.y + _pr.h)) {
				var _sid = g.sprites[_k].id;
				exped_collect(_hi, room_width * .5, room_height * .5, "swap:" + string(_sid));
				swap_pick = false;
				view = "hub";
				play_sound_ext(snd_apply, 1, 1.2, .5, 1);
				exit;
			}
		}
		exit;
	}
	var _h = _e.hauls[_hi];
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	var _recruit = (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP);
	if (_recruit) {
		var _sw = __swap_r(), _go = __go_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sw.x, _sw.y, _sw.x + _sw.w, _sw.y + _sw.h)) { swap_pick = true; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; }
		if (point_in_rectangle(mouse_x, mouse_y, _go.x, _go.y, _go.x + _go.w, _go.y + _go.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5, "letgo");
			view = "hub";
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	} else {
		var _cb = __col_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cb.x, _cb.y, _cb.x + _cb.w, _cb.y + _cb.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5);
			view = "hub";
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	}
	exit;
}

// ======================= THE TRIP: a fight can be stepped by hand =======================
if (view == "trip") {
	var _tr = __trip();
	// a tap on the replay's window skips the rest of it
	if (!is_undefined(rp)) {
		var _fy0 = room_height - 8 - fight_s;
		if (point_in_rectangle(mouse_x, mouse_y, log_x, _fy0, log_x + log_w, _fy0 + fight_s)) {
			rp.r.seen = true; rp = undefined;
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
			exit;
		}
	}
	// [recall]: an exploring crew comes home
	if (!is_undefined(_tr) && (_tr[$ "mode"] ?? "quest") == "explore" && !(_tr[$ "recall"] ?? false)) {
		var _rr2 = __recall_r();
		if (point_in_rectangle(mouse_x, mouse_y, _rr2.x, _rr2.y, _rr2.x + _rr2.w, _rr2.y + _rr2.h)) {
			exped_recall(_tr);
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	}
	// [map]: the world's region
	if (!is_undefined(_tr)) {
		var _mr = __trip_map_r();
		if (point_in_rectangle(mouse_x, mouse_y, _mr.x, _mr.y, _mr.x + _mr.w, _mr.y + _mr.h)) {
			map_dest = _tr.dest; map_rgi = _tr[$ "rgi"] ?? 0; map_from = "trip"; view = "map";
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [crew]: this trip's crew, in the crew menu (his ask: only the sprites on the quest)
	if (!is_undefined(_tr)) {
		var _tcr = __trip_crew_r();
		if (point_in_rectangle(mouse_x, mouse_y, _tcr.x, _tcr.y, _tcr.x + _tcr.w, _tcr.y + _tcr.h)) {
			crew_trip = _tr.id; sheet_id = _tr.sids[0]; view = "crew"; it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [abort]: the question first (the confirm popup); the crew comes home
	if (!is_undefined(_tr) && !(_tr[$ "aborted"] ?? false) && _tr.stage != 2) {
		var _abr = __trip_abort_r();
		if (point_in_rectangle(mouse_x, mouse_y, _abr.x, _abr.y, _abr.x + _abr.w, _abr.y + _abr.h)) {
			confirm = "abort";
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
			exit;
		}
	}
	// a crew row opens that sprite's sheet (this crew only)
	if (!is_undefined(_tr)) {
		for (var _k = 0; _k < array_length(_tr.sids); _k++) {
			var _cr = __crew_row_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) {
				sheet_id = _tr.sids[_k]; view = "crew"; crew_trip = _tr.id; it_pop = undefined;
				play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
				exit;
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
	exit;
}

// ======================= THE HUB =======================
// the list: a trip or a haul opens its page
var _rows = array_length(_e.hauls) + array_length(_e.trips);
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (!point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) continue;
	if (_i < array_length(_e.hauls)) { view = "haul"; view_id = _e.hauls[_i].id; }
	else { view = "trip"; view_id = _e.trips[_i - array_length(_e.hauls)].id; }
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
// [crew]: the roster
if (array_length(g.sprites) > 0) {
	var _shr = __crewbtn_r();
	if (point_in_rectangle(mouse_x, mouse_y, _shr.x, _shr.y, _shr.x + _shr.w, _shr.y + _shr.h)) {
		view = "crew"; crew_trip = -1; it_pop = undefined;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// a world: its planet window
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _c = __card_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _c.x, _c.y, _c.x + _c.w, _c.y + _c.h)) {
		sel_dest = _i; pl_dest = _e.board[_i]; rg_sel = 0; pl_focus = -1; view = "planet";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
