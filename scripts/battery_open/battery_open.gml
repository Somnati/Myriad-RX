/// @description battery_open() - put the battery panel up over whatever
/// room you are standing in. THE ONE DOOR: the menu line calls this
/// rather than creating the object, so "is it already up" is answered
/// in one place. The overlay contract: one panel at a time.
function battery_open() {
	if (instance_exists(syst_battery_panel) && syst_battery_panel.closing) {
		syst_battery_panel.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_battery_panel);
}
