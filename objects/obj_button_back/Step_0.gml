
// lives only alongside the save menu, shows only on the slots page.
// rides the menu's slide: starts tucked behind the header bar (which
// draws over the top ~29px) and slides down into place at y 30
if !instance_exists(obj_save_menu) { kill; exit; }
var _s = obj_save_menu.slide;
visible = _s > .02;
y = lerp(12, 30, _s);

pair;

if _s > .9
if click_tic <= 0
if mouse_over()
	if mouse_check_button_pressed(mb_left){
		click_tic = click_tic_;

		obj_save_menu.page = 0;

	}
