/// @description exped_close() - arm the bench's close
function exped_close() {
	if (!instance_exists(syst_exped_panel)) return;
	syst_exped_panel.closing = true;
}
