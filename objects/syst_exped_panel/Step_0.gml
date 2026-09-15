// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

var _e = g.exped;
// the trip page's world is built a few rows a frame (planet_gen_step),
// so it arrives in half a second without a hitch
if (view == "trip") {
	var _tv = __trip();
	if (!is_undefined(_tv)) {
		var _pn = planet_get(_tv.dest.seed, exped_planet_hint(_tv.dest));
		if (_pn.row < _pn.th) planet_gen_step(_pn);
	}
}
// THE REPLAY: a trip page with an unseen film (and no live fight)
// plays it in the combat window, a swing every half second; the last
// frame holds a moment, then it is seen. A tap on the window skips it
if (view == "trip") {
	var _tvr = __trip();
	if (!is_undefined(_tvr)) {
		var _rr = _tvr[$ "replay"];
		// a fight watched LIVE on this page is not replayed after
		if (!is_undefined(_tvr.fight)) seen_live = string(_tvr.id) + ":" + string(_tvr[$ "fights"] ?? 0);   // (the fight counter - room_i is the old delve's)
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
if (view == "trip" && is_undefined(__trip())) {
	view = (__haul_i() >= 0) ? "haul" : "hub";
}
if (view == "haul" && __haul_i() < 0) { view = "hub"; swap_pick = false; }
if (view == "sheet" && is_undefined(__sp_by_id(sheet_id))) view = "hub";
if (view == "map" && !is_struct(map_dest)) view = "hub";

if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) {
	if (view != "hub") { view = "hub"; swap_pick = false; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); }
	else exped_close();
	exit;
}
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// ======================= THE CREW MENU: tabs on the left =======================
if (view == "crew" || view == "sheet") {
	view = "crew";
	if (!mouse_check_button_pressed(mb_left)) exit;
	var _bk = __back_r();
	if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) { view = "hub"; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		var _tb = __tab_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _tb.x, _tb.y, _tb.x + _tb.w, _tb.y + _tb.h)) {
			sheet_id = g.sprites[_k].id;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	exit;
}

// EVERYTHING BELOW IS A PRESS (the gate was lost in the crew menu rewrite,
// 2026-09-14 - hovering a button clicked it; his report)
if (!mouse_check_button_pressed(mb_left)) exit;

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
			map_dest = _tr.dest; view = "map";
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// a crew row opens that sprite's sheet
	if (!is_undefined(_tr)) {
		for (var _k = 0; _k < array_length(_tr.sids); _k++) {
			var _cr = __crew_row_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) {
				sheet_id = _tr.sids[_k]; view = "sheet";
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
// send: [quest] or [explore] - a world, a crew, and the bill (exped_cost)
if (array_length(_e.board) > 0) sel_dest = clamp(sel_dest, 0, array_length(_e.board) - 1);
var _sr2 = __send_r(), _xr2 = __explore_r();
var _hitq = point_in_rectangle(mouse_x, mouse_y, _sr2.x, _sr2.y, _sr2.x + _sr2.w, _sr2.y + _sr2.h);
var _hitx = point_in_rectangle(mouse_x, mouse_y, _xr2.x, _xr2.y, _xr2.x + _xr2.w, _xr2.y + _xr2.h);
if (_hitq || _hitx) {
	var _crew = [];
	for (var _c = 0; _c < array_length(sel_crew); _c++)
		for (var _k = 0; _k < array_length(g.sprites); _k++) if (g.sprites[_k].id == sel_crew[_c]) array_push(_crew, g.sprites[_k]);
	if (sel_dest >= 0 && array_length(_crew) > 0 && exped_start(sel_dest, _crew, _hitx ? "explore" : "quest")) {
		play_sound_ext(snd_apply, 1, 1.2, .5, 1);
		sel_crew = [];
	} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
	exit;
}
// [crew]: the roster as a list (his ask, 2026-09-14)
if (array_length(g.sprites) > 0) {
	var _shr = __sheet_r();
	if (point_in_rectangle(mouse_x, mouse_y, _shr.x, _shr.y, _shr.x + _shr.w, _shr.y + _shr.h)) {
		view = "crew"; crew_off = 0; crew_drag = undefined;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// a world's [map] chip (checked before the card's own tap)
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _cm = __card_map_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _cm.x, _cm.y, _cm.x + _cm.w, _cm.y + _cm.h)) {
		map_dest = _e.board[_i]; view = "map";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// a world
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _c = __card_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _c.x, _c.y, _c.x + _c.w, _c.y + _c.h)) {
		sel_dest = _i;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// the crew: tap to add to the party, tap again to drop; up to EXPED_PARTY
for (var _k = 0; _k < array_length(g.sprites); _k++) {
	var _cr = __chip_r(_k);
	if (!point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) continue;
	var _sp = g.sprites[_k];
	var _at = array_get_index(sel_crew, _sp.id);
	if (_at >= 0) { array_delete(sel_crew, _at, 1); play_sound_ext(snd_softclick, .9, 1, .4, 1); exit; }
	if (_sp.asleep || (_sp[$ "trip"] ?? false) || array_length(sel_crew) >= EXPED_PARTY) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
	array_push(sel_crew, _sp.id);
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
