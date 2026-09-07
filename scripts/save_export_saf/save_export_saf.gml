/// @description save_export_saf([file]);
/// @param [file]
/// android-only: opens the system "save as" picker (SAF) so the player
/// writes the savefile anywhere (Downloads, Drive...), no clipboard
/// size limit. the write result arrives in syst_handle_save's
/// Async - Social event as type "filetransfer_export".
/// `file` defaults to the active profile's save; save_export's note on
/// skipping the flush for another profile's file applies here too.
function save_export_saf(_file = "") {

	if (os_type != os_android) {
		show("saf export is android-only > use the export button");
		return false;
	}

	var _src = (_file == "") ? syst_handle_save.file_to_handle : _file;

	// flush first, but only when the file being exported IS the live one
	if (_src == syst_handle_save.file_to_handle)
	with (syst_handle_save) {
		action = sv_save;
		handle_save();
		handle_settings(sv_save);
		action = -1;
	}

	if (!file_exists(_src)) { show("export failed > no savefile"); return false; }

	var _b = buffer_load(_src);
	var _txt = buffer_read(_b, buffer_text);
	buffer_delete(_b);

	FileTransfer_Export("myriad_save.ini", _txt);
	return true;
}
