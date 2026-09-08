/// @description sfx_index(kind) - which ROW of the roster is chosen,
/// resolved from the saved id every time it is asked.
/// An id that no longer exists - a roster edit, an older save - answers
/// row 0 rather than erroring or silently picking whatever has since
/// moved into that slot. That is the whole reason ids replaced indices
/// the first time he asked for sounds to be removed from the MIDDLE of
/// the list (2026-09-08): under the old scheme, deleting "pop" quietly
/// gave everyone who had chosen "atlas" a different sound.
function sfx_index(_kind) {
	var _l = sfx_config(_kind);
	if (array_length(_l) == 0) return 0;
	if (!variable_global_exists("sfx_pick")) return 0;
	if (!variable_struct_exists(g.sfx_pick, _kind)) return 0;
	var _id = g.sfx_pick[$ _kind];
	for (var _i = 0; _i < array_length(_l); _i++)
		if (_l[_i].id == _id) return _i;
	return 0;
}
