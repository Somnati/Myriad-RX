// The cards go stale on their own: the autosave clock fires every 60s
// while this room is open, so a slow re-peek keeps "2 minutes ago"
// honest. Nine small ini reads every 90 frames costs nothing.
scan_tic -= delta;
if (scan_tic <= 0) {
	scan_tic = 90;
	__refresh_prof();
	__refresh_slots();
}

// THE DEFERRED OS DIALOG (see `pending` in Create). Hold while the
// dialogue box is still unwinding, then let a few frames draw a settled
// screen before handing the display to Windows. The job is cleared
// BEFORE it runs, so a dialog that misbehaves can never re-arm itself.
if (pending != "") {
	if (instance_exists(obj_dialogue) && obj_dialogue.dialogue_active)
		pending_t = 3;
	else if (pending_t > 0)
		pending_t -= delta;
	else {
		var _job = pending;
		pending = "";
		if (_job == "export") __do_export(); else __do_import();
	}
	exit;  // nothing else on this screen acts while a transfer is armed
}

// ---- THE CONFIRM POPUP owns the screen while it is up ----
conf_a = move_to(conf_a, (confirm != "") ? 1 : 0, 5);
if (confirm != "") {
	var _cb = __conf_btns();
	conf_hot = 0;
	for (var _i = 0; _i < 2; _i++) {
		var _b = _cb[_i];
		if (point_in_rectangle(mouse_x, mouse_y, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h)) conf_hot = _i + 1;
	}
	if (keyboard_check_pressed(vk_escape)) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); exit; }
	if (input_free() && conf_a > .9 && mouse_check_button_pressed(mb_left)) {
		if (conf_hot == 1) __conf_go();
		else if (conf_hot == 2) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); }
	}
	exit;
}

// Region UI plays by syst_input's rules: input must be free (no
// dialogue or menu up - begin-step timing would otherwise eat the very
// click that picked a popup option) and no button instance may own the
// pointer over a row.
if (input_free())
if (g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {
	var _mx = mouse_x;
	var _my = mouse_y;

	// ---- back, top right of the strip ----
	var _bk = __back_rect();
	if (point_in_rectangle(_mx, _my, _bk.x1, _bk.y1, _bk.x2, _bk.y2)) {
		play_sound_ext(snd_matclick2, .8, .9, .5, 1);
		back_room();
		exit;
	}

	// ---- the profile rail: always live, on every page ----
	// This is what the rail bought over the old two-page slide - you
	// can switch profiles from anywhere without unwinding first.
	var _tb = __tabs();
	for (var _i = 0; _i < 4; _i++) {
		var _t = _tb[_i];
		if (!point_in_rectangle(_mx, _my, _t.x1, _t.y1, _t.x2, _t.y2)) continue;
		if (_i != sel_prof) {
			sel_prof = _i;
			page = 0;   // a different profile means a different question
			__refresh_slots();
			play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
		}
		exit;
	}

	// nothing below here lives in the rail
	if (_mx < rail_w) exit;

	// ---- the action band ----
	if (ng_mode) {
		var _nb = __ngbtn();
		if (point_in_rectangle(_mx, _my, _nb.x, _nb.y, _nb.x + _nb.w, _nb.y + _nb.h)) {
			play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
			// an occupied profile confirms the overwrite first; an
			// empty one goes straight to rm_newgame
			if (__phas(sel_prof)) {
				obj_dialogue.box_col_border = g.profile_color[sel_prof];
				obj_dialogue.dialogue_start(dt_ng_over);
			} else __ng_go();
			exit;
		}
	} else {
		var _bd = __band();
		for (var _i = 0; _i < 3; _i++) {
			var _b = _bd[_i];
			if (!point_in_rectangle(_mx, _my, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h)) continue;
			// export and delete need a file to work on; import does not
			if (_b.id != "import" && !__phas(sel_prof)) {
				play_sound_ext(snd_matclick2, .7, .8, .35, 0);
				exit;
			}
			play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
			obj_dialogue.box_col_border = g.profile_color[sel_prof];
			switch (_b.id) {
				// export needs no confirm - it only READS, and the file
				// dialog it opens is its own confirmation - but it still
				// goes through the deferred lane, because the dialog is
				// modal either way
				case "export": dt_act_export(); break;
				case "import": obj_dialogue.dialogue_start(dt_ask_import); break;
				case "wipe":   obj_dialogue.dialogue_start(dt_ask_delete); break;
			}
			exit;
		}
	}

	// ---- THE BIG BUTTONS (his ask, 2026-09-13): the popup asks, then acts ----
	if (!ng_mode) {
		var _bb = __bigbtns();
		for (var _i = 0; _i < array_length(_bb); _i++) {
			var _b = _bb[_i];
			if (!point_in_rectangle(_mx, _my, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h)) continue;
			var _ok = !is_undefined(info[max(0, sel_row)]) && info[max(0, sel_row)].valid;
			if (_b.id == "load" && (sel_row < 0 || !_ok)) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
			play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
			confirm = _b.id;
			exit;
		}
	}

	// ---- the slot rows: A TAP SELECTS (his ask, 2026-09-13) ----
	// In new-game mode the rows are read-only: you are here to see what
	// you would be overwriting, not to load it.
	if (ng_mode) exit;

	for (var _i = 0; _i < 5; _i++) {
		var _ry = __row_y(_i);
		if (!point_in_rectangle(_mx, _my, rail_w, _ry, room_width, _ry + row_h)) continue;
		sel_row = _i;
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
}
