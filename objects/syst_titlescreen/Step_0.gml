
tt += delta;
var _had = has_save;
has_save = file_exists(save_file); // load room can create/erase saves
if (has_save != _had) { items = __items(); hov = array_create(array_length(items), 0); any_save = __any_save(); }

// hover ease per row. One number drives the brighten, the slide and the
// accent bar (see the Draw), so they cannot disagree about how hovered a
// row is - and a disabled continue never invites a hover at all.
// move_to's adj is a divisor: 5 is a quick settle that still reads as a
// movement, and it eases OUT at the same rate it eased in, which is what
// makes a row you have left look genuinely at rest.
for (var _i = 0; _i < array_length(items); _i++) {
	var _ry = row_y0 + _i * row_p;
	var _en = (items[_i] != "continue") || has_save;
	var _on = _en && point_in_rectangle(mouse_x, mouse_y,
		rule_x, _ry, lm + row_w, _ry + row_h);
	hov[_i] = move_to(hov[_i], _on ? 1 : 0, 5);
}

if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {
	for (var _i = 0; _i < array_length(items); _i++) {
		var _ry = row_y0 + _i * row_p;
		// the hit rect reaches back to the accent column so the bar is
		// part of the target rather than decoration beside it
		if (!point_in_rectangle(mouse_x, mouse_y, rule_x, _ry,
			lm + row_w, _ry + row_h)) continue;

		var _it = items[_i];

		if (_it == "continue" && has_save) { // boot already loaded it
			// CONTINUE GETS ITS OWN SOUND (his file: a digital
			// rainstick). Not the interface click every other row here
			// makes - this is the one press that ends the title screen
			// and starts the run.
			//
			// TAKE ONE ONLY. The source is 24 seconds holding SIX takes
			// of the same sound on a four-second grid, which as a single
			// asset meant pressing continue played all six with the
			// silences between them (his catch). The envelope puts the
			// first at 0.00-2.50 with a second and a half of room after
			// it, so that is what got cut: 2.49s, and it still runs long
			// enough to carry the wipe rather than finishing before it.
			//
			// Pitched FLAT on purpose: the other rows roll their pitch
			// so a repeated press stays alive, and this one is never
			// repeated - a rolled pitch would only detune it.
			//
			// QUIET (his report: too loud). It is the one number worth
			// knowing here, because the asset itself is HOT: the library
			// mastered this cue at 0.116 peak and the import normalised
			// it to 0.85, which is right for keeping the noise floor
			// down but leaves it louder than everything around it. .25
			// is about 7dB under where it started.
			play_sound_ext(snd_continue, 1, 1, .25, 1);
			g.game_started = true;
			g.room_hist = [];
			goto_room(rm_clicker);
		}
		if (_it == "new game") { // the slot + difficulty picker (his
			// overhaul, 2026-07-10). NO game_restart and NO deletion
			// here - rm_saves opens in new-game mode, and files only go
			// when a difficulty is picked on a chosen slot. The
			// in-memory reset is game_reset() (the old restart-free
			// path leaked cores/batteries/machines/dims/tiles)
			play_sound_ext(snd_matclick2, 1.1, 1.3, .6, 1);
			// a fresh install has no profile to pick: straight to the
			// difficulty list on the active (empty) profile
			if (!any_save) { g.ng_prof = g.profile; goto_room(rm_newgame); break; }
			g.saves_mode = "newgame";
			goto_room(rm_saves);
		}
		if (_it == "load") { // the saves bench; back returns here
			play_sound_ext(snd_matclick2, .95, 1.1, .5, 1);
			goto_room(rm_saves);
		}
		if (_it == "quit") {
			play_sound_ext(snd_matclick2, .8, .9, .5, 1);
			goto_room(rm_quit);
		}
		break;
	}
}
