/// Async - Social: results from the FileTransfer (SAF) extension.
/// export just reports; import feeds the shared apply pipeline.

var _type = async_load[? "type"];

if (_type == "filetransfer_export") {
	if (async_load[? "success"] == 1) show("save exported > file picker");
	else show("export cancelled/failed");
}

if (_type == "filetransfer_import") {
	// the saves menu stashes WHICH profile the import was for (SAF is
	// async, so it cannot ride a return value). Applying and adopting
	// both happen here; the stash is cleared either way, so a cancelled
	// picker leaves nothing armed for the next import.
	var _p = variable_global_exists("import_prof") ? g.import_prof : -1;
	if (async_load[? "success"] == 1) {
		if (_p >= 0) {
			if (save_import_apply(async_load[? "content"], save_slot_path(0, _p))) {
				g.profile = _p;
				g.game_started = true;
			}
		} else save_import_apply(async_load[? "content"]);
	} else show("import cancelled/failed");
	g.import_prof = -1;
}
