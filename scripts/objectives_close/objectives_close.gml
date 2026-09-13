/// @description objectives_close() - fold the objectives panel away
function objectives_close() {
	if (!instance_exists(syst_objectives_panel)) return;
	syst_objectives_panel.closing = true;
}
