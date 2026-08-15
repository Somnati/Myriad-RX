/// @description save_export_saf();
/// android-only: opens the system "save as" picker (SAF) so the player
/// writes the savefile anywhere (Downloads, Drive...), no clipboard
/// size limit. the write result arrives in syst_handle_save's
/// Async - Social event as type "filetransfer_export".
function save_export_saf() {

	if (os_type != os_android) {
		show("saf export is android-only > use the export button");
		return false;
	}

	// flush the live state to disk first, so the export is current
	with (syst_handle_save) {
		action = sv_save;
		handle_save();
		handle_settings(sv_save);
		action = -1;
	}

	var _src = syst_handle_save.file_to_handle;
	if (!file_exists(_src)) { show("export failed > no savefile"); return false; }

	var _b = buffer_load(_src);
	var _txt = buffer_read(_b, buffer_text);
	buffer_delete(_b);

	FileTransfer_Export("myriad_save.ini", _txt);
	return true;
}
