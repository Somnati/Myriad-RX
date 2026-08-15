/// @description save_autosave_rotate();
/// the rotating autosave: flushes the live state to the main savefile,
/// then shifts the slots one place down and snapshots the fresh main
/// into slot 1:
///   autosave_3  <-  autosave_2
///   autosave_2  <-  autosave_1
///   autosave_1  <-  savefile (fresh)
/// three files, three restore points, and because they are SEPARATE
/// files a death mid-write can only ever corrupt one of them. the boot
/// failsafe (save_recover) walks them newest-first.
function save_autosave_rotate() {

	// flush current state to the main save first
	with (syst_handle_save) {
		action = sv_save;
		handle_save();
		action = -1;
	}

	var _main = syst_handle_save.file_to_handle;
	if (!file_exists(_main)) return false;

	var _a1 = save_slot_path(1);
	var _a2 = save_slot_path(2);
	var _a3 = save_slot_path(3);

	// shift down: 2 -> 3, 1 -> 2 (delete first: file_copy onto an
	// existing file is undefined-ish across platforms, so never risk it)
	if (file_exists(_a3)) file_delete(_a3);
	if (file_exists(_a2)) file_copy(_a2, _a3);
	if (file_exists(_a2)) file_delete(_a2);
	if (file_exists(_a1)) file_copy(_a1, _a2);
	if (file_exists(_a1)) file_delete(_a1);

	// fresh snapshot into slot 1
	file_copy(_main, _a1);

	show("autosave > rotated");
	return true;
}
