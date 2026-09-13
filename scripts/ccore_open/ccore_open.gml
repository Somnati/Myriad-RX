/// @description ccore_open() - put the credit core panel up over the
/// room you are standing in (the overlay contract: one panel at a
/// time, the burger's X and escape close it, the room holds quiet)
function ccore_open() {
	if (instance_exists(syst_ccore_panel) && syst_ccore_panel.closing) {
		syst_ccore_panel.closing = false;
		return;
	}
	if (instance_exists(syst_ccore_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// a panel already up FOLDS (2026-09-13: the burger opens the menu over
	// a panel now, so a menu line must be able to swap panels)
	if (ui_overlay() != noone) ui_overlay_close();
	create_obj(0, 0, syst_ccore_panel);
}
