
__tick += delta; // the change-pulse clock

if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {
	var _bby = obj_ui_header.sprite_height;

	// [favs]: show or hide the per-row star gutter (his ask 2026-09-06)
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 106,
		_bby + 6, room_width - 66, _bby + 22)) {
		fav_show = !fav_show;
		g.stats_fav_show = fav_show;
		save_mark_dirty();
		play_sound_ext(snd_softclick, fav_show ? 1.1 : .9,
			fav_show ? 1.2 : .9, .4, 1);
	}

	// back, top right (in the title strip, above the list)
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 62,
		_bby + 6, room_width - 6, _bby + 22)) {
		play_sound_ext(snd_matclick2, .8, .9, .5, 1);
		back_room();
		exit;
	}

	// list rows. same geometry as the draw - no drift
	if (mouse_y >= list_y) {
		var _hit = __row_at(mouse_y);
		if (_hit != -1) {
			var _hr = rows[_hit];
			if (help_txt != "") {
				help_txt = ""; // an open explainer eats the next tap
			}
			else if (_hr.kind == 1) {
				g.stats_open[$ _hr.path] = !_hr.open;
				rebuild = true;
				anim_pend = _hit; // queue the unfurl off this fold line
				play_sound_ext(snd_softclick, _hr.open ? .9 : 1.1, _hr.open ? 1.0 : 1.2, .4, 1);
			}
			else if (_hr.kind == 4) {
				// flip the global the row carries as data
				if (variable_global_exists(_hr.val))
					variable_global_set(_hr.val, !(variable_global_get(_hr.val) == true));
				rebuild = true;
				save_mark_dirty();
				play_sound_ext(snd_matclick2, _hr.open ? .9 : 1.1, _hr.open ? 1.0 : 1.2, .5, 1);
			}
			else if (_hr.kind == 5) {
				// cycle: advance the carried global through its options
				var _n = max(1, array_length(_hr.data));
				var _iv = 0;
				if (variable_global_exists(_hr.val)) _iv = variable_global_get(_hr.val);
				variable_global_set(_hr.val, (_iv + 1) mod _n);
				rebuild = true;
				save_mark_dirty();
				play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
			}
			else if (_hr.kind == 0 && _hr.name != "") {
				// the gutter only answers while it is on screen -
				// otherwise a tap at the row's left edge is just a tap
				// on the row, and opens its explainer
				if (fav_show && mouse_x <= 9) {
					// the star gutter: pin/unpin into the favorites section
					var _now = !(g.stats_fav[$ _hr.key] ?? false);
					if (_now) g.stats_fav[$ _hr.key] = true;
					else if (variable_struct_exists(g.stats_fav, _hr.key))
						variable_struct_remove(g.stats_fav, _hr.key);
					rebuild = true;
					save_mark_dirty();
					play_sound_ext(snd_softclick, _now ? 1.2 : .8, _now ? 1.3 : .9, .4, 1);
				}
				else if (_hr.help != "") {
					// tap-for-info: float the explainer near the tap
					help_txt = _hr.help;
					help_x = mouse_x;
					help_y = mouse_y;
					play_sound_ext(snd_softclick, 1, 1, .3, 1);
				}
			}
		}
	}
}
