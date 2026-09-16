/// @description exped_open() - the expedition bench, over the room (it opens on the board's world - the hub went, his call 2026-09-16)
function exped_open() {
	if (instance_exists(syst_exped_panel) && syst_exped_panel.closing) {
		syst_exped_panel.closing = false;
		return;
	}
	if (instance_exists(syst_exped_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// a panel already up FOLDS (2026-09-13: the burger opens the menu over
	// a panel now, so a menu line must be able to swap panels)
	if (ui_overlay() != noone) ui_overlay_close();
	create_obj(0, 0, syst_exped_panel);
}
