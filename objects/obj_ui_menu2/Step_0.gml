
// the menu doesn't exist until a run has started (his rule: no header
// menu before continue/new game) - the title screen stays clean
if (!variable_global_exists("game_started") || !g.game_started) exit;

tic -= delta;
// ⚖️ THE BURGER IS THE OVERLAY'S X TOO (his suggestion). Settings and
// statistics cover the room from the header down and the burger is the
// one control still above them, so it becomes the way out rather than a
// second way in - and it wears the X while it means that, which is the
// morph it already had for its own drawer.
// ⚖️ ...AND IT IS NOT ANY MORE (his report, 2026-09-13: "i can't open the
// hamb menu while i'm in the tiles"). The burger opens the menu over a
// panel too - the drawer draws above every overlay and its lines swap
// panels (the *_open guards fold what is up) - and a panel's own way
// out is the X CHIP beside the burger (__x_r) and escape.
var _ovl = (ui_overlay() != noone);
t = move_to(t, open ? 1 : 0, 4); // adj is a divisor (delta-aware)
rip = max(0, rip - .06 * delta);
xa = move_to(xa, _ovl ? 1 : 0, 4);
hot = point_in_rectangle(mousex, mousey, room_width - 26, 12, room_width - 2, 32);
var _xr = __x_r();
hot_x = _ovl && point_in_rectangle(mousex, mousey, _xr.x, _xr.y, _xr.x + _xr.w, _xr.y + _xr.h);
// the chip: a press closes the panel
if (hot_x && tic <= 0 && input_free(ui_layer_menu) && (!variable_global_exists("click_owner") || g.click_owner == noone)
&& mouse_check_button_pressed(mb_left)) {
	tic = 8; xrip = 1;
	ui_overlay_close();
	play_sound_ext(snd_matclick2, .7, .8, .5, 1);
}
xrip = max(0, xrip - .06 * delta);

// the trigger lives at the MENU layer so it stays clickable while the
// open menu blocks the room behind it (region pattern, no sprite)
if (input_free(ui_layer_menu))
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (hot && tic <= 0) {
	tic = 8;
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
