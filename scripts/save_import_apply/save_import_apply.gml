/// @description save_import_apply(txt, [file]);
/// @param txt
/// @param [file]
/// the shared back half of every import route (desktop dialog,
/// clipboard, android SAF): sanity-check the text, replace the
/// savefile, reload progress. settings.ini is untouched on purpose.
/// returns true if the save was applied.
/// `file` names WHICH savefile to land in (default: the active one).
/// The save system is repointed at it BEFORE the reload - otherwise
/// the write would go to the chosen profile and the load would read
/// the old one. The CALLER owns g.profile and only sets it once this
/// returns true, so a cancelled import changes nothing at all.
function save_import_apply(_txt, _file = "") {

	if (!is_string(_txt) || string_pos("save_datetime", _txt) <= 0) {
		show("import rejected > not a savefile");
		return false;
	}

	var _dest = (_file == "") ? syst_handle_save.file_to_handle : _file;
	var _b = buffer_create(max(1, string_byte_length(_txt)), buffer_fixed, 1);
	buffer_write(_b, buffer_text, _txt);
	buffer_save(_b, _dest);
	buffer_delete(_b);

	// point the save system at what we just wrote, or the reload below
	// reads whatever file was active before the import
	syst_handle_save.file_to_handle = _dest;
	with (syst_handle_save) {
		action = sv_load;
		handle_save();
		action = -1;
	}
	show("save imported");
	return true;
}
