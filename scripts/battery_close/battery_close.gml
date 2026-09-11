/// @description battery_close() - arm the panel's close ease (the
/// burger's X and escape both land here through ui_overlay_close).
function battery_close() {
	if (!instance_exists(syst_battery_panel)) return;
	syst_battery_panel.closing = true;
}
