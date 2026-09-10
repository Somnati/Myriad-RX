// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

// ---- the scroll settles: a flick coasts, and the range is clamped ----
if (drag_y < 0) {
	scroll += sv * delta;
	sv *= power(.88, delta);
	if (abs(sv) < .05) sv = 0;
}
var _smax = __scroll_max();
if (scroll < 0)     { scroll = 0;     sv = 0; }
if (scroll > _smax) { scroll = _smax; sv = 0; }

// ---- input: only once the panel has fully arrived, and only while
// nothing sits over it ----
if (oa < .999 || closing) { drag_y = -1; exit; }
if (!input_free(ui_layer_popup)) { drag_y = -1; exit; }
if (keyboard_check_pressed(vk_escape)) { faq_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// the wheel scrolls the band (pc)
var _wh = (mouse_wheel_down() ? 1 : 0) - (mouse_wheel_up() ? 1 : 0);
if (_wh != 0 && mouse_x >= rail_w && mouse_y >= list_y) {
	scroll += _wh * 36;
	sv = 0;
}

// a press: on the rail it switches tabs; in the band it starts a drag
if (mouse_check_button_pressed(mb_left)) {
	var _tb = __tabs();
	for (var _i = 0; _i < array_length(_tb); _i++) {
		var _t = _tb[_i];
		if (point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2)) {
			if (tab != _t.idx) {
				tab = _t.idx;
				scroll = 0; sv = 0;
				play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
			}
			exit;
		}
	}
	if (mouse_x >= rail_w && mouse_y >= list_y) {
		drag_y = mouse_y;
		drag_s = scroll;
		dragged = false;
		sv = 0;
	}
}

// the drag: the band follows the finger (touch), and a release with
// travel left over keeps coasting
if (drag_y >= 0) {
	if (mouse_check_button(mb_left)) {
		var _d = drag_y - mouse_y;
		if (abs(_d) > 6) dragged = true;
		if (dragged) {
			var _ns = drag_s + _d;
			sv = _ns - scroll;
			scroll = _ns;
		}
	} else {
		drag_y = -1;
		if (!dragged) sv = 0;
	}
}
