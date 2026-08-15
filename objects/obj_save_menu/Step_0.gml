
// kh slide between the two pages
slide += (page - slide) * .2;
if (abs(page - slide) < .002) slide = page;

// refresh the profile cards whenever page 0 settles back in (a save
// may have been created since)
if (page == 1) prof_fresh = false;
if (page == 0 && slide < .02 && !prof_fresh) {
	for (var _i = 0; _i < 4; _i++) {
		prof_info[_i] = save_slot_info(save_slot_path(0, _i));
		if (prof_info[_i].valid) {
			if (prof_info[_i].name != "") g.profile_name[_i]  = prof_info[_i].name;
			if (prof_info[_i].color >= 0) g.profile_color[_i] = prof_info[_i].color;
		}
	}
	prof_fresh = true;
}

// region ui plays by syst_input's rules: input must be free (no
// dialogue/menu up: begin-step timing also eats the click that picks
// an option) and no button instance may own the pointer over a row
if (input_free())
if (g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {
	var _mx = mouse_x;
	var _my = mouse_y;

	// back, top right (was MISSING - the title's load path stranded
	// you here; the nav stack returns wherever you came from)
	if (point_in_rectangle(_mx, _my, room_width - 62,
		obj_ui_header.sprite_height + 1, room_width - 6,
		obj_ui_header.sprite_height + 14)) {
		play_sound_ext(snd_matclick2, .8, .9, .5, 1);
		back_room();
		exit;
	}

	if (page == 0 && slide < .5) {
		// ---- profile list ----
		for (var _i = 0; _i < 4; _i++) {
			var _ry = row_y0 + _i * row_sp;
			if (point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h)) {
				sel_prof = _i;
				play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
				// new-game mode: occupied slot = confirm the overwrite
				// first; empty slot = straight to the difficulty page
				if (ng_mode) {
					var _has = !is_undefined(prof_info[_i]) && prof_info[_i].valid;
					if (_has) {
						obj_dialogue.box_col_border = g.profile_color[sel_prof];
						obj_dialogue.dialogue_start(dt_ng_over);
					} else page = 1;
					break;
				}
				// refresh the slot cards for this profile
				for (var _j = 0; _j < 5; _j++)
					info[_j] = save_slot_info(save_slot_path(slot_of_row[_j], sel_prof));
				page = 1;
				break;
			}
		}
	} else if (page == 1 && slide > .5) {
		// new-game mode: page 1 is the difficulty picker - the pick
		// pulls the trigger (wipe slot, reset run, first-save, play)
		if (ng_mode) {
			for (var _i = 0; _i < 4; _i++) {
				var _ry = row_y0 + _i * row_sp;
				if (!point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h)) continue;
				ng_start(_i);
				break;
			}
			exit;
		}
		// (back navigation is the framework obj_button_back now)
		for (var _i = 0; _i < 5; _i++) {
			var _ry = row_y0 + _i * row_sp;
			if (!point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h)) continue;
			var _slot = slot_of_row[_i];

			if (_slot == 4) { show("rebirth slot > reserved"); break; }

			// clicking a slot opens the options popup: the dialogue
			// trees (bound methods in create) do the actual work.
			// the box wears the savefile's personal color
			dlg_row = _i;
			play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
			obj_dialogue.box_col_border = g.profile_color[sel_prof];
			if (_slot == 0)
				obj_dialogue.dialogue_start(info[_i].valid ? dt_slot_main : dt_slot_new);
			else
				obj_dialogue.dialogue_start(info[_i].valid ? dt_slot_auto : dt_slot_empty);
			break;
		}
	}
}
