/// @description set_profile(index);
/// @param index
/// switches the active profile (0-based): repoints the save system at
/// the profile's files, runs the corruption failsafe on THAT profile's
/// slots, and queues a load. a profile with no save yet simply
/// first-saves on the next step, which is the "save to new file" flow.
function set_profile(_p) {
	g.profile = clamp(floor(_p), 0, 3);
	with (syst_handle_save) {
		file_to_handle = save_slot_path(0);
		save_recover();
		// fresh profile: reset the per-profile state BEFORE the first
		// save runs, or the new profile inherits the old one's progress.
		// game_reset is the FULL fresh-run reset (new game's) - the old
		// partial reset here leaked cores/power/machines/tiles/dims
		if (!file_exists(file_to_handle)) game_reset();
		action = sv_load;
	}
	show("profile set > " + string(g.profile + 1) + " '" + g.profile_name[g.profile] + "'");
}
