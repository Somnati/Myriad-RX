hov = -1;
if (mouse_y >= tab_y - 12 && mouse_y < tab_y + row_h * (array_length(amounts) + 1))
if (mouse_x >= label_w) hov = clamp(floor((mouse_x - label_w) / col_w), 0, array_length(fmts) - 1);

// a header press picks that format for the whole game
if (input_free() && g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (hov != -1 && mouse_y >= tab_y - 12 && mouse_y < tab_y) {
	g.num_format = hov;
	if (instance_exists(syst_handle_save)) syst_handle_save.action = sv_save;
	play_sound_ext(snd_matclick2, 1.1, 1.3, .5, 1);
}
