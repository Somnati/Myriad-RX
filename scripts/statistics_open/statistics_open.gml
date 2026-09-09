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
	// still fading out from a close? CATCH IT rather than refusing.
	// The old guard was written when closing was instant; with an exit
	// animation the panel is briefly both open and not, and a press in
	// that window used to do nothing at all. Reviving also spares us
	// the one thing the guard exists to prevent - a second instance
	// fighting the first over the same widget pool keys.
	if (instance_exists(syst_statistics_v2) && syst_statistics_v2.closing) {
		syst_statistics_v2.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_statistics_v2);
}
