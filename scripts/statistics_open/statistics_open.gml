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
/// THE TAB (his ask, 2026-09-15): it opens on the folder that fits where
/// you are - the expedition panel up = expeditions, tiles = tiles, and
/// so on (stats_tab_here); nothing fitting = wherever it was last.
function statistics_open() {
	var _want = stats_tab_here();
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
	if (instance_exists(syst_statistics_v2)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	// a panel already up FOLDS (2026-09-13: the burger opens the menu over
	// a panel now, so a menu line must be able to swap panels)
	if (ui_overlay() != noone) ui_overlay_close();
	g.stats_tab_want = _want;   // (syst_statistics_v2's Create reads and clears it)
	create_obj(0, 0, syst_statistics_v2);
}
