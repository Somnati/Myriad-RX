
// input: region pattern, fully arbitrated (menu/popup blockers mute
// the whole bench for free)
if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {

	// back, top right of the title strip
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 62, bby + 1,
		room_width - 6, bby + 14)) {
		play_sound_ext(snd_matclick2, .8, .9, .5, 1);
		back_room();
		exit;
	}

	// the bench buttons (headers don't respond)
	for (var _i = 0; _i < array_length(rows); _i++) {
		var _r = rows[_i];
		if (_r.fn == -1) continue;
		var _ry = __row_y(_i);
		if (point_in_rectangle(mouse_x, mouse_y, btn_x, _ry,
			btn_x + btn_w, _ry + btn_h - 1)) {
			play_sound_ext(snd_matclick2, .95, 1.15, .5, 1);
			_r.fn();
			break;
		}
	}
}
