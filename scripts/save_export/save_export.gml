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
		// THE FULLSCREEN TRAP (2026-09-07, his report on the import
		// twin: "it pulled up the file manager and it kinda froze...
		// i couldnt go back to the game"). A Windows common dialog is
		// MODAL and blocks the whole game loop; opened over an
		// EXCLUSIVE fullscreen window the two fight for the display,
		// and closing the dialog does not reliably hand the foreground
		// back. The game starts fullscreen by default (scr_display1),
		// so this is the normal case, not the edge one. Drop to
		// windowed for the length of the dialog and restore after -
		// and restore on EVERY exit, cancel included.
		// Borderless is deliberately left alone: as far as the OS is
		// concerned that is an ordinary window, and a dialog sits over
		// it without a fight.
		var _fs = window_get_fullscreen();
		if (_fs) window_set_fullscreen(false);
		var _dest = get_save_filename("ini savefile|*.ini", "myriad_save.ini");
		if (_fs) window_set_fullscreen(true);
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
