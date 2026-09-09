
// ---- THE OPEN/CLOSE EASE (his ask, 2026-09-09) ----
// move_to's adj is a divisor and delta-aware, so it settles in about
// the same 21 frames on any refresh rate. It SNAPS at the ends rather
// than approaching them forever - __in_off short-circuits on oa >= .999
// and the input gate below waits for exactly that, so the screen has to
// genuinely reach "nothing is offset" or it never accepts a click.
oa = move_to(oa, closing ? 0 : 1, UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;

// closed: the panel is done, and the CleanUp sweeps its furniture
if (closing && oa <= 0) { instance_destroy(); exit; }

// the scrollbar fades on `enabled` (its own Step), so it leaves with
// the panel rather than hanging over an empty room
if (instance_exists(sb)) sb.enabled = (oa >= .999 && !closing);

__tick += delta; // the change-pulse clock

// the favourite gutter's slide: names step right as the star comes out
// from behind the rail, and back when it goes
fav_t = trickle(fav_t, fav_show ? 1 : 0, 5);
if (abs(fav_t - (fav_show ? 1 : 0)) < .01) fav_t = fav_show ? 1 : 0;

// ---- rebuild: throttled for value freshness, instant for structure ----
utic -= delta;
if (utic <= 0 || rebuild) {
	utic = 60;
	rebuild = false;
	var _oldmx = mx;
	var _oldrows = view; // __rebuild reassigns; keep the old slice for ghosts
	__rebuild();
	// a folder toggle queued an unfurl: the row delta IS the fold size
	if (anim_pend >= 0) {
		anim_row = anim_pend;
		anim_n = mx - _oldmx;
		anim_t = (anim_n == 0) ? 1 : 0;
		// closing: freeze copies of the removed child rows - the draw
		// slides these GHOSTS back up under the fold (they used to just
		// vanish, his report: the last folder's children disappearing)
		anim_ghost = [];
		if (anim_n < 0)
			for (var _k = 0; _k < -anim_n; _k++)
				if (anim_pend + 1 + _k < array_length(_oldrows))
					array_push(anim_ghost, _oldrows[anim_pend + 1 + _k]);
		anim_pend = -1;
	}
	// the clamp can YANK the page when a close shrinks the list under
	// the scroll (closing the bottom folder while scrolled deep). fold
	// the yank into page_ofs so the pixels stay put and GLIDE home,
	// instead of every row jumping the same frame the anim starts
	var _prepage = g.stats_page;
	g.stats_page = clamp(g.stats_page, 0, max(0, mx - full_rows));
	if (anim_t < 1 && g.stats_page != _prepage)
		page_ofs += g.stats_page - _prepage;
}
if (anim_t < 1) {
	anim_t = trickle(anim_t, 1, 5);
	if (anim_t > .98) anim_t = 1;
}
if (page_ofs != 0) {
	page_ofs = trickle(page_ofs, 0, 5);
	if (abs(page_ofs) < .05) page_ofs = 0;
}

// ---- widget chaperone: park EVERYTHING ever registered (a widget
// whose folder just collapsed isn't in the current build, but it
// still needs parking), then place what's visible. the window reaches
// span_max rows ABOVE the first visible index so a tall widget whose
// head row scrolled past the top keeps its position (it slides under
// the title strip: rows draw in draw begin, widgets at depth+1, the
// strip in the controller's Draw_0 covers them, the menu covers all) ----
for (var _i = 0; _i < array_length(widgets_all); _i++)
	if (instance_exists(widgets_all[_i])) widgets_all[_i].y = -1000;

var _first = floor(g.stats_page);
var _lo = max(0, _first - span_max + 1);
// while an anim runs, reach past the window like the draw does - a
// widget riding up from below the fold places before its row settles
var _wreach = (anim_t < 1) ? abs(anim_n) : 0;
for (var _r = _lo; _r < min(array_length(view), _first + visible_rows + 1 + _wreach); _r++) {
	var _row = view[_r];
	if (_row.kind != 2) continue;
	if (!instance_exists(_row.inst)) continue;
	var _ay = __anim_off(_r);
	if (__row_y(_r) + _ay + row_h * _row.span < list_y) continue; // fully gone
	// a widget on an UNFURLING child stays parked until its row clears
	// the fold line (the draw skips those rows too)
	if (anim_t < 1 && anim_n > 0 && _r > anim_row && _r <= anim_row + anim_n)
	if (__row_y(_r) + _ay < __row_y(anim_row) + row_h) continue;
	// the content band, same seat and same gutter slide as the names
	_row.inst.x = content_x + fav_t * 10 + max(0, _row.fdep - 1) * 10;
	_row.inst.y = __row_y(_r) + _ay + ((_row.name != "") ? 14 : 6);
}

// ---- input (region pattern, fully arbitrated) ----
// escape closes, matching settings and the menu drawer. It never OPENS
// anything, so rooms using escape for their own purpose stay safe.
if (keyboard_check_pressed(vk_escape)) { statistics_close(); exit; }

// through the overlay's OWN block: the room behind is held at
// ui_layer_popup and the screen that raised the line has to be above it
// ⚖️ NOTHING IS CLICKABLE UNTIL IT HAS LANDED. Rows animate through
// __anim_off while the hit tests below keep FINAL geometry - this
// framework's own law, hit tests never chase a moving row. So visuals
// and hit tests genuinely disagree for about twenty frames, and the
// honest answer is to take no input at all until they agree again.
// (The hover-only reads in the Draw are exempt by construction: they
// test against _ry, which already carries the offset.)
if (oa >= .999 && !closing)
if (input_free(ui_layer_popup))
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
		// CLOSE, not navigate - the screen is an overlay now and the
		// room you came from never left
		statistics_close();
		exit;
	}

	// the rail: pick a category. Switching resets the scroll, since a
	// remembered page from a long tab means landing mid-air in a short
	// one - settings does the same
	if (mouse_x < rail_w && mouse_y >= list_y) {
		var _tb = __tabs();
		for (var _i = 0; _i < array_length(_tb); _i++)
			if (point_in_rectangle(mouse_x, mouse_y, _tb[_i].x1, _tb[_i].y1,
				_tb[_i].x2, _tb[_i].y2)) {
				if (_i != g.stats_tab) {
					g.stats_tab = _i;
					g.stats_page = 0;
					__slice();
					help_txt = "";
					play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
				}
				exit;
			}
		exit;   // a tap on the rail is never a tap on a row
	}

	// list rows. same geometry as the draw - no drift
	if (mouse_y >= list_y) {
		var _hit = __row_at(mouse_y);
		if (_hit != -1) {
			var _hr = view[_hit];
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
				// THE GUTTER'S BAND. It used to be x <= 9, from when the
				// pips sat at the room's left edge; the rail rebuild
				// moved them into the content band and this did not
				// follow, so the stars could not be tapped (his report
				// 2026-09-06). It answers only while the gutter is out -
				// otherwise a tap here is just a tap on the row.
				if (fav_show && mouse_x <= content_x + 10) {
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
