// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

// the bar scrolls the band (wheel + touch drag) and writes `scroll`
if (instance_exists(sb)) sb.enabled = (oa >= .999 && !closing);
scroll = clamp(scroll, 0, __scroll_max());

// ---- input: once the panel has fully arrived, and while nothing sits
// over it (a pillbox, the menu) ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) { offlog_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// [debug]: swap every card for its raw form (and show the sim row)
var _dr = __dbg_r();
if (point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) {
	g.offlog.debug = !g.offlog.debug;
	scroll = 0;
	if (instance_exists(sb)) { sb.ty = 0; sb.ty_speed_actual = 0; sb.ty_speed = 0; }
	play_sound_ext(snd_softclick, g.offlog.debug ? 1.1 : .9, g.offlog.debug ? 1.2 : 1, .4, 1);
	exit;
}

// the sim row (debug only): feed offline_replay FOR REAL - the exact
// entry the boot path uses, so the whole pipeline runs (Techdemo II's
// bench). Mutating, and the row says so.
if (g.offlog.debug)
for (var _i = 0; _i < array_length(sims); _i++) {
	var _sr = __sim_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _sr.x, _sr.y, _sr.x + _sr.w, _sr.y + _sr.h)) {
		offline_replay(sims[_i][0], "sim " + sims[_i][1]);
		scroll = 0;
		if (instance_exists(sb)) { sb.ty = 0; sb.ty_speed_actual = 0; sb.ty_speed = 0; }
		play_sound_ext(snd_apply, 1.0, 1.2, .5, 1);
		exit;
	}
}
