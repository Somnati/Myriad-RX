/// the panel's pulse: the open ease, then the hits (region law: every
/// hit here mirrors Draw's geometry)

// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

hot_row = -1; hot_btn = 0; hot_def = false;
if (oa < .999 || closing) { drag = -1; exit; }
if (!input_free(ui_layer_overlay)) { drag = -1; exit; }
if (keyboard_check_pressed(vk_escape)) { cheat_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) { drag = -1; exit; }

var _p = mouse_check_button_pressed(mb_left);
var _h = mouse_check_button(mb_left);
var _v = g.cheat.v;

// ---- hover ----
hot_def = point_in_rectangle(mouse_x, mouse_y, x1 - def_w, band_y - 2, x1, band_y + 12);
for (var _i = 0; _i < N; _i++) {
	var _ry = row_y0 + _i * row_h;
	if (mouse_y < _ry || mouse_y >= _ry + row_h) continue;
	if (mouse_x < x0 || mouse_x >= x1) continue;
	hot_row = _i;
	var _by = land ? _ry + 1 : _ry + 1;
	if (point_in_rectangle(mouse_x, mouse_y, bx_minus, _by, bx_minus + bw_btn, _by + 13)) hot_btn = -1;
	if (point_in_rectangle(mouse_x, mouse_y, bx_plus,  _by, bx_plus + bw_btn,  _by + 13)) hot_btn = 1;
	break;
}

// ---- [default] ----
if (_p && hot_def) {
	if (cheat_reset()) play_sound_ext(snd_matclick2, 1, 1.15, .5, 1);
	else play_sound_ext(snd_matclick, .6, .75, .3, 1);
	exit;
}

// ---- the buttons: a press, then hold-to-repeat ----
if (hot_row >= 0 && hot_btn != 0) {
	if (_p) { __step(hot_row, hot_btn); rep_t = 22; }
	else if (_h) {
		rep_t -= delta;
		if (rep_t <= 0) { __step(hot_row, hot_btn); rep_t = 5; }
	}
	drag = -1;
	exit;
}

// ---- the bar: press or drag sets the row outright ----
if (_p && hot_row >= 0) {
	var _b = __bar(hot_row);
	if (point_in_rectangle(mouse_x, mouse_y, _b.x - 2, _b.y - 4, _b.x + _b.w + 2, _b.y + _b.h + 4)) drag = hot_row;
}
if (!_h) drag = -1;
if (drag >= 0) {
	var _b = __bar(drag);
	var _want = clamp((mouse_x - _b.x) / max(1, _b.w), 0, 1) * CHEAT_ROW_MAX;
	var _was = _v[drag];
	if (cheat_set(drag, _want) && abs(_v[drag] - _was) >= CHEAT_STEP)
		play_sound_ext(snd_softclick, .9 + .3 * (_v[drag] / CHEAT_ROW_MAX), 1 + .3 * (_v[drag] / CHEAT_ROW_MAX), .3, 1);
}
