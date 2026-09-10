/// @description automation_close() - take the automation screen down.
/// Arms the exit; the Step destroys at zero. Nothing to flush: every
/// toggle and slider marked the save as it changed.
function automation_close() {
	if (!instance_exists(syst_automation_panel)) return;
	syst_automation_panel.closing = true;
}
