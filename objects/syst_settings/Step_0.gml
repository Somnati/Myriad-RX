
draw_set_font(fnt); // the "?" zone + pillbox widths measure text

// ---- rebuild every step: ~35 rows of struct pushes, trivial - and
// live rebuilding is what lets rows appear/vanish/dim conditionally ----
__rebuild();
g.settings_page = clamp(g.settings_page, 0, max(0, mx - full_rows));

// ---- dropdown pick lands here (the syst_fidget pattern): route it
// to the pill row that owns the open box's kind tag ----
if (_pselid != -1 && pill_kind != "") {
	var _pk = pill_kind;
	pill_kind = "";
	for (var _i = 0; _i < array_length(rows); _i++) {
		var _pr = rows[_i];
		if (_pr.kind == sett_kind_pill && _pr.data.kind == _pk) {
			_pr.data.pick(_pselval);
			break;
		}
	}
	_pselid = -1;
	// picks that opened a keep/revert popup save when that resolves;
	// everything else saves now
	if (!confirm_active) dirty_tic = 45;
	play_sound_ext(snd_matclick2, 1, 1.2, .5, 1);
}

// ---- the keep/revert countdown ----
// pauses while the menu drawer is up (the popup hides under it); on
// zero the change undoes itself - that's the whole "picked a
// resolution the display can't show" escape hatch
if (confirm_active)
if (!variable_global_exists("input_block") || g.input_block < ui_layer_menu) {
	confirm_tic -= delta;
	if (confirm_tic <= 0) {
		confirm_revert();
		confirm_active = false;
		dirty_tic = 45;
		play_sound_ext(snd_matclick, .8, .9, .5, 1);
	}
	else if (input_free(ui_layer_popup))
	if (mouse_check_button_pressed(mb_left)) {
		var _cb = __confirm_box();
		if (point_in_rectangle(mouse_x, mouse_y, _cb.kx1, _cb.ky1, _cb.kx2, _cb.ky2)) {
			confirm_active = false; // keep: the change already applied
			dirty_tic = 45;
			play_sound_ext(snd_matclick2, 1.1, 1.3, .5, 1);
		}
		if (point_in_rectangle(mouse_x, mouse_y, _cb.rx1, _cb.ry1, _cb.rx2, _cb.ry2)) {
			confirm_revert();
			confirm_active = false;
			dirty_tic = 45;
			play_sound_ext(snd_matclick, .8, .9, .5, 1);
		}
	}
}

// ---- debounced settings save: any change arms dirty_tic (widgets do
// it themselves, row-taps do it below); when it runs out, one save.
// held while a confirmation is pending - never persist an unconfirmed
// display change ----
if (dirty_tic > 0 && !confirm_active) {
	dirty_tic -= delta;
	if (dirty_tic <= 0) {
		syst_handle_save.action = sv_save; // writes save + settings.ini
		saved_flash = 90;
	}
}
if (saved_flash > 0) saved_flash -= delta;

// ---- widget chaperone: park EVERYTHING pooled first (rows on other
// tabs, rows that vanished this pass - all their widgets go off
// screen), then place the active tab's visible ones. widgets ride at
// depth-1, so one scrolled partway past the top slides UNDER the
// title strip (the proxy at depth-2 paints over them) ----
var _keys = variable_struct_get_names(pool);
for (var _i = 0; _i < array_length(_keys); _i++) {
	var _w = pool[$ _keys[_i]];
	if (instance_exists(_w)) _w.y = -1000;
}

var _first = floor(g.settings_page);
for (var _r = _first; _r < min(mx, _first + visible_rows + 1); _r++) {
	var _row = view[_r];
	if (_row.inst == noone || !instance_exists(_row.inst)) continue;
	var _ry = __row_y(_r);
	if (_ry + row_h < list_y) continue; // fully gone: stay parked
	switch (_row.kind) {
		case sett_kind_toggle: _row.inst.x = val_x - 18; _row.inst.y = _ry + 3; break;
		case sett_kind_radio:  _row.inst.x = val_x - 10; _row.inst.y = _ry + 3; break;
		case sett_kind_slider: _row.inst.y = _ry + 3; break; // x baked at spawn
	}
}

// ---- input (region pattern, fully arbitrated: widgets and the
// scrollbar own their own clicks; the confirm popup and any open
// pillbox raise the block, which mutes all of this for free) ----
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

	// the round ? button: flip every hint whisper at once
	if (point_distance(mouse_x, mouse_y, room_width - 74, bby + 7) <= 8) {
		g.settings_hints = !g.settings_hints;
		if (!g.settings_hints) help_txt = ""; // fold an open explainer too
		play_sound_ext(snd_softclick, g.settings_hints ? 1.1 : .9,
			g.settings_hints ? 1.2 : 1, .4, 1);
		exit;
	}

	// the category rail: switch tabs, fresh scroll
	var _tb = __tabs();
	for (var _i = 0; _i < array_length(_tb); _i++) {
		var _t = _tb[_i];
		if (point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2)) {
			if (g.settings_tab != _t.idx) {
				g.settings_tab = _t.idx;
				g.settings_page = 0;
				help_txt = "";
				if (instance_exists(sb)) {
					sb.ty = 0; // the scrollbar's touch position IS the
					sb.ty_speed_actual = 0; // page - move both or it drifts
					sb.ty_speed = 0;
				}
				play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
			}
			exit;
		}
	}

	// list rows (right of the rail). same geometry as the draw
	if (mouse_x >= rail_w)
	if (mouse_y >= list_y) {
		var _hit = __row_at(mouse_y);
		if (_hit != -1) {
			var _hr = view[_hit];
			if (help_txt != "") {
				help_txt = ""; // an open explainer eats the next tap
			}
			else {
				// the "?" zone opens help on ANY row that carries it
				// (only while the strip's ? button has hints showing)
				var _tx = content_x + 2 + _hr.ind * 8;
				var _qx = _tx + string_width(_hr.name) + 5;
				if (g.settings_hints
				&&  _hr.help != "" && mouse_x >= _qx - 3 && mouse_x <= _qx + 9) {
					help_txt = _hr.help;
					help_x = mouse_x;
					help_y = mouse_y;
					play_sound_ext(snd_softclick, 1, 1, .3, 1);
				}
				else switch (_hr.kind) {

				case sett_kind_toggle: // fat target: the whole row flips
					_hr.data.set(!_hr.data.get());
					if (instance_exists(_hr.inst)) _hr.inst.sync();
					dirty_tic = 45;
					play_sound_ext(_hr.data.get() ? snd_matclick2 : snd_matclick,
						1.15, 1.5, .5, 1);
					break;

				case sett_kind_radio: // whole row picks the option
					if (!_hr.data.on()) {
						_hr.data.pick();
						dirty_tic = 45;
						play_sound_ext(snd_matclick2, 1.1, 1.3, .5, 1);
					}
					break;

				case sett_kind_pill: // open the dropdown at the tap
					pillbox_init();
					pill_kind = _hr.data.kind;
					_hr.data.build();
					do_pillbox(mouse_x, mouse_y);
					// pills spawn at owner depth-1, which the strip proxy
					// (-2) and scrollbar (-3) would cover - lift OUR box
					// above both (the menu at -520 still tops it)
					with (obj_pillbox) if (obj == other.id) depth = other.depth - 4;
					break;

				case sett_kind_action:
					play_sound_ext(snd_matclick2, .9, 1.1, .5, 1);
					_hr.data(); // methods keep their declared scope
					break;

				case sett_kind_info:
					if (_hr.help != "") {
						help_txt = _hr.help;
						help_x = mouse_x;
						help_y = mouse_y;
						play_sound_ext(snd_softclick, 1, 1, .3, 1);
					}
					break;
				}
			}
		}
	}
}
