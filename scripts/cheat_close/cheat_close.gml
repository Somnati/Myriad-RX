/// @description cheat_close() - fold the cheat shop away (its Step
/// destroys it once the ease reaches zero; every change already marked
/// the save as it happened).
function cheat_close() {
	if (!instance_exists(syst_cheat_panel)) return;
	syst_cheat_panel.closing = true;
}
