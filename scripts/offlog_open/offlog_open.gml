/// @description offlog_open() - put the offline log up over the room
/// you are standing in (the overlay contract: one panel at a time, the
/// burger's X and escape close it, the room holds quiet). The menu's
/// [offline log] line and the welcome card's [log] chip both land here.
function offlog_open() {
	if (instance_exists(syst_offlog) && syst_offlog.closing) {
		syst_offlog.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;
	create_obj(0, 0, syst_offlog);
}
