/// @description the door

tic -= delta;
rip = max(0, rip - .06 * delta);

var _s = __seat();
hot = point_in_rectangle(mousex, mousey, _s.x - 11, _s.y - 11, _s.x + 11, _s.y + 11);
spin = move_to(spin, hot ? 1 : 0, 6);

// never while the settings room is the room it would take you to, and
// never under the open menu - the drawer covers this corner
if (in_room(rm_settings)) exit;
if (instance_exists(obj_ui_menu2) && obj_ui_menu2.open) exit;

// the trigger lives at the MENU layer so it stays clickable alongside
// the burger (obj_ui_menu2's rule, region pattern, no sprite mask)
if (input_free(ui_layer_menu))
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (hot && tic <= 0) {
	tic = 8;
	rip = 1;
	play_sound_ext(snd_matclick2, 1, 1.05, .5, 1);
	goto_room(rm_settings);
}
