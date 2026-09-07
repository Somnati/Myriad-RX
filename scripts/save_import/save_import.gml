/// @description save_import([file]);
/// @param [file]
/// pulls a savefile in from the player's chosen file (desktop dialog)
/// or the clipboard (non-desktop fallback), then applies it through
/// save_import_apply(). for the android FILE PICKER route use
/// save_import_saf() instead. returns true if a save was imported.
/// `file` is the DESTINATION - which profile's main save the import
/// lands in - and defaults to the active one. It exists so the saves
/// menu can import into the profile on screen WITHOUT repointing
/// anything up front: a cancelled import must leave the save system
/// exactly where it found it (syst_handle_save first-saves any
/// file_to_handle that does not exist, so a stray repoint could copy
/// the live run into an empty profile).
function save_import(_file = "") {

	var _txt = "";

	if (os_type == os_windows || os_type == os_macosx || os_type == os_linux) {
		// THE FULLSCREEN TRAP - see save_export for the full note. A
		// modal common dialog over an exclusive fullscreen window is
		// what froze his game; drop to windowed around it, restore on
		// every exit including cancel.
		var _fs = window_get_fullscreen();
		if (_fs) window_set_fullscreen(false);
		var _src = get_open_filename("ini savefile|*.ini", "");
		if (_fs) window_set_fullscreen(true);
		if (_src == "") return false; // player cancelled
		if (!file_exists(_src)) return false;
		var _b = buffer_load(_src);
		_txt = buffer_read(_b, buffer_text);
		buffer_delete(_b);
	} else {
		_txt = clipboard_get(); // clipboard fallback
	}

	return save_import_apply(_txt, _file);
}
