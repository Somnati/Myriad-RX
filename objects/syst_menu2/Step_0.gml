
tic -= delta;

// mirror the trigger; fold and die when it clears
if (instance_exists(obj_ui_menu2)) open = obj_ui_menu2.open;
else open = false;
am = move_to(am, open ? 1 : 0, 4); // move_to's adj is a divisor (delta-aware)
if (!open && am < .01) { kill; exit; }
// the glass capture slot (see the Create): only for the glass style
if (variable_global_exists("menu_style") && g.menu_style == "glass") {
	if (!instance_exists(snap_px)) {
		snap_px = create_obj(0, 0, obj_draw_proxy);
		snap_px.owner = id;
		snap_px.fn    = __snap_cap;
	}
	snap_px.depth = (ui_overlay() != noone) ? -514 : -499;
} else if (instance_exists(snap_px)) { instance_destroy(snap_px); snap_px = noone; snap_ok = false; }

// blur rides the fold, and switches off entirely at zero.
// g.blur (settings > display "menu blur") was a DEAD SETTING - saved,
// defaulted, and read by nothing, so the toggle did nothing at all
// (his report 2026-09-06). It gates the layer now; the default flipped
// to on so the look is unchanged for anyone who never touches it.
// (blur: ui_blur_tick reads `am` off this instance every frame)

// the bar rides the sliding edge and the fold - it is the only
// scrollbar in the game whose owner moves
if (instance_exists(sb)) {
	// TIED TO THE DRAWER'S RIGHT EDGE (his call) - the panel was widened
	// by exactly the bar's width so the rows still end clear of it
	sb.x = panel_x + pw - sprite_get_width(spr_scrollbar);
	sb.y = hdr_h + 2;
	sb.image_yscale = (room_height - hdr_h - foot_h - 4)
		/ sprite_get_height(spr_scrollbar);
	sb.visible = (am > .9);
	sb.enabled = (am > .9);
	// AND IT WEARS THE ROOM YOU ARE IN. The bar sits beside a column of
	// colour-coded rows, so a white thumb was the one thing in the
	// drawer with no identity - it carries the current room's hue now,
	// which is the same mark the wide row and the gold pip are making.
	var _bc = c_white;
	for (var _q = 0; _q < array_length(btns); _q++) {
		if (is_method(btns[_q].rm)) continue;
		if (!in_room(btns[_q].rm)) continue;
		_bc = merge_colour(btns[_q].col, c_white, .25);
		break;
	}
	sb.col = _bc;
}

// per-button hover ease: the gradient wipe reads off this, so pointing
// at a row is a state that ARRIVES rather than a colour that appears
// (his report: "i dont want it to instantly change colors"). adj 3 is
// about a third of the remaining distance a frame - quick, but a frame
// of it is still visible, which is the whole point.
var _hit = __layout();
for (var _q = 0; _q < array_length(btns); _q++) hov[_q] = move_to(hov[_q], 0, 3);
for (var _q = 0; _q < array_length(_hit); _q++) {
	var _r = _hit[_q];
	if (_r.kind != 0) continue;
	if (!point_in_rectangle(mousex, mousey, _r.x1, _r.y1, _r.x2, _r.y2)) continue;
	hov[_r.idx] = move_to(hov[_r.idx], 1, 3);
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
		// 12px a notch, halved from 24 (his call): one click was moving
		// most of a short list. The bar's own wheel step halved with it.
		if (mouse_wheel_up())   scr = clamp(scr - 12, 0, scr_max);
		if (mouse_wheel_down()) scr = clamp(scr + 12, 0, scr_max);
	}

	if (pressed && !mouse_check_button(mb_left)) {
		pressed = false;
		if (touch_dragdist < 8 && tic <= 0) {
			// THE TAP
			var _it = __layout();
			_hit = -1;   // (declared above - the layout read; reused for the tap)
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
