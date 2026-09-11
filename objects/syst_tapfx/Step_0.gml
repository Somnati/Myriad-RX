tm += delta / 60;
if (!__live()) {
	// nothing performs outside the money room; drop what was in flight
	glows = []; rings = []; craters = []; shocks = []; slashes = []; heat = 0;
	exit;
}

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
	for (var _i = 0; _i < array_length(fx_names); _i++)
		set_pill(fx_names[_i], { val : _i, col : (g.tap_fx == _i) ? c_gold : sett_ink,
		                         enabled : (g.tap_fx == _i) });
	var _r = __chip_r();
	do_pillbox(_r.x + _r.w + 2, _r.y + _r.h * .5);   // off the chip's right; the box clamps itself into the room
	play_sound_ext(snd_softclick, .9, 1.1, .4, 1);
}

// ---- the effects tick ----
for (var _i = array_length(glows) - 1; _i >= 0; _i--) {
	glows[_i].t += delta;
	if (glows[_i].t >= 10) array_delete(glows, _i, 1);
}
for (var _i = array_length(rings) - 1; _i >= 0; _i--) {
	rings[_i].r   += 2.4 * delta;
	rings[_i].amp *= power(.93, delta);
	if (rings[_i].amp < .35 || rings[_i].r > 70) array_delete(rings, _i, 1);
}
for (var _i = array_length(craters) - 1; _i >= 0; _i--) {
	craters[_i].d *= power(.86, delta);
	if (craters[_i].d < .12) array_delete(craters, _i, 1);
}
for (var _i = array_length(shocks) - 1; _i >= 0; _i--) {
	shocks[_i].r += 1.1 * delta;
	if (shocks[_i].r > (shocks[_i].crit ? 22 : 16)) array_delete(shocks, _i, 1);
}
for (var _i = array_length(slashes) - 1; _i >= 0; _i--) {
	slashes[_i].t += delta;
	if (slashes[_i].t >= 7) array_delete(slashes, _i, 1);
}

// hold heat: builds while the tap surface is held, cools when it lets go
var _hold = (g.tap_fx == 6) && instance_exists(obj_clicker) && obj_clicker.hold_on
	&& mouse_check_button(mb_left);
heat = trickle(heat, _hold ? 1 : 0, _hold ? 40 : 8, 0);
if (_hold) { hx = trickle(hx, mouse_x, 3, 0); hy = trickle(hy, mouse_y, 3, 0); }
if (heat < .003) { hx = mouse_x; hy = mouse_y; }
