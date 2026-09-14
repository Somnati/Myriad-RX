/// @description title_header() - the title screen's header: made only
/// while a panel is up there (settings), hidden above the room to start
/// - syst_titlescreen's Step slides it down, and back up and away when
/// the panel closes. Title mode (obj_ui_header): the bar alone, and
/// the corner X on it is how the panel closes (his report, 2026-09-13).
/// The gear calls this BEFORE it opens settings, so the panel seats
/// under the bar's real height rather than a guess.
function title_header() {
	if (instance_exists(obj_ui_header)) return obj_ui_header;
	var _h = instance_create_depth(0, 0, -1000, obj_ui_header);
	_h.y = -(_h.bar_h + 3);
	return _h;
}
