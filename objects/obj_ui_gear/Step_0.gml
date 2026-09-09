/// @description the door

tic -= delta;
rip = max(0, rip - .06 * delta);

var _s = __seat();
if (_s.a <= .01) { hot = false; spin = 0; exit; }

hot = point_in_rectangle(mousex, mousey, _s.x - 11, _s.y - 11, _s.x + 11, _s.y + 11);
// ⚖️ A QUARTER TURN THERE AND BACK (his spec), not a free spin. The
// ease is the whole animation: 0 at rest, 1 while hovered, and the Draw
// reads BOTH the angle and the scale off it. adj 3 is about a third of
// the remaining distance per frame - the burger's own snap, quick
// enough to read as a response to the pointer rather than an idle
// animation, and it unwinds at exactly the same rate on the way out.
spin = move_to(spin, hot ? 1 : 0, 3);

// a panel is already up: the burger is the X that closes it, not this
if (ui_overlay() != noone) exit;

// the trigger lives at the MENU layer so it stays clickable next to the
// open drawer, which raises the modal block behind it (obj_ui_menu2's
// rule, region pattern, no sprite mask)
if (input_free(ui_layer_menu))
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (hot && tic <= 0) {
	tic = 8;
	rip = 1;
	play_sound_ext(snd_matclick2, 1, 1.05, .5, 1);
	// the drawer folds and the screen comes up over the room - no
	// transition, nothing left behind it (his ask). Folding first
	// matters more than it did: the drawer would otherwise sit under
	// the overlay, still open, waiting for you when you close it.
	if (instance_exists(obj_ui_menu2)) obj_ui_menu2.open = false;
	settings_open();
}
