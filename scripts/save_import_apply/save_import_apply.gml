/// @description save_import_apply(txt);
/// @param txt
/// the shared back half of every import route (desktop dialog,
/// clipboard, android SAF): sanity-check the text, replace
/// savefile.ini, reload progress. settings.ini is untouched on
/// purpose. returns true if the save was applied.
function save_import_apply(_txt) {

	if (!is_string(_txt) || string_pos("save_datetime", _txt) <= 0) {
		show("import rejected > not a savefile");
		return false;
	}

	var _dest = syst_handle_save.file_to_handle;
	var _b = buffer_create(max(1, string_byte_length(_txt)), buffer_fixed, 1);
	buffer_write(_b, buffer_text, _txt);
	buffer_save(_b, _dest);
	buffer_delete(_b);

	with (syst_handle_save) {
		action = sv_load;
		handle_save();
		action = -1;
	}
	show("save imported");
	return true;
}
