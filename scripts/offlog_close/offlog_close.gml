/// @description offlog_close() - arm the log's close; its Step eases it
/// out and destroys it at zero
function offlog_close() {
	if (!instance_exists(syst_offlog)) return;
	syst_offlog.closing = true;
}
