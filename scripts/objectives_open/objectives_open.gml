/// @description objectives_open() - the objectives panel (the detailed
/// list, from the menu or a tap on the card). One overlay at a time -
/// the contract every panel shares.
function objectives_open() {
	if (instance_exists(syst_objectives_panel) && syst_objectives_panel.closing) {
		syst_objectives_panel.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_objectives_panel);
}
