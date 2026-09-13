/// @description gift_open() - put the daily gift up over whatever room
/// you are standing in. THE ONE DOOR (the settings door's rule): the
/// menu line calls this rather than creating the object, so "is it
/// already up" is answered in one place; a panel still fading out is
/// caught and revived rather than refused.
function gift_open() {
	if (instance_exists(syst_gift_panel) && syst_gift_panel.closing) {
		syst_gift_panel.closing = false;
		return;
	}
	if (instance_exists(syst_gift_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	if (ui_overlay() != noone) ui_overlay_close();   // one panel at a time: the one up folds (2026-09-13 - the menu opens over panels now)
	create_obj(0, 0, syst_gift_panel);
}
