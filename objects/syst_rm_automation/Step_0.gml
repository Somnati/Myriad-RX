// ---- the live drag, first: it owns the pointer until released ----
if (drag_row >= 0) {
	if (!mouse_check_button(mb_left)) { drag_row = -1; save_mark_dirty(); }
	else {
		__set_slider(drag_tab, drag_row, __slide(drag_row, drag_lo, drag_hi));
		exit;
	}
}

if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

var _bk = __back_rect();
if (point_in_rectangle(mouse_x, mouse_y, _bk.x1, _bk.y1, _bk.x2, _bk.y2)) {
	play_sound_ext(snd_matclick2, .8, .9, .5, 1);
	back_room();
	exit;
}

// ---- the rail ----
for (var _t = 0; _t < NTAB; _t++) {
	var _r = __tab_rect(_t);
	if (!point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h))
		continue;
	if (tab != _t) { tab = _t; play_sound_ext(snd_softclick, 1, 1.1, .45, 0); }
	exit;
}

// ---- the page's controls ----
var _rows = __page_rows();
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _rw = _rows[_i];

	// the rarity chip strip: eight targets in one row
	if (_rw.kind == 3) {
		var _cy = __row_y(_i);
		if (mouse_y < _cy || mouse_y >= _cy + row_h) continue;
		for (var _k = 0; _k < UPG_RARITY_N; _k++) {
			var _ch = __chip_r(_k, _cy);
			if (!point_in_rectangle(mouse_x, mouse_y, _ch.x, _ch.y,
				_ch.x + _ch.w, _ch.y + _ch.h)) continue;
			__flip_chip(_k);
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			save_mark_dirty();
			exit;
		}
		continue;
	}

	if (_rw.kind == 0 || _rw.kind == 2 || _rw.kind == 4) {   // has a toggle
		var _tg = __tog_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _tg.x, _tg.y, _tg.x + _tg.w, _tg.y + _tg.h)) {
			__flip(tab, _i);
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			save_mark_dirty();
			exit;
		}
	}
	if (_rw.kind == 1 || _rw.kind == 2) {   // has a slider
		var _tk = __trk_r(_i);
		// a fat grab zone: a 5px track is a 5px target, and this is a
		// touch build
		if (point_in_rectangle(mouse_x, mouse_y, _tk.x - 3, _tk.y - 5,
			_tk.x + _tk.w + 3, _tk.y + _tk.h + 5)) {
			drag_row = _i;
			drag_tab = tab;
			drag_lo  = _rw.lo;
			drag_hi  = _rw.hi;
			__set_slider(tab, _i, __slide(_i, _rw.lo, _rw.hi));
			exit;
		}
	}
}
