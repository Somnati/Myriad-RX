/// @description automation_open() - put the automation screen up over
/// whatever room you are standing in. THE ONE DOOR (the settings door's
/// rule): a panel still fading out is caught and revived; a second
/// panel is refused.
function automation_open() {
	if (instance_exists(syst_automation_panel) && syst_automation_panel.closing) {
		syst_automation_panel.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;   // one panel at a time
	create_obj(0, 0, syst_automation_panel);
}
