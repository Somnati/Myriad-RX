
tt += delta;
has_save = file_exists(save_file); // load room can create/erase saves

// hover bounce springs (the draw inflates the chrome from these; a
// disabled continue never invites a hover). damped spring per button:
// stiffness pulls toward the target, damping bleeds velocity - enter
// overshoots and settles, exit bounces back; snap kills residual
// motion so rest is truly still
for (var _i = 0; _i < 5; _i++) {
	var _by = btn_y0 + _i * btn_p;
	var _en = (_i != 1) || has_save;
	var _tgt = (_en && point_in_rectangle(mouse_x, mouse_y, btn_x, _by,
		btn_x + btn_w, _by + btn_h)) ? 1 : 0;
	hv[_i] = (hv[_i] + (_tgt - hov[_i]) * .22 * delta) * power(.78, delta);
	hov[_i] += hv[_i] * delta;
	if (abs(hv[_i]) < .002 && abs(_tgt - hov[_i]) < .004) {
		hov[_i] = _tgt;
		hv[_i] = 0;
	}
}

if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {
	for (var _i = 0; _i < 5; _i++) {
		var _by = btn_y0 + _i * btn_p;
		if (!point_in_rectangle(mouse_x, mouse_y, btn_x, _by,
			btn_x + btn_w, _by + btn_h)) continue;

		if (_i == 0) { // new game: the slot + difficulty picker (his
			// overhaul, 2026-07-10). NO game_restart and NO deletion
			// here - rm_saves opens in new-game mode, and files only
			// go when a difficulty is picked on a chosen slot. the
			// in-memory reset is game_reset() (the old restart-free
			// path leaked cores/batteries/machines/dims/tiles)
			play_sound_ext(snd_matclick2, 1.1, 1.3, .6, 1);
			g.saves_mode = "newgame";
			goto_room(rm_saves);
		}
		if (_i == 1 && has_save) { // continue: boot already loaded it
			// CONTINUE GETS ITS OWN SOUND (his ask): a device powering
			// up, from the sci-fi pack. Not the interface click every
			// other button here makes - this is the one press that ends
			// the title screen and starts the run, and it is long enough
			// (1.4s) to carry the wipe rather than finishing before it.
			// Pitched flat on purpose: the buttons roll their pitch so a
			// repeated press stays alive, and this one is never repeated.
			play_sound_ext(snd_continue, 1, 1, .55, 1);
			g.game_started = true;
			g.room_hist = [];
			goto_room(rm_clicker);
		}
		if (_i == 2) { // load: the saves bench; back returns here
			play_sound_ext(snd_matclick2, .95, 1.1, .5, 1);
			goto_room(rm_saves);
		}
		if (_i == 3) { // settings; back returns here (nav stack)
			play_sound_ext(snd_matclick2, .95, 1.1, .5, 1);
			goto_room(rm_settings);
		}
		if (_i == 4) { // quit
			play_sound_ext(snd_matclick2, .8, .9, .5, 1);
			goto_room(rm_quit);
		}
		break;
	}
}
