
tic -= delta;

// mirror the trigger; fold and die when it clears
if (instance_exists(obj_ui_menu2)) open = obj_ui_menu2.open;
else open = false;
am = move_to(am, open ? 1 : 0, 4); // move_to's adj is a divisor (delta-aware)
if (!open && am < .01) { kill; exit; }

// blur rides the fold, and switches off entirely at zero
if (blur_fx != -1) {
	layer_set_visible("menu_blur", am > 0);
	fx_set_parameter(blur_fx, "g_intensity", am);
}

// ---- input: touch-list semantics. presses only ARM; drags scroll
// the list; the tap itself lands on RELEASE inside the drag budget
if (am > .5)
if (input_free(ui_layer_menu))
if (!variable_global_exists("click_owner") || g.click_owner == noone) {

	if (mouse_check_button_pressed(mb_left)) {
		pressed = true;
		lmy = mousey;
	}

	if (pressed && mouse_check_button(mb_left)) {
		// drag-scroll (only when the list overflows)
		if (scr_max > 0 && mousex > panel_x)
			scr = clamp(scr + (lmy - mousey), 0, scr_max);
		lmy = mousey;
	}

	// wheel scrolls too
	if (scr_max > 0) {
		if (mouse_wheel_up())   scr = clamp(scr - 24, 0, scr_max);
		if (mouse_wheel_down()) scr = clamp(scr + 24, 0, scr_max);
	}

	if (pressed && !mouse_check_button(mb_left)) {
		pressed = false;
		if (touch_dragdist < 8 && tic <= 0) {
			// THE TAP
			var _it = __layout();
			var _hit = -1;
			var _top = hdr_h + 2;
			var _bot = room_height - foot_h - 2;
			for (var _i = 0; _i < array_length(_it); _i++) {
				var _o = _it[_i];
				if (!point_in_rectangle(mousex, mousey, _o.x1, _o.y1, _o.x2, _o.y2)) continue;
				// list rows don't respond from under the bands
				if (_o.kind == 0 && (mousey < _top || mousey > _bot)) continue;
				if (_o.kind == 2) { _hit = -2; break; } // labels eat the tap, no action
				if (_o.kind == 3) { _hit = -2; break; } // info lines too (menu2_label)
				_hit = _i;
				break;
			}
			if (_hit >= 0) {
				var _b = btns[_it[_hit].idx];
				tic = 8;
				if (is_method(_b.rm)) {
					// method destinations (the starmap entry rides
					// ship_goto): fold the drawer, run the closure
					if (instance_exists(obj_ui_menu2)) obj_ui_menu2.open = false;
					play_sound_ext(snd_matclick, .8, 1.2, .4, 1);
					_b.rm();
				}
				else if (in_room(_b.rm)) {
					// already here: the menu just folds
					if (instance_exists(obj_ui_menu2)) obj_ui_menu2.open = false;
					play_sound_ext(snd_softclick, .9, 1, .3, 1);
				}
				else {
					play_sound_ext(snd_matclick, .8, 1.2, .4, 1);
					goto_room(_b.rm);
				}
			}
			else if (_hit == -1 && mousex < panel_x && !__guarded()) {
				// tap outside the drawer closes it (unless the room
				// pinned a side rail there - pool's left panel)
				if (instance_exists(obj_ui_menu2)) obj_ui_menu2.open = false;
				play_sound_ext(snd_matclick2, .7, .8, .4, 1);
			}
		}
	}
}
if (!mouse_check_button(mb_left)) pressed = false;
