/// @description tiles_skin_heal() - the skins array made whole against
/// the board: as long as the slots, 0 wherever the slot is empty, and
/// every tile's surface set from its tier (the ladder is deterministic
/// now, so this also rewrites skins rolled under the old pool). Called from tiles_sync (every
/// load and resize) and after the offline replay rewrites the board -
/// so a slip anywhere heals within a frame instead of drawing garbage.
function tiles_skin_heal() {
	var _t = g.tiles;
	if (!variable_struct_exists(_t, "skin")) _t.skin = [];
	var _n0 = array_length(_t.skin);
	if (_n0 != _t.slots) {
		array_resize(_t.skin, _t.slots);
		for (var _i = _n0; _i < _t.slots; _i++) _t.skin[_i] = -1;   // (array_resize fills 0 - which is a real skin)
	}
	for (var _i = 0; _i < _t.slots; _i++) {
		if (_t.tier[_i] <= 0) { _t.skin[_i] = 0; continue; }
		_t.skin[_i] = tile_skin_roll(_t.tier[_i]);
	}
}
