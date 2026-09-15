/// @description settings_open() - put the settings screen up over
/// whatever room you are standing in.
///
/// ⚖️ IT IS AN OVERLAY, NOT A ROOM (his ask, 2026-09-08): "i dont want a
/// loading transition to the settings room... i want the settings as it
/// would be in its own room to appear on top of the clicker room". So
/// there is no goto_room, no wipe, and the game you were playing is
/// still behind it - which also means opening settings mid-run no
/// longer costs the room its state.
///
/// THE ONE DOOR. Every entry point calls this rather than creating the
/// object, so "is it already up" is answered in one place - spawning a
/// second syst_settings would give you two backdrops, two scrollbars
/// and two sets of widgets fighting over the same pool keys.
function settings_open() {
	// still fading out from a close? CATCH IT rather than refusing.
	// The old guard was written when closing was instant; with an exit
	// animation the panel is briefly both open and not, and a press in
	// that window used to do nothing at all. Reviving also spares us
	// the one thing the guard exists to prevent - a second instance
	// fighting the first over the same widget pool keys.
	if (instance_exists(syst_settings) && syst_settings.closing) {
		syst_settings.closing = false;
		return;
	}
	if (instance_exists(syst_settings)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// one panel at a time: the one up folds (2026-09-13 - the menu opens over
	// panels now) - EXCEPT the expedition panel (his ask, 2026-09-15): it
	// stays under the settings, quiet and deeper, so the pages' dither is
	// seen live as the slider moves
	var _ov = ui_overlay();
	if (_ov != noone && _ov.object_index != syst_exped_panel) ui_overlay_close();
	create_obj(0, 0, syst_settings);
}
