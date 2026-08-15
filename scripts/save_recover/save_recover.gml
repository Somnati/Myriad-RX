/// @description save_recover();
/// boot failsafe for the mobile death-mid-write case: if the main
/// savefile is missing or fails validation, walk the autosave slots
/// newest-first and restore the first survivor over the main file.
/// returns true if a recovery happened. runs BEFORE the first load
/// (syst_handle_save Create), so the load that follows reads the
/// recovered file like nothing happened.
function save_recover() {
	var _main = syst_handle_save.file_to_handle;

	// nothing on disk at all = clean first boot, not a corruption
	if (!file_exists(_main)
	&&  !file_exists(save_slot_path(1))
	&&  !file_exists(save_slot_path(2))
	&&  !file_exists(save_slot_path(3))) return false;

	if (save_validate(_main)) return false; // main is fine

	// main is corrupt or gone but autosaves exist: find a survivor
	for (var _i = 1; _i <= 3; _i++) {
		var _slot = save_slot_path(_i);
		if (save_validate(_slot)) {
			if (file_exists(_main)) file_delete(_main);
			file_copy(_slot, _main);
			show("SAVE RECOVERED > main was corrupt, restored " + _slot);
			return true;
		}
	}

	show("SAVE RECOVERY FAILED > no valid autosave found");
	return false;
}
