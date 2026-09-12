/// @description ccore_close() - arm the panel's close; its Step eases
/// it out and destroys it at zero
function ccore_close() {
	if (!instance_exists(syst_ccore_panel)) return;
	syst_ccore_panel.closing = true;
}
