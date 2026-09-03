/// @description scr_escape() - THE escape router (ux pass 2026-07-09,
/// his call: escape only ends the game when NOTHING else wants it).
/// system's begin step calls this instead of game_end; local escape
/// consumers keep their own handlers (they run later the same frame),
/// this file just STANDS DOWN when one of them is active - the same
/// declarative-registry shape as input_free's blocker list.
///
/// >>> A NEW ESCAPE CONSUMER: handle vk_escape in your own step, then
/// add one stand-down line here so the router doesn't also fire.
///
/// resolution order: transitions swallow -> local consumers own it ->
/// modal/popup owners own it (input_block) -> BACK one room -> the
/// title screen is the last stop, escape there quits.
function scr_escape() {
	// transitional rooms / mid-wipe: swallow outright
	if (room == rm_gameload || room == rm_quit) return;
	if (instance_exists(syst_roomtrans) && syst_roomtrans.switch_rooms) return;
	// local consumers (they close/exit themselves this frame)
	if (instance_exists(obj_ui_menu2) && obj_ui_menu2.open) return;
	if (instance_exists(syst_rebirth) && syst_rebirth.open) return;
	if (instance_exists(obj_debug_pro) && obj_debug_pro.edit_index >= 0) return;
	if (instance_exists(syst_statistics_v2) && syst_statistics_v2.search_on) return;
	// popups/modals (pillbox, confirm, dialogue, the offline card):
	// their owners dismiss themselves - never quit over an open popup
	if (variable_global_exists("input_block") && g.input_block > 0) return;
	// nobody claimed it: BACK. the title is the exit door.
	if (room == rm_titlescreen) { game_end(); return; }
	back_room();
}
