
// the menu doesn't exist until a run has started (his rule: no header
// menu before continue/new game) - the title screen stays clean
if (!variable_global_exists("game_started") || !g.game_started) exit;

tic -= delta;
// ⚖️ THE BURGER IS THE OVERLAY'S X TOO (his suggestion). Settings and
// statistics cover the room from the header down and the burger is the
// one control still above them, so it becomes the way out rather than a
// second way in - and it wears the X while it means that, which is the
// morph it already had for its own drawer.
var _ovl = (ui_overlay() != noone);
t = move_to(t, (open || _ovl) ? 1 : 0, 4); // adj is a divisor (delta-aware)
rip = max(0, rip - .06 * delta);
hot = point_in_rectangle(mousex, mousey, room_width - 26, 12, room_width - 2, 32);

// the trigger lives at the MENU layer so it stays clickable while the
// open menu blocks the room behind it (region pattern, no sprite)
if (input_free(ui_layer_menu))
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (hot && tic <= 0) {
	tic = 8;
	// an overlay is up: this press CLOSES it and opens nothing. Two
	// panels over each other with one X between them is a guessing game.
	if (_ovl) {
		ui_overlay_close();
		rip = 1;
		play_sound_ext(snd_matclick2, .7, .8, .5, 1);
		exit;
	}
	open = !open;
	rip = 1;
	if (open) {
		if (!instance_exists(syst_menu2)) create_obj(0, 0, syst_menu2);
		play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
	}
	else play_sound_ext(snd_matclick2, .7, .8, .5, 1);
}

// escape closes (pc nicety; it never OPENS, so room escape uses stay safe)
if (open && keyboard_check_pressed(vk_escape)) {
	open = false;
	rip = 1;
	play_sound_ext(snd_matclick2, .7, .8, .5, 1);
}
