
draw_set_font(fnt); // the "?" zone + pillbox widths measure text

// ---- THE OPEN/CLOSE EASE (his ask, 2026-09-09) ----
// move_to's adj is a divisor and it is delta-aware, so this settles in
// about the same 21 frames on any refresh rate. It SNAPS at the ends
// rather than approaching them forever: __in_off short-circuits on
// oa >= .999, and the whole screen has to reach a state where nothing
// is offset at all or the hit tests below never line up with the rows.
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;

// ---- THE PEEK: a held visualiser knob, the visualiser in the room ----
var _pk = noone;
if (instance_exists(obj_bignum5) && !closing)
	with (obj_set_slider) if (live && grabbed) _pk = id;
if (_pk != noone) peek_inst = _pk;
peek = move_to(peek, (_pk != noone) ? 1 : 0, 5);
if (peek < .01 && _pk == noone) { peek = 0; peek_inst = noone; }
oa_blur = oa * (1 - peek);

// an open dropdown goes NOW, not in the CleanUp: obj_pillbox draws at
// full alpha and knows nothing about the fade, so leaving it up would
// park a solid box over a panel that is visibly gone
if (closing) {
	with (obj_pillbox) if (obj == other.id) instance_destroy();
	pill_kind = "";
}

// closed: the panel is done. Everything settings_close had to do
// happened when it was pressed - this is only the furniture leaving.
if (closing && oa <= 0) { instance_destroy(); exit; }

// the scrollbar fades itself out on `enabled` (its own Step), so it
// leaves with the panel instead of hanging in an empty screen
if (instance_exists(sb)) sb.enabled = (oa >= .999 && !closing);

// ---- rebuild every step: ~35 rows of struct pushes, trivial - and
// live rebuilding is what lets rows appear/vanish/dim conditionally ----
__rebuild();
g.settings_page = clamp(g.settings_page, 0, max(0, mx - full_rows));
fav_t += ((fav_show ? 1 : 0) - fav_t) * min(1, .2 * delta);

// ---- dropdown pick lands here (the syst_fidget pattern): route it
// to the pill row that owns the open box's kind tag ----
if (_pselid != -1 && pill_kind != "") {
	var _pk = pill_kind;
	var _stay = false;
	for (var _i = 0; _i < array_length(rows); _i++) {
		var _pr = rows[_i];
		if (_pr.kind == sett_kind_pill && _pr.data.kind == _pk) {
			_pr.data.pick(_pselval);
			_stay = _pr.data.stay;
			break;
		}
	}
	// ⚖️ A STAYING BOX KEEPS ITS KIND TAG, or the next pick has nothing
	// to route to and the box goes deaf after one choice. It also has to
	// RELIGHT by hand: the pills are structs the spawned instances hold
	// references to (set_pill's contract), so flipping `enabled` is the
	// whole update - no rebuild, no respawn, no flicker.
	pill_kind = _stay ? _pk : "";
	if (_stay)
		for (var _q = 0; _q < array_length(_pills); _q++)
			_pills[_q].enabled = (_pills[_q].val == _pselval);
	_pselid = -1;
	click_tic = 12;   // DE's tic: the pick's press must not also be a row's
	// picks that opened a keep/revert popup save when that resolves;
	// everything else saves now
	if (!confirm_active) dirty_tic = 45;
	// AN AUDITION ROW MAKES NO UI CLICK. Picking a sound already plays
	// that sound, and laying the interface's own click over it is the
	// same complaint he made about the tapper: something else talking
	// while he is trying to hear the thing he picked.
	if (!_stay) play_sound_ext(snd_matclick2, 1, 1.2, .5, 1);
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
	// ⚖️ THE WIDGET FADES WITH ITS ROW. The rows dissolve through a
	// shader, but a widget is a separate instance drawing in its own
	// event, so the shader never reaches it - image_alpha is the lane
	// that does. Toggles and radios have no Draw at all and honour it
	// for free; obj_set_slider paints by hand and multiplies it in.
	_row.inst.image_alpha = ui_anim_in(oa, _r - floor(g.settings_page)) * ((_row.inst == peek_inst) ? 1 : (1 - peek));
	switch (_row.kind) {
		case sett_kind_toggle: _row.inst.x = val_x - 18; _row.inst.y = _ry + 3; break;
		case sett_kind_radio:  _row.inst.x = val_x - 10; _row.inst.y = _ry + 3; break;
		case sett_kind_slider: _row.inst.y = _ry + 3; break; // x baked at spawn
	}
}

// ---- input (region pattern, fully arbitrated: widgets and the
// scrollbar own their own clicks; the confirm popup and any open
// pillbox raise the block, which mutes all of this for free) ----
// through the overlay's OWN block (see the Create): the room behind is
// held at ui_layer_popup, and the screen that raised the line has to be
// above it
// ⚖️ NOTHING IS CLICKABLE UNTIL IT HAS LANDED. Rows animate through
// __row_y while __row_at (the inverse) deliberately keeps FINAL
// geometry - the statistics framework's law, hit tests never chase a
// moving row. That means visuals and hit tests genuinely disagree for
// about twenty frames, so the honest answer is to accept no input at
// all until they agree again. It also kills the click-through: a press
// that opened this panel can no longer run twice on the way in.
// ⚖️ ui_layer_overlay, NOT ui_layer_popup (his report, 2026-09-10:
// picking a pill also opened the settings row under it). The popup
// gate dates from when this overlay raised the popup block itself;
// since the overlay rung landed, a pillbox's block (200) no longer
// muted a gate at 200 - so the press that picked the pill fell through
// to the row it was floating over. At the panel's own rung the rows
// are free with the panel up and muted under any pillbox or popup.
// escape closes (the menu drawer's own nicety; it never OPENS settings,
// so rooms that use escape for something else stay safe) - behind the
// same landing + input gate as the taps
if (oa >= .999 && !closing && input_free(ui_layer_overlay))
if (keyboard_check_pressed(vk_escape)) { settings_close(); exit; }

click_tic = max(0, click_tic - delta);

// ⚖️ THE GATE, AS EXITS (his report, 2026-09-10: "the menu blur toggle
// doesn't work"). Since the overlay port (de2ae9e) the three conditions
// - landed, input free, no click owner - were a braceless if-chain
// with the ESCAPE line slipped in as its one statement, so the whole
// tap block under it ran ungated: no landing gate, no input gate and
// NO OWNER CHECK. A press on a toggle's PADDLE was then handled twice
// - by the widget (its own arbitrated click) and by the row ("the
// whole row flips") - two flips, net nothing; the label half of the
// row still worked, which is why some toggles seemed fine. It is also
// where this morning's pillbox click-throughs came from. Exits now,
// so nothing can be slipped between the gate and the taps again.
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
// NO ROW HEARS A PRESS WHILE A DROPDOWN EXISTS (DE's rule, his ask) or
// while the click timer runs - the pillbox owns the pointer until it
// has gone, however the frames fall
if (instance_exists(obj_pillbox) || click_tic > 0) exit;

// ---- THE HOLD (settings_action's hold rows): the pointer held on the
// row fills it over ~three quarters of a second and fires at full; off
// the row or let go, it empties ----
if (hold_row >= 0) {
	var _hr2 = (hold_row < array_length(view)) ? view[hold_row] : undefined;
	var _on = !is_undefined(_hr2) && mouse_check_button(mb_left) && mouse_x >= rail_w
		&& __row_at(mouse_y) == hold_row;
	if (_on) {
		hold_hp += delta * (100 / 45);
		if (hold_hp >= 100) {
			hold_hp = 0; hold_row = -1;
			play_sound_ext(snd_matclick2, .9, 1.1, .5, 1);
			_hr2.data();
			click_tic = 6;
		}
	} else { hold_row = -1; hold_hp = 0; }
	exit;
}
if (mouse_check_button_pressed(mb_left)) {
	click_tic = 6;   // DE's tic: one tap, then a beat

	// (no back button - the burger is the X, his call 2026-09-10)

	// [hints]: flip every "?" whisper at once (a chip beside [favs] -
	// the round button it replaced "felt out of place", his report
	// 2026-09-12)
	if (point_in_circle(mouse_x, mouse_y, room_width - 84 + 6, bby + 8, 7.5)) {
		g.settings_hints = !g.settings_hints;
		if (!g.settings_hints) help_txt = ""; // fold an open explainer too
		play_sound_ext(snd_softclick, g.settings_hints ? 1.1 : .9,
			g.settings_hints ? 1.2 : 1, .4, 1);
		exit;
	}

	// [favs]: show or hide the star gutter
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 62, bby + 1, room_width - 22, bby + 14)) {
		fav_show = !fav_show;
		g.settings_fav_show = fav_show;
		dirty_tic = 45;
		play_sound_ext(snd_softclick, fav_show ? 1.1 : .9, fav_show ? 1.2 : .9, .4, 1);
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
			else if (fav_show && !_hr.group && _hr.sec != "favorites" && _hr.name != ""
			&& mouse_x <= content_x + 8) {
				// THE STAR GUTTER: pin/unpin the row on the favorites tab
				// (only while the gutter is out - otherwise a tap here is
				// just a tap on the row). The same key from either tab
				var _fk = __fav_key(_hr);
				var _now = !(g.settings_fav[$ _fk] ?? false);
				if (_now) g.settings_fav[$ _fk] = true;
				else if (variable_struct_exists(g.settings_fav, _fk))
					variable_struct_remove(g.settings_fav, _fk);
				dirty_tic = 45;
				play_sound_ext(snd_softclick, _now ? 1.2 : .8, _now ? 1.3 : .9, .4, 1);
			}
			else {
				// the "?" zone opens help on ANY row that carries it
				// (only while the strip's ? button has hints showing)
				var _tx = content_x + 2 + _hr.ind * 8 + round(fav_t * 8);
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
					// ⚖️ THE SAME ROW TOGGLES. Pressing an open dropdown's
					// own row should shut it - that is what every
					// dropdown anywhere does, and without it a staying
					// box (the sound rows, the dice material) can only
					// be closed by tapping off it, which is exactly the
					// press that used to stack a second box.
					if (_popen && pill_kind == _hr.data.kind) {
						_popen = false;
						pill_kind = "";
						break;
					}
					// (belt and braces to the ui_layer_overlay gate: while
					// ANY box of ours is up, no row may open another)
					if (_popen || instance_exists(obj_pillbox)) break;
					pillbox_init();
					pill_kind = _hr.data.kind;
					_hr.data.build();
					// a STAYING box is an audition box: it opens and picks
					// silently, because the sound it picks IS the feedback
					do_pillbox(mouse_x, mouse_y, _hr.data.stay ? 1 : 0,
						-1, false, _hr.data.stay);
					// pills spawn at owner depth-1, which the strip proxy
					// (-2) and scrollbar (-3) would cover - lift OUR box
					// above both (the menu at -520 still tops it)
					with (obj_pillbox) if (obj == other.id) depth = other.depth - 4;
					break;

				case sett_kind_action:
					if (_hr[$ "hold"] ?? false) {   // a hold row: arm the clock, fire at full
						hold_row = _hit; hold_hp = 0;
						play_sound_ext(snd_softclick, .9, 1, .3, 1);
						break;
					}
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
