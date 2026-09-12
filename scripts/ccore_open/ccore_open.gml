/// @description ccore_open() - put the credit core panel up over the
/// room you are standing in (the overlay contract: one panel at a
/// time, the burger's X and escape close it, the room holds quiet)
function ccore_open() {
	if (instance_exists(syst_ccore_panel) && syst_ccore_panel.closing) {
		syst_ccore_panel.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_ccore_panel);
}
