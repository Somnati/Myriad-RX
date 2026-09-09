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
	if (instance_exists(syst_settings)) return;
	create_obj(0, 0, syst_settings);
}
