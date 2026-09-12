/// @description tiles_open() - put the tile table up over the room you
/// are standing in (his ask, 2026-09-12: "port the tiles to a
/// standalone layer thing instead of its own room" - rm_tiles is a
/// dead room now). The overlay contract: one panel at a time, the
/// burger's X and escape close it through ui_overlay_close, syst_input
/// holds the room quiet, ui_blur_tick softens it behind (the board
/// paints its own ground over that - the room it was is black). The
/// table itself never left: syst_tiletimer runs tiles_tick everywhere,
/// this is only the view.
function tiles_open() {
	if (instance_exists(syst_tiles) && syst_tiles.closing) {
		syst_tiles.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;   // one panel at a time
	create_obj(0, 0, syst_tiles);
}
