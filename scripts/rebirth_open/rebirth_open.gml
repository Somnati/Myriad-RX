/// @description rebirth_open() - the menu's "rebirth" entry (Myriad
/// DE: obj_button_suboptions spawned syst_rebirth into rm_clicker on
/// the tap). The overlay LIVES in rm_clicker as a placed instance, so
/// opening it from elsewhere means going there first: the pending
/// flag survives the room hop and syst_rebirth's Create consumes it.
function rebirth_open() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	g.rebirth_open_pending = true;
	if (in_room(rm_clicker) && instance_exists(syst_rebirth))
		syst_rebirth.__open();
	else
		goto_room(rm_clicker);
}
