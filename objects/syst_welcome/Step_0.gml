oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
// a tap anywhere, or escape: done reading
if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_left)) {
	closing = true;
	play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
}
