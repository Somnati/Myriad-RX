if (!__live()) { glows = []; shocks = []; exit; }

// ---- the pick lands (the pillbox hands it back on this instance) ----
if (_pselid != -1) {
	g.tap_fx = _pselval;
	_pselid = -1;
	if (instance_exists(syst_handle_save)) syst_handle_save.action = sv_save;   // settings.ini
}

// ---- the chip: open the list ----
if (input_free() && g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (__consumes(mouse_x, mouse_y)) {
	pillbox_init();
	var _cur = __fx();
	for (var _i = 0; _i < array_length(fx_names); _i++)
		set_pill(fx_names[_i], { val : _i, col : (_cur == _i) ? c_gold : sett_ink,
		                         enabled : (_cur == _i) });
	var _r = __chip_r();
	do_pillbox(_r.x + _r.w + 2, _r.y + _r.h * .5);   // off the chip's right; the box clamps itself into the room
	play_sound_ext(snd_softclick, .9, 1.1, .4, 1);
}

// ---- the effects tick ----
for (var _i = array_length(glows) - 1; _i >= 0; _i--) {
	glows[_i].t += delta;
	if (glows[_i].t >= 10) array_delete(glows, _i, 1);
}
for (var _i = array_length(shocks) - 1; _i >= 0; _i--) {
	shocks[_i].r += 1.6 * delta;   // (was 1.1 to 16: smaller and faster, his call)
	if (shocks[_i].r > (shocks[_i].crit ? 16 : 12)) array_delete(shocks, _i, 1);
}
