oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) {
	var _open_log = to_log;
	instance_destroy();
	if (_open_log) offlog_open();   // the card is gone, the log takes its place
	exit;
}
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
// the [log] chip: the full story, in the offline log
if (mouse_check_button_pressed(mb_left)) {
	var _lr = __log_r();
	if (point_in_rectangle(mouse_x, mouse_y, _lr.x, _lr.y, _lr.x + _lr.w, _lr.y + _lr.h)) {
		to_log = true;
		closing = true;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// a tap anywhere, or escape: done reading
if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_left)) {
	closing = true;
	play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
}
