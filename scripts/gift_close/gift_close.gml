/// @description gift_close() - take the daily gift panel down. Arms the
/// exit; its Step destroys it once the ease reaches zero. Nothing to
/// flush: a collect marked the save the moment it happened.
function gift_close() {
	if (!instance_exists(syst_gift_panel)) return;
	syst_gift_panel.closing = true;
}
