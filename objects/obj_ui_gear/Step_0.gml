/// @description the doors

tic -= delta;
rip = max(0, rip - .06 * delta);
drop = move_to(drop, (ui_overlay() != noone) ? 1 : 0, 6);   // (the title's seat reads it)

var _seats = __seats();
if (array_length(_seats) == 0) { hot_i = -1; for (var _i = 0; _i < array_length(icons); _i++) icons[_i].spin = 0; exit; }

// which icon the pointer is on, and every icon's hover ease. ⚖️ A
// QUARTER TURN THERE AND BACK (his spec), not a free spin: 0 at rest, 1
// while hovered, the Draw reads the angle and the scale off it. move_to
// adj 3 is the burger's own snap
hot_i = -1;
for (var _k = 0; _k < array_length(_seats); _k++) {
	var _s = _seats[_k];
	if (_s.t >= .999 && point_in_rectangle(mousex, mousey, _s.x - 11, _s.y - 11, _s.x + 11, _s.y + 11)) hot_i = _s.i;
}
for (var _i = 0; _i < array_length(icons); _i++)
	icons[_i].spin = move_to(icons[_i].spin, (hot_i == _i) ? 1 : 0, 3);

// the trigger lives at the MENU layer so it stays clickable next to the
// open drawer, which raises the modal block behind it (obj_ui_menu2's
// rule, region pattern, no sprite mask). A panel already up is no bar:
// every door closes whatever is open on its way in (the *_open guards)
if (input_free(ui_layer_menu))
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (hot_i >= 0 && tic <= 0) {
	tic = 8;
	rip = 1; rip_i = hot_i;
	play_sound_ext(snd_matclick2, 1, 1.05, .5, 1);
	// the drawer folds and the screen comes up over the room - no
	// transition, nothing left behind it (his ask). Folding first
	// matters: the drawer would otherwise sit under the overlay, still
	// open, waiting for you when you close it
	if (instance_exists(obj_ui_menu2)) obj_ui_menu2.open = false;
	__open(hot_i);
}
