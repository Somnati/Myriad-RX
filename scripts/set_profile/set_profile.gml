/// @description set_profile(index);
/// @param index
/// switches the active profile (0-based): repoints the save system at
/// the profile's files, runs the corruption failsafe on THAT profile's
/// slots, and queues a load. a profile with no save yet simply
/// first-saves on the next step, which is the "save to new file" flow.
function set_profile(_p) {
	_p = clamp(floor(_p), 0, 3);
	// ⚖️ THE OLD RUN FLUSHES TO THE PROFILE THAT OWNS IT, FIRST (his loss,
	// 2026-09-13: a new game on profile 2, back to the title, load profile
	// 1 - and profile 1's main save became the new game). This repointed
	// file_to_handle at the target and queued the load for the NEXT step;
	// the goto_room that followed in the SAME step saw a dirty flag and
	// flushed - the run still in memory, the new game - into the file the
	// pointer now named, then cleared the queued load. So: if the run in
	// memory is dirty and belongs to another profile that still has a
	// save, it is written HOME now, and the flag is cleared either way -
	// nothing between here and the load has anything left to write. A
	// same-profile call (an autosave restored onto main) never flushes:
	// that would overwrite what was just restored.
	var _old = variable_global_exists("profile") ? g.profile : -1;
	if (_old >= 0 && _old != _p && variable_global_exists("save_dirty") && g.save_dirty
	&& instance_exists(syst_handle_save) && file_exists(save_slot_path(0, _old))) {
		with (syst_handle_save) {
			file_to_handle = save_slot_path(0, _old);
			action = sv_save;
			handle_save();
			action = -1;
		}
		show("profile set > flushed the dirty run home to p" + string(_old + 1));
	}
	if (variable_global_exists("save_dirty")) g.save_dirty = false;
	g.profile = _p;
	with (syst_handle_save) {
		file_to_handle = save_slot_path(0);
		save_recover();
		// fresh profile: reset the per-profile state BEFORE the first
		// save runs, or the new profile inherits the old one's progress.
		// game_reset is the FULL fresh-run reset (new game's) - the old
		// partial reset here leaked cores/power/machines/tiles/dims
		if (!file_exists(file_to_handle)) game_reset();
		// the offline log restarts with the profile: the load's own replay
		// files this profile's first entry (game_reset does the same for a
		// fresh one) - and a report queued for the OLD profile is void
		if (variable_global_exists("offline_report")) g.offline_report.shown = true;
		offlog_init(true);
		action = sv_load;
	}
	show("profile set > " + string(g.profile + 1) + " '" + g.profile_name[g.profile] + "'");
}
