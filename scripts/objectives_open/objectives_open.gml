/// @description objectives_open() - the objectives panel (the detailed
/// list, from the menu or a tap on the card). One overlay at a time -
/// the contract every panel shares.
function objectives_open() {
	if (instance_exists(syst_objectives_panel) && syst_objectives_panel.closing) {
		syst_objectives_panel.closing = false;
		return;
	}
	if (instance_exists(syst_objectives_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// a panel already up FOLDS (2026-09-13: the burger opens the menu over
	// a panel now, so a menu line must be able to swap panels)
	if (ui_overlay() != noone) ui_overlay_close();
	create_obj(0, 0, syst_objectives_panel);
}
