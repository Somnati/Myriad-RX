/// @description save_import_saf();
/// android-only: opens the system file picker (SAF). the chosen file's
/// text arrives in syst_handle_save's Async - Social event as type
/// "filetransfer_import" and gets applied via save_import_apply().
function save_import_saf() {

	if (os_type != os_android) {
		show("saf import is android-only > use the import button");
		return false;
	}

	FileTransfer_Import();
	return true;
}
