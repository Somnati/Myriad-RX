/// @description welcome_close() - arm the welcome screen's close (the
/// burger's X and escape land here through ui_overlay_close).
function welcome_close() {
	if (!instance_exists(syst_welcome)) return;
	syst_welcome.closing = true;
}
