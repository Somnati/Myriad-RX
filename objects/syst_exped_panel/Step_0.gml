// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

var _e = g.exped;
// a trip that got home while its page was open: the page turns to the haul
if (view == "trip" && is_undefined(__trip())) {
	view = (__haul_i() >= 0) ? "haul" : "hub";
}
if (view == "haul" && __haul_i() < 0) { view = "hub"; swap_pick = false; }

if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) {
	if (view != "hub") { view = "hub"; swap_pick = false; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); }
	else exped_close();
	exit;
}
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// the debug clock: x1 / x10 / x100
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	if (point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) {
		_e.spd = [1, 10, 100][_k];
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
}

// [back] from a page
if (view != "hub") {
	var _bk = __back_r();
	if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) {
		view = "hub"; swap_pick = false;
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		exit;
	}
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
// send: a world and a crew
var _sr2 = __send_r();
if (sel_dest >= 0 && array_length(sel_crew) > 0
&& point_in_rectangle(mouse_x, mouse_y, _sr2.x, _sr2.y, _sr2.x + _sr2.w, _sr2.y + _sr2.h)) {
	var _crew = [];
	for (var _c = 0; _c < array_length(sel_crew); _c++)
		for (var _k = 0; _k < array_length(g.sprites); _k++) if (g.sprites[_k].id == sel_crew[_c]) array_push(_crew, g.sprites[_k]);
	if (array_length(_crew) > 0 && exped_start(sel_dest, _crew)) {
		play_sound_ext(snd_apply, 1, 1.2, .5, 1);
		sel_crew = [];
	} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
	exit;
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
