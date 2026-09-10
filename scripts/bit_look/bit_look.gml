/// @description bit_look(lane) - the roster ROW a lane's motes wear,
/// resolved from the saved id every time it is asked.
/// @param lane  "profit" (dials + the tap) / "credit" / "unit" (the
///              rebirth burst) / "tile" (the table's fountain)
///
/// THE LANES ARE HIS LIST (2026-09-10: "a setting to control profit /
/// credit / unit / tile bits"). Each is one key of g.bit_pick holding a
/// bit_config id, and each has its own settings pill, because the
/// reason to change one is not the reason to change another: the tile
/// fountain is eight motes a second at one spot and wants to be plain,
/// a dial payout is one mote across the room and can afford a halo.
///
/// sfx_index's rule, kept: an id that no longer exists - a roster edit,
/// an older save - answers row 0 rather than erroring or silently
/// wearing whatever moved into that slot. Returns the ROW (id + name),
/// so the pill reads .name and the mote reads .id off one call.
function bit_look(_lane) {
	var _l = bit_config();
	if (!variable_global_exists("bit_pick")) return _l[0];
	if (!variable_struct_exists(g.bit_pick, _lane)) return _l[0];
	var _id = g.bit_pick[$ _lane];
	for (var _i = 0; _i < array_length(_l); _i++)
		if (_l[_i].id == _id) return _l[_i];
	return _l[0];
}
