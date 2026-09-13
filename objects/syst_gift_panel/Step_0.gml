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
if (!input_free(ui_layer_overlay)) exit;   // muted under a pillbox / popup / the menu
if (keyboard_check_pressed(vk_escape)) { gift_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// collect: the button is the action, but the whole card takes the tap
// too (mobile - the big pretty thing should also work)
if (gift_can_claim()) {
	var _b = __btn_r(), _c = __card_r();
	if (point_in_rectangle(mouse_x, mouse_y, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h)
	 || point_in_rectangle(mouse_x, mouse_y, _c.x, _c.y, _c.x + _c.w, _c.y + _c.h)) {
		// the ceremony leaves from the amount (gift_claim owns the
		// motes: profit's carry the amount into the header, credits'
		// fly to the credit panel)
		var _rw = gift_claim(cx + pad + 30, cy + y_big + 7);
		if (_rw != undefined) {
			board = gift_board(); // slot 14 rolls a fresh cycle
			flash = 1;
			flash_col = _rw.rar.col;
			slot_flash = _rw.pos;
			float_text(cx + cw div 2, cy + y_big - 6, _rw.label, _rw.col, fnt_outline);
			play_sound_ext(snd_matclick2, 1.1, 1.3, .6, 1);
		}
	}
}
