/// @description save_export([file]);
/// @param [file]
/// writes a save out to a file the PLAYER can reach, dodging
/// the clipboard size limit that truncated big myriad saves on mobile.
/// desktop: system save dialog, plain readable ini. mobile: clipboard
/// fallback until the android SAF (file picker) extension lands.
/// returns true if the save left the building.
/// `file` defaults to the ACTIVE profile's save. The saves menu passes
/// another profile's path to export THAT one - and the flush below is
/// deliberately skipped in that case: writing the live run into a file
/// we were only asked to read would overwrite the very profile the
/// player wanted a backup of.
function save_export(_file = "") {

	var _src = (_file == "") ? syst_handle_save.file_to_handle : _file;

	// flush the live state to disk first so the export is current -
	// but ONLY when the file being exported IS the live one
	if (_src == syst_handle_save.file_to_handle)
	with (syst_handle_save) {
		action = sv_save;
		handle_save();
		handle_settings(sv_save);
		action = -1;
	}

	if (!file_exists(_src)) { show("export failed > no savefile"); return false; }

	if (os_type == os_windows || os_type == os_macosx || os_type == os_linux) {
		var _dest = get_save_filename("ini savefile|*.ini", "myriad_save.ini");
		if (_dest == "") return false; // player cancelled
		var _b = buffer_load(_src);
		buffer_save(_b, _dest);
		buffer_delete(_b);
		show("save exported > " + _dest);
		return true;
	}

	// mobile fallback: clipboard (the old road, until SAF)
	var _b = buffer_load(_src);
	var _txt = buffer_read(_b, buffer_text);
	buffer_delete(_b);
	clipboard_set(_txt);
	show("save exported > clipboard (mobile fallback)");
	return true;
}
