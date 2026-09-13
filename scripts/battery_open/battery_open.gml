/// @description battery_open() - put the battery panel up over whatever
/// room you are standing in. THE ONE DOOR: the menu line calls this
/// rather than creating the object, so "is it already up" is answered
/// in one place. The overlay contract: one panel at a time.
function battery_open() {
	if (instance_exists(syst_battery_panel) && syst_battery_panel.closing) {
		syst_battery_panel.closing = false;
		return;
	}
	if (instance_exists(syst_battery_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// a panel already up FOLDS (2026-09-13: the burger opens the menu over
	// a panel now, so a menu line must be able to swap panels)
	if (ui_overlay() != noone) ui_overlay_close();
	create_obj(0, 0, syst_battery_panel);
}
