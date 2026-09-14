/// @description cheat_open() - the cheat shop, as a panel over whatever
/// room you are standing in (the overlay contract: one at a time).
function cheat_open() {
	if (instance_exists(syst_cheat_panel) && syst_cheat_panel.closing) {
		syst_cheat_panel.closing = false;
		return;
	}
	if (instance_exists(syst_cheat_panel)) return;
	if (ui_overlay() != noone) ui_overlay_close();
	create_obj(0, 0, syst_cheat_panel);
}
