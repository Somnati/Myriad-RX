/// @description automation_open() - put the automation screen up over
/// whatever room you are standing in. THE ONE DOOR (the settings door's
/// rule): a panel still fading out is caught and revived; a second
/// panel is refused.
function automation_open() {
	if (instance_exists(syst_automation_panel) && syst_automation_panel.closing) {
		syst_automation_panel.closing = false;
		return;
	}
	if (instance_exists(syst_automation_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	if (ui_overlay() != noone) ui_overlay_close();   // one panel at a time: the one up folds (2026-09-13 - the menu opens over panels now)
	create_obj(0, 0, syst_automation_panel);
}
