// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }
if (instance_exists(sb)) sb.enabled = (oa >= .999 && !closing);

// ---- the live drag, first: it owns the pointer until released ----
if (drag_row >= 0) {
	if (!mouse_check_button(mb_left)) { drag_row = -1; save_mark_dirty(); }
	else {
		var _tr = (drag_which == 1) ? __tm_r(drag_row)
		        : ((drag_which == 2) ? __cap_r(drag_row) : __trk_r(drag_row));
		__set_row(drag_rw, __pick(drag_rw, _tr, drag_which), (drag_which == 1) ? 1 : 0);
		exit;
	}
}

// input: only once the panel has fully arrived, and only while nothing
// sits over it (a pillbox, a popup, the menu)
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) { automation_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// (the wheel and the touch drag are the house bar's now - scrl_autom
// in obj_scrollbar writes scroll[tab])
rows_n = array_length(__page_rows());
scroll[tab] = clamp(scroll[tab], 0, max(0, rows_n - __rows_fit()));

if (!mouse_check_button_pressed(mb_left)) exit;

// ---- the [overclock] chip in the RAM band ----
{
	var _oc = __oc_rect();
	if (point_in_rectangle(mouse_x, mouse_y, _oc.x, _oc.y, _oc.x + _oc.w, _oc.y + _oc.h)) {
		__oc_flip();
		exit;
	}
}

// ---- the rail ----
for (var _t = 0; _t < NTAB; _t++) {
	var _r = __tab_rect(_t);
	if (!point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h))
		continue;
	if (tab != _t) {
		tab = _t;
		// the bar re-seats on this tab's own scroll
		if (instance_exists(sb)) { sb.ty = scroll[tab] * row_p; sb.ty_speed = 0; sb.ty_speed_actual = 0; }
		play_sound_ext(snd_softclick, 1, 1.1, .45, 0);
	}
	exit;
}

// ---- the page's controls ----
var _rows = __page_rows();
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _rw = _rows[_i];
	if (!__row_hit(_i)) continue;
	if (_rw.kind == 8) {
		// a band's button, if it has one
		if (_rw.btn != "") {
			var _bb = __btn_r(_i, 0, 1);
			if (point_in_rectangle(mouse_x, mouse_y, _bb.x, _bb.y, _bb.x + _bb.w, _bb.y + _bb.h)) {
				__action(_rw, 0);
				exit;
			}
		}
		continue;
	}

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

	// an action row: its buttons, from the right - or the whole row,
	// when it is one that folds its actions out
	if (_rw.kind == 7) {
		var _nb = array_length(_rw.btns);
		if (_nb == 0 && variable_struct_exists(_rw, "chev")) {
			var _ry7 = __row_y(_i);
			if (point_in_rectangle(mouse_x, mouse_y, cont_x, _ry7, cont_x + cont_w, _ry7 + row_h)) { __action(_rw, -1); exit; }
			continue;
		}
		for (var _b = 0; _b < _nb; _b++) {
			var _br = __btn_r(_i, _b, _nb);
			if (!point_in_rectangle(mouse_x, mouse_y, _br.x, _br.y, _br.x + _br.w, _br.y + _br.h)) continue;
			__action(_rw, _b);
			exit;
		}
		continue;
	}
	if (_rw.kind == 6) continue;

	if (_rw.kind == 0 || _rw.kind == 2 || _rw.kind == 4 || _rw.kind == 5) {   // has a toggle
		var _tg = __tog_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _tg.x, _tg.y, _tg.x + _tg.w, _tg.y + _tg.h)) {
			__flip_row(_rw);
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			save_mark_dirty();
			exit;
		}
	}
	// a fat grab zone on every track: a 5px track is a 5px target, and
	// this is a touch build
	if (_rw.kind == 1 || _rw.kind == 2) {   // the wide slider
		var _tk = __trk_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _tk.x - 3, _tk.y - 5,
			_tk.x + _tk.w + 3, _tk.y + _tk.h + 5)) {
			drag_row = _i; drag_tab = tab; drag_which = 0; drag_rw = _rw;
			drag_lo  = _rw.lo; drag_hi = _rw.hi;
			__set_row(_rw, __pick(_rw, _tk, 0));
			exit;
		}
	}
	if (_rw.kind == 5) {   // the cap track and the timer track
		var _ck = __cap_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _ck.x - 3, _ck.y - 5,
			_ck.x + _ck.w + 3, _ck.y + _ck.h + 5)) {
			drag_row = _i; drag_tab = tab; drag_which = 2; drag_rw = _rw;
			drag_lo  = _rw.lo; drag_hi = _rw.hi;
			__set_row(_rw, __pick(_rw, _ck, 2), 0);
			exit;
		}
		var _tm = __tm_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _tm.x - 3, _tm.y - 5,
			_tm.x + _tm.w + 3, _tm.y + _tm.h + 5)) {
			drag_row = _i; drag_tab = tab; drag_which = 1; drag_rw = _rw;
			drag_lo  = RAM_TIMER_MIN; drag_hi = RAM_TIMER_MAX;
			__set_row(_rw, __pick(_rw, _tm, 1), 1);
			exit;
		}
	}
}
