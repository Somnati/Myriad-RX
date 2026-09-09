/// @description statistics_open() - put the statistics screen up over
/// whatever room you are standing in.
///
/// An OVERLAY, not a room (his ask, 2026-09-08, after settings got the
/// same treatment): no wipe, and the game carries on behind it. See
/// settings_open - this is deliberately the same shape, because two
/// panels that behave differently are two things to remember.
///
/// THE ONE DOOR, so "is it already up" is answered in one place, and it
/// refuses while another overlay is open rather than stacking two
/// full-screen panels with one X between them.
function statistics_open() {
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_statistics_v2);
}
