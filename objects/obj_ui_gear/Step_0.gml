/// @description the door

tic -= delta;
rip = max(0, rip - .06 * delta);

var _s = __seat();
if (_s.a <= .01) { hot = false; spin = 0; exit; }

hot = point_in_rectangle(mousex, mousey, _s.x - 11, _s.y - 11, _s.x + 11, _s.y + 11);
spin = move_to(spin, hot ? 1 : 0, 6);

// the room it would take you to is the room you are in
if (in_room(rm_settings)) exit;

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
	// shut the drawer on the way out. The room change would rebuild it
	// closed anyway (it is not persistent), but the wipe is long enough
	// to see, and leaving it open through the transition reads as the
	// tap having missed.
	if (instance_exists(obj_ui_menu2)) obj_ui_menu2.open = false;
	goto_room(rm_settings);
}
