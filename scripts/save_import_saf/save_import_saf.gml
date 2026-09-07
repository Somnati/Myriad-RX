/// @description save_import_saf([profile]);
/// @param [profile]
/// android-only: opens the system file picker (SAF). the chosen file's
/// text arrives in syst_handle_save's Async - Social event as type
/// "filetransfer_import" and gets applied via save_import_apply().
/// SAF is ASYNCHRONOUS, so a destination cannot ride the return value
/// the way save_import's does: `profile` is STASHED in g.import_prof
/// and the async handler reads it, applies into that profile and
/// adopts it. -1 (the default) means the active profile, the old
/// behaviour. The handler clears the stash on both outcomes, so a
/// cancelled picker leaves nothing armed.
function save_import_saf(_prof = -1) {

	if (os_type != os_android) {
		show("saf import is android-only > use the import button");
		return false;
	}

	g.import_prof = _prof;
	FileTransfer_Import();
	return true;
}
