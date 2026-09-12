/// @description exped_open() - the expedition bench, over the room
function exped_open() {
	if (instance_exists(syst_exped_panel) && syst_exped_panel.closing) {
		syst_exped_panel.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_exped_panel);
}
