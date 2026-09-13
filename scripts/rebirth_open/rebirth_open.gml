/// @description rebirth_open() - the menu's "rebirth" entry (Myriad
/// DE: obj_button_suboptions spawned syst_rebirth into rm_clicker on
/// the tap). The overlay LIVES in rm_clicker as a placed instance, so
/// opening it from elsewhere means going there first: the pending
/// flag survives the room hop and syst_rebirth's Create consumes it.
function rebirth_open() {
	if (!variable_global_exists("game_started") || !g.game_started) return;
	if (instance_exists(syst_rebirth) && syst_rebirth.open) return;   // already up
	if (ui_overlay() != noone) ui_overlay_close();   // one panel at a time: the one up folds (2026-09-13 - the menu opens over panels now)
	g.rebirth_open_pending = true;
	// ⚖️ IN PLACE, WHATEVER THE ROOM (his ask, 2026-09-10: from the tiles
	// it used to hop to the money room first). The money room carries
	// its own instance; anywhere else gets a GUEST one, spawned here,
	// which opens off the pending flag in its Create and destroys
	// itself once closed (syst_rebirth's guest rule).
	if (instance_exists(syst_rebirth)) syst_rebirth.__open();
	else create_obj(0, 0, syst_rebirth);
}
