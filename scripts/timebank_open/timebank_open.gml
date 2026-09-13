/// @description timebank_open() - put the time bank up over whatever
/// room you are standing in. THE ONE DOOR: the menu line and the
/// cockpit chip both call this rather than creating the object, so "is
/// it already up" is answered in one place.
///
/// ⚖️ AN OVERLAY, NOT A ROOM (his ask, 2026-09-10: "move the time bank
/// out of its own room and make it stand alone like settings and
/// statistics"). rm_timebank is gone. No goto_room, no wipe; the game
/// you were in is still behind it, and closing costs the room nothing.
///
/// Still fading out from a close? CATCH IT rather than refusing - the
/// settings door's rule: with an exit animation the panel is briefly
/// both open and not, and a press in that window used to do nothing.
function timebank_open() {
	if (instance_exists(syst_timebank_panel) && syst_timebank_panel.closing) {
		syst_timebank_panel.closing = false;
		return;
	}
	if (instance_exists(syst_timebank_panel)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	if (ui_overlay() != noone) ui_overlay_close();   // one panel at a time: the one up folds (2026-09-13 - the menu opens over panels now)
	create_obj(0, 0, syst_timebank_panel);
}
