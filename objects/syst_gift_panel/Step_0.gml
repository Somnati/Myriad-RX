// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

// collect feedback melts
if (flash > 0) flash -= .04 * delta;
else slot_flash = -1;

// ---- input: only once the panel has fully arrived, and only while
// nothing sits over it (a dropdown, the menu) ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_popup)) exit;
if (keyboard_check_pressed(vk_escape)) { gift_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// collect: the button is the action, but the spotlight card takes the
// tap too (mobile - the big pretty thing should also work)
if (gift_can_claim())
if (point_in_rectangle(mouse_x, mouse_y, btn_x, btn_y, btn_x + btn_w, btn_y + btn_h)
 || point_in_rectangle(mouse_x, mouse_y, spot_x, spot_y, spot_x + spot_w, spot_y + spot_h)) {
	// the ceremony leaves from the spotlight's centre (gift_claim owns
	// the motes: profit's carry the amount into the header, credits'
	// fly to the credit panel)
	var _rw = gift_claim(spot_x + spot_w div 2, spot_y + spot_h div 2);
	if (_rw != undefined) {
		board = gift_board(); // slot 14 rolls a fresh cycle
		flash = 1;
		flash_col = _rw.col;
		slot_flash = _rw.pos;
		float_text(room_width div 2, spot_y + 24, _rw.label, _rw.col, fnt_outline);
		play_sound_ext(snd_matclick2, 1.1, 1.3, .6, 1);
	}
}
