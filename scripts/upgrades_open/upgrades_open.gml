/// @description upgrades_open() - put the upgrade table up over the
/// room you are standing in (his ask, 2026-09-12: "a standalone overlay
/// type thing instead of its own room" - the back button goes with the
/// room). The overlay contract: one panel at a time, the burger's X and
/// escape close it through ui_overlay_close, syst_input holds the room
/// quiet, ui_blur_tick softens it behind. rm_upgrades survives as a
/// dead room; nothing routes there any more.
function upgrades_open() {
	if (instance_exists(syst_upgrades) && syst_upgrades.closing) {
		syst_upgrades.closing = false;
		return;
	}
	if (instance_exists(syst_upgrades)) return;   // already up: nothing to do (the fold-what-is-up line below must not fold THIS)
	if (ui_overlay() != noone) ui_overlay_close();   // one panel at a time: the one up folds (2026-09-13 - the menu opens over panels now)
	create_obj(0, 0, syst_upgrades);
}
