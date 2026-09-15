// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

var _c = g.ccore;
flash = max(0, flash - .04 * delta);
glow  = trickle(glow, (_c.st == 1) ? .5 : ((_c.st == 2) ? 1 : 0), 8, 0);

// ---- the split slider's drag: it owns the pointer until released ----
if (drag) {
	if (!mouse_check_button(mb_left)) { drag = false; save_mark_dirty(); }
	else {
		var _r = __sl_r();
		// (the knob toward "capacity" - the LEFT end - is more capacity:
		// split is the capacity share, so it is 100 minus the knob's place.
		// his report, 2026-09-14: it read backwards)
		_c.split = 100 - clamp(round(lerp(0, 100, (mouse_x - _r.x) / max(1, _r.w)) / 5) * 5, 0, 100);
		exit;
	}
}

// ---- input: once the panel has fully arrived, and while nothing sits
// over it (a pillbox, the menu) ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) { ccore_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// collect: the button, and the disc itself (the big pretty thing
// should also work - the gift's rule)
var _cb = __col_r();
if (point_in_rectangle(mouse_x, mouse_y, _cb.x, _cb.y, _cb.x + _cb.w, _cb.y + _cb.h)
 || point_distance(mouse_x, mouse_y, disc_cx, disc_cy) <= disc_r) {
	var _n = ccore_collect(disc_cx, disc_cy);
	if (_n > 0) {
		flash = 1;
		float_text(disc_cx, disc_cy - disc_r - 6, "+" + string(_n) + " credits", c_lavender, fnt_outline);
		// DE's press: the heavy tap under the diamond (obj_button_install),
		// then the motes chime out one by one (ccore_collect)
		play_sound_ext(snd_tapheavy, .8, .9, .3, 1);
	} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
	exit;
}

// the split slider (a fat grab zone: a 5px track is a 5px target)
var _sr = __sl_r();
if (_c.lv > 0)
if (point_in_rectangle(mouse_x, mouse_y, _sr.x - 3, _sr.y - 6, _sr.x + _sr.w + 3, _sr.y + _sr.h + 6)) {
	drag = true;
	_c.split = 100 - clamp(round(lerp(0, 100, (mouse_x - _sr.x) / max(1, _sr.w)) / 5) * 5, 0, 100);
	exit;
}

// the level ladder
var _br = __buy_r();
if (point_in_rectangle(mouse_x, mouse_y, _br.x, _br.y, _br.x + _br.w, _br.y + _br.h)) {
	var _was = _c.lv;
	if (ccore_buy()) {
		play_sound_ext(snd_apply, 1.0, 1.2, .5, 1);
		if (_was == 0) assign_banner("credit core unlocked", c_lavender, c_black);
	} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
	exit;
}
