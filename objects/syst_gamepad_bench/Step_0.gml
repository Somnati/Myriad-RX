/// taps + slider drags, house region pattern (menu/popup blockers
/// mute the bench for free)

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

	// rumble test / reset binds
	if (point_in_rectangle(mouse_x, mouse_y, sld_x, btn_y, sld_x + 70, btn_y + 13)) {
		pad_rumble(.8, 30);
		array_push(g.pad.log, "rumble test (active "
			+ ((g.pad.active >= 0) ? string(g.pad.active) : "none") + ")");
		play_sound_ext(snd_matclick2, .95, 1.15, .5, 1);
	}
	if (point_in_rectangle(mouse_x, mouse_y, sld_x + 76, btn_y, sld_x + 152, btn_y + 13)) {
		// hard reset: fresh defaults, saved over the old rebinds.
		// action names don't change, so state/rows stay valid.
		g.pad.acts = pad_config();
		g.pad.act_names = variable_struct_get_names(g.pad.acts);
		g.pad.rebind = "";
		pad_binds_save();
		array_push(g.pad.log, "binds reset to defaults");
		play_sound_ext(snd_matclick2, .7, .8, .5, 1);
	}

	// slider grabs (generous 8px band around the 4px bar)
	if (point_in_rectangle(mouse_x, mouse_y, sld_x, dz_y + 6, sld_x + sld_w, dz_y + 16))
		drag = "dz";
	if (point_in_rectangle(mouse_x, mouse_y, sld_x, thr_y + 6, sld_x + sld_w, thr_y + 16))
		drag = "thr";

	// action rows: tap = arm rebind (tap again = cancel)
	for (var _i = 0; _i < array_length(rows); _i++) {
		var _ry = __act_y(_i);
		if (point_in_rectangle(mouse_x, mouse_y, act_x, _ry, act_x + act_w, _ry + 10)) {
			pad_rebind(rows[_i]);
			play_sound_ext(snd_matclick2, 1.05, 1.2, .5, 1);
			break;
		}
	}
}

// slider drag rides the held button; release saves
if (drag != "") {
	if (mouse_check_button(mb_left)) {
		var _t = clamp((mouse_x - sld_x) / sld_w, 0, 1);
		if (drag == "dz")  g.pad.dz = .05 + _t * .5;      // .05...55
		else               g.pad.digi_thr = .2 + _t * .6; // .2...8
	} else {
		drag = "";
		pad_binds_save();
	}
}
