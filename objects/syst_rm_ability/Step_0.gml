
// ---- rebuild passes ----
// the controller's grab is always a FULL pass (a_ = -1): it reseeds
// the batch offsets and materializes the inspected card in one sweep
if (a != previous_a || input_changed > 0) {
	grab_deck();
	previous_a = a;
}
if (update_ap) {
	update_ap = false;
	grab_deck_ap();
	get_ability_cost();
}

// collection mode owns the scrollbar range (grab_deck_ap owns it in
// deck mode)
if (view == 1) mx = array_length(coll_rows);

// ---- info panel: when the materialized card changed, the current
// panel becomes the outgoing state and the new card slides in ----
if (aid != shown_aid) {
	shown_aid = aid;
	o_name = i_name; o_text = i_text; o_rarity = i_rarity;
	o_apreq = i_apreq; o_flavor = i_flavor;
	f = 0;
	repeat (5) {
		o_flavor_text[f]  = i_flavor_text[f];
		o_flavor_color[f] = i_flavor_color[f];
		f++;
	}
	o_tos = i_tos; o_alpha = i_alpha;

	if (aid == -1) {
		i_name = "ability deck";
		i_text = "tap an ability to read it.\ntap its ap chip to toggle it.\ndiscover new abilities below.";
		i_rarity = -1; i_apreq = 0; i_flavor = 0;
	} else {
		i_name = name; i_text = txt; i_rarity = rarity;
		i_apreq = apreq; i_flavor = flavor;
		f = 0;
		repeat (5) {
			i_flavor_text[f]  = flavor_text[f];
			i_flavor_color[f] = flavor_color[f];
			f++;
		}
	}
	i_tos = 8; i_alpha = 0;
}
i_tos = trickle(i_tos, 0, 4);
i_alpha = trickle(i_alpha, 1, 4);
o_tos = trickle(o_tos, -8, 4);
o_alpha = trickle(o_alpha, 0, 4);

reveal_t = max(0, reveal_t - delta);

// ---- loadout overwrite confirmation lands here (pillbox pick) ----
if (_pselid != -1 && pill_kind == "lo_ow") {
	if (_pselval == 1 && pending_lo != -1) {
		var _arr3 = array_create(array_length(g.abi_keys), 0);
		for (var _i = 0; _i < array_length(g.abi_keys); _i++)
			_arr3[_i] = (variable_global_get(g.abi_keys[_i]) == 1) ? 1 : 0;
		g.abi_loadout[pending_lo] = _arr3;
		save_mark_dirty();
		play_sound_ext(snd_pop, 1.1, 1.3, .5, 1);
	}
	lo_set = false;
	pending_lo = -1;
	pill_kind = "";
	_pselid = -1;
}

// ---- the discovery draft is MODAL: while it's up, its obj_card
// faces are the only thing listening. the deck drives the cards
// (staggered flip reveal, hover tilt); obj_card just renders ----
if (array_length(g.abi_draft) > 0) {
	if (array_length(draft_ids) != array_length(g.abi_draft)) __draft_spawn();

	for (var _d = 0; _d < array_length(draft_ids); _d++) {
		var _c = draft_ids[_d];
		if (!instance_exists(_c)) continue;
		if (_c.flip_delay > 0) { _c.flip_delay -= delta; continue; }
		var _hov = point_in_rectangle(mouse_x, mouse_y,
			_c.x - _c.card_w * .5, _c.y - _c.card_h * .5,
			_c.x + _c.card_w * .5, _c.y + _c.card_h * .5);
		// hover leans the card toward the pointer; idle keeps it held
		var _ty2 = _hov ? clamp((mouse_x - _c.x) * .35, -14, 14)
			: 4 * dsin(current_time / 900 + _d * 2);
		var _tx2 = _hov ? clamp(-(mouse_y - _c.y) * .35, -14, 14)
			: 3 * dsin(current_time / 1300 + _d);
		_c.rot_y = trickle(_c.rot_y, _ty2, 6); // 180 -> 0 = the reveal flip
		_c.rot_x = trickle(_c.rot_x, _tx2, 6);
	}

	if (input_free())
	if (mouse_check_button_pressed(mb_left)) {
		for (var _d = 0; _d < array_length(draft_ids); _d++) {
			var _c2 = draft_ids[_d];
			if (!instance_exists(_c2)) continue;
			if (_c2.rot_y > 60) continue; // still flipping: not claimable
			// obj_card sits in syst_input's owner families, so a
			// hovered card OWNS the click - the old `owner == noone`
			// gate rejected every card tap. accept ownership, or a
			// free click inside the rect (the bbox trails the mesh)
			var _own = (variable_global_exists("click_owner")
				&& g.click_owner == _c2);
			var _freeclk = (!variable_global_exists("click_owner")
				|| g.click_owner == noone);
			var _in = point_in_rectangle(mouse_x, mouse_y,
				_c2.x - _c2.card_w * .5, _c2.y - _c2.card_h * .5,
				_c2.x + _c2.card_w * .5, _c2.y + _c2.card_h * .5);
			if (_own || (_freeclk && _in)) {
				deck_draft_pick(g.abi_draft[_d]);
				break;
			}
		}
	}
	exit; // nothing else in the room takes input under a draft
} else if (array_length(draft_ids) > 0) {
	// draft resolved: the cards go away
	for (var _d = 0; _d < array_length(draft_ids); _d++)
		if (instance_exists(draft_ids[_d])) instance_destroy(draft_ids[_d]);
	draft_ids = [];
}

// ---- input (region pattern, fully arbitrated) ----
if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {

	// back, top right
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 62, 30, room_width - 6, 46)) {
		play_sound_ext(snd_matclick2, .8, .9, .5, 1);
		back_room();
		exit;
	}

	// discover: spend units, then a DRAFT of up to three seeded
	// candidates rises - the player picks one. gate on the POOL, not
	// the counts - paying while nothing is drawable would eat units.
	// the free-purchasing debug toggle waives the units cost
	if (point_in_rectangle(mouse_x, mouse_y, info_x, 200, info_x + info_w, 224)) {
		if (array_length(g.abi_pool) > 0
		&& (g.abi_free || g.units >= g.new_ability_cost)) {
			if (!g.abi_free) g.units = do_subtract(g.units, g.new_ability_cost);
			deck_draft_roll();
			play_sound_ext(snd_pop, .9, 1.1, .5, 1);
		} else play_sound_ext(snd_softclick, .7, .8, .4, 1);
	}

	// debug: grant exactly the next discovery's cost in units
	if (point_in_rectangle(mouse_x, mouse_y, info_x, 230, info_x + 70, 244)) {
		g.units = do_add(g.units, do_ceil(g.new_ability_cost));
		play_sound_ext(snd_pop, 1.0, 1.2, .4, 1);
	}

	// ---- debug row, bottom left: unlock all / enable all / free ----
	if (point_in_rectangle(mouse_x, mouse_y, 6, 250, 76, 264)) {
		for (var _i = 0; _i < array_length(g.abi_keys); _i++)
			if (variable_global_get(g.abi_keys[_i]) == -1)
				variable_global_set(g.abi_keys[_i], 0);
		fetch_new_ability();
		input_changed = 2;
		update_ap = true;
		with (obj_ability_slot) input_changed = 2;
		play_sound_ext(snd_pop, .8, 1.0, .5, 1);
	}
	if (point_in_rectangle(mouse_x, mouse_y, 82, 250, 152, 264)) {
		// enable everything discovered (grab_deck_ap clamps the
		// over-committed pool to 0 gracefully)
		for (var _i = 0; _i < array_length(g.abi_keys); _i++)
			if (variable_global_get(g.abi_keys[_i]) != -1)
				variable_global_set(g.abi_keys[_i], 1);
		input_changed = 2;
		update_ap = true;
		with (obj_ability_slot) input_changed = 2;
		save_mark_dirty();
		play_sound_ext(snd_pop, 1.0, 1.2, .5, 1);
	}
	if (point_in_rectangle(mouse_x, mouse_y, 158, 250, 228, 264)) {
		g.abi_free = !g.abi_free;
		play_sound_ext(snd_matclick2, 1.0, 1.1, .5, 1);
	}

	// view toggle: the deck list <-> the collection
	if (point_in_rectangle(mouse_x, mouse_y, 234, 250, 304, 264)) {
		view = 1 - view;
		g.ability_page = 0;
		if (view == 0) update_ap = true; // restore the deck's row count
		play_sound_ext(snd_matclick2, 1.0, 1.1, .5, 1);
	}

	// ---- loadout presets, top of the right column: tap a slot to
	// APPLY its stored enable-set; [set] arms the next tap to STORE ----
	for (var _l = 0; _l < 3; _l++)
	if (point_in_rectangle(mouse_x, mouse_y, 296 + _l * 22, 30, 312 + _l * 22, 44)) {
		if (lo_set) {
			if (is_array(g.abi_loadout[_l])) {
				// occupied slot: confirm the overwrite via pillbox
				pending_lo = _l;
				pillbox_init();
				pill_kind = "lo_ow";
				set_pill("overwrite " + string(_l + 1), { val : 1, col : c_hred });
				set_pill("cancel", { val : 0, col : rgb(170, 190, 230) });
				do_pillbox(mouse_x, mouse_y);
			} else {
				var _arr = array_create(array_length(g.abi_keys), 0);
				for (var _i = 0; _i < array_length(g.abi_keys); _i++)
					_arr[_i] = (variable_global_get(g.abi_keys[_i]) == 1) ? 1 : 0;
				g.abi_loadout[_l] = _arr;
				lo_set = false;
				save_mark_dirty();
				play_sound_ext(snd_pop, 1.1, 1.3, .5, 1);
			}
		} else if (is_array(g.abi_loadout[_l])) {
			// apply: every DISCOVERED ability takes the stored state;
			// locked ones are untouched, dependencies re-enforce, and
			// an over-committed pool clamps gracefully
			var _arr2 = g.abi_loadout[_l];
			for (var _i = 0; _i < array_length(g.abi_keys); _i++) {
				var _v = variable_global_get(g.abi_keys[_i]);
				if (_v == -1) continue;
				var _want = (_i < array_length(_arr2)) ? _arr2[_i] : 0;
				variable_global_set(g.abi_keys[_i], _want);
			}
			deck_failsafes();
			update_ap = true;
			input_changed = 2;
			with (obj_ability_slot) input_changed = 2;
			save_mark_dirty();
			play_sound_ext(snd_apply, .9, 1.1, .5, 1);
		} else play_sound_ext(snd_softclick, .6, .7, .4, 1); // empty slot
	}
	if (point_in_rectangle(mouse_x, mouse_y, 362, 30, 390, 44)) {
		lo_set = !lo_set;
		play_sound_ext(snd_matclick2, 1.0, 1.1, .4, 1);
	}

	// the list: which row is under the pointer. the TOGGLE is the pip
	// on the card's RIGHT; the rest of the row inspects. (deck view
	// only - the collection is display-only)
	if (view == 0)
	if (point_in_rectangle(mouse_x, mouse_y,
		list_x, list_y, list_x + list_w, list_y + visible_rows * row_h)) {
		// match the VISUAL rows exactly: they ride the fractional page
		// offset (yos), and the capsule is 11px of the 15px pitch -
		// the gutter between capsules is dead space
		var _yoff = row_h * (round(g.ability_page) - g.ability_page);
		var _rel = mouse_y - list_y - _yoff;
		var _hrow = floor(_rel / row_h);
		var _ta = -999;
		if (_rel - _hrow * row_h <= 11) _ta = _hrow + round(g.ability_page);
		var _tog = (mouse_x >= list_x + list_w - 26); // the toggle pip zone
		with (obj_ability_slot) {
			if (a != _ta) continue;
			if (input == -1 || input == 3) continue;
			if (_tog && other.can_edit && tog && open == true) {
				// toggling ON needs the AP; toggling OFF is free
				var _on = (input == 0 || input >= 100);
				if (!_on || g.ap >= apreq) pending_toggle = true;
				else play_sound_ext(snd_softclick, .6, .7, .4, 1); // can't afford
			} else if (!_tog) {
				pending_inspect = true;
				other.a = _ta;
				play_sound_ext(snd_softclick, 1.0, 1.1, .4, 1);
			}
		}
	}
}
