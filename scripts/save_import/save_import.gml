/// @description save_import();
/// pulls a savefile in from the player's chosen file (desktop dialog)
/// or the clipboard (non-desktop fallback), then applies it through
/// save_import_apply(). for the android FILE PICKER route use
/// save_import_saf() instead. returns true if a save was imported.
function save_import() {

	var _txt = "";

	if (os_type == os_windows || os_type == os_macosx || os_type == os_linux) {
		var _src = get_open_filename("ini savefile|*.ini", "");
		if (_src == "") return false; // player cancelled
		if (!file_exists(_src)) return false;
		var _b = buffer_load(_src);
		_txt = buffer_read(_b, buffer_text);
		buffer_delete(_b);
	} else {
		_txt = clipboard_get(); // clipboard fallback
	}

	return save_import_apply(_txt);
}
