/// @description tile_skin_roll(tier) -> a material kind for a tile of
/// this tier, rolled from the pool it qualifies for (tile_mat_config):
/// every row at or under the tier, weighted, the growing weights
/// scaled by how far the tier sits above each row's floor. 0 for an
/// empty slot. Ambient random - the tiers themselves roll the same way.
function tile_skin_roll(_tier) {
	if (_tier <= 0) return 0;
	if (!TILE_MATERIAL) return 0;
	var _c = tile_mat_config();
	var _ws = [], _tot = 0;
	for (var _i = 0; _i < array_length(_c); _i++) {
		var _r = _c[_i];
		var _w = 0;
		if (_tier >= _r.min) _w = _r.w * (_r.grow ? (1 + TILE_MAT_GROW * (_tier - _r.min)) : 1);
		_ws[_i] = _w;
		_tot += _w;
	}
	if (_tot <= 0) return 0;
	var _roll = random(_tot);
	for (var _i = 0; _i < array_length(_c); _i++) {
		_roll -= _ws[_i];
		if (_roll <= 0) return _c[_i].kind;
	}
	return _c[array_length(_c) - 1].kind;
}
