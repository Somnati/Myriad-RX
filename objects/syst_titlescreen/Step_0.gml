
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
			// CONTINUE GETS ITS OWN SOUND (his file: a digital
			// rainstick). Not the interface click every other button
			// here makes - this is the one press that ends the title
			// screen and starts the run.
			//
			// TAKE ONE ONLY. The source is 24 seconds holding SIX takes
			// of the same sound on a four-second grid, which as a single
			// asset meant pressing continue played all six with the
			// silences between them (his catch). The envelope puts the
			// first at 0.00-2.50 with a second and a half of room after
			// it, so that is what got cut: 2.49s, and it still runs long
			// enough to carry the wipe rather than finishing before it.
			//
			// Pitched FLAT on purpose: the other buttons roll their
			// pitch so a repeated press stays alive, and this one is
			// never repeated - a rolled pitch would only detune it.
			//
			// QUIET (his report: too loud). It is the one number worth
			// knowing here, because the asset itself is HOT: the library
			// mastered this cue at 0.116 peak and the import normalised
			// it to 0.85, which is right for keeping the noise floor
			// down but leaves it louder than everything around it. The
			// rest of the buttons on this screen sit at .5-.6 of samples
			// that were already near full scale, so matching them by
			// number would not match them by ear. .25 is about 7dB under
			// where it was.
			play_sound_ext(snd_continue, 1, 1, .25, 1);
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
			// over the title screen, not instead of it - the same door
			// the in-game gear uses
			settings_open();
		}
		if (_i == 4) { // quit
			play_sound_ext(snd_matclick2, .8, .9, .5, 1);
			goto_room(rm_quit);
		}
		break;
	}
}
