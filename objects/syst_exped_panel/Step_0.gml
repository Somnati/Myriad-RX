// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) { exped_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

var _e = g.exped;

// the debug clock: x1 / x10 / x100
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	if (point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) {
		_e.spd = [1, 10, 100][_k];
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
}

// ---- the haul: collect ----
if (!is_undefined(_e.haul)) {
	var _cb = __col_r();
	if (point_in_rectangle(mouse_x, mouse_y, _cb.x, _cb.y, _cb.x + _cb.w, _cb.y + _cb.h)) {
		exped_collect(room_width * .5, room_height * .5);
		play_sound_ext(snd_apply, 1, 1.2, .5, 1);
	}
	exit;
}

// ---- the trip: a fight can be stepped by hand ----
if (!is_undefined(_e.trip)) {
	var _tr = _e.trip;
	if (!is_undefined(_tr.fight) && !_tr.fight.over) {
		var _sr = __step_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sr.x, _sr.y, _sr.x + _sr.w, _sr.y + _sr.h)) {
			exped_fight_turn(_tr.fight);
			play_sound_ext(snd_matclick2, .9, 1.1, .4, 1);
		}
	}
	exit;
}

// ---- the board: pick a world, pick a sprite, send ----
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _sr2 = __send_r(_i);
	if (sel_dest == _i && sel_crew >= 0 && sel_crew < array_length(g.sprites)
	&& point_in_rectangle(mouse_x, mouse_y, _sr2.x, _sr2.y, _sr2.x + _sr2.w, _sr2.y + _sr2.h)) {
		if (exped_start(_i, g.sprites[sel_crew])) {
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			sel_dest = -1; sel_crew = -1;
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
		exit;
	}
	var _c = __card_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _c.x, _c.y, _c.x + _c.w, _c.y + _c.h)) {
		sel_dest = _i;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
for (var _k = 0; _k < array_length(g.sprites); _k++) {
	var _cr = __crew_r(_k);
	if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) {
		var _sp = g.sprites[_k];
		if (_sp.asleep || (_sp[$ "trip"] ?? false)) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
		sel_crew = _k;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
