// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

// the bar scrolls the band (wheel + touch drag) and writes `scroll`;
// it fades with the panel
if (instance_exists(sb)) sb.enabled = (oa >= .999 && !closing);
scroll = clamp(scroll, 0, __scroll_max());

// ---- input: only once the panel has fully arrived, and only while
// nothing sits over it ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;   // muted under a pillbox / popup / the menu
if (keyboard_check_pressed(vk_escape)) { faq_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// a press on the rail switches tabs (fresh scroll: a remembered page
// from a long tab means landing mid-air in a short one)
if (mouse_check_button_pressed(mb_left)) {
	var _tb = __tabs();
	for (var _i = 0; _i < array_length(_tb); _i++) {
		var _t = _tb[_i];
		if (point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2)) {
			if (tab != _t.idx) {
				tab = _t.idx;
				scroll = 0;
				if (instance_exists(sb)) { sb.ty = 0; sb.ty_speed_actual = 0; sb.ty_speed = 0; }
				play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
			}
			exit;
		}
	}
}
