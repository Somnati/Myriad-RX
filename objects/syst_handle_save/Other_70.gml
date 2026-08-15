/// Async - Social: results from the FileTransfer (SAF) extension.
/// export just reports; import feeds the shared apply pipeline.

var _type = async_load[? "type"];

if (_type == "filetransfer_export") {
	if (async_load[? "success"] == 1) show("save exported > file picker");
	else show("export cancelled/failed");
}

if (_type == "filetransfer_import") {
	if (async_load[? "success"] == 1) save_import_apply(async_load[? "content"]);
	else show("import cancelled/failed");
}
