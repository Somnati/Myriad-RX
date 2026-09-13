/// @description tile_skin_roll(tier) -> the material kind a tile of this
/// tier wears: the ladder's row (tile_mat_config), the top six cycling
/// past its end. Deterministic now (his call: tied to the tier) - the
/// name and the per-tile store survive from the pool days, so a pool
/// can come back as one function if he ever wants variety within a
/// tier again. 0 for an empty slot or with the materials off.
function tile_skin_roll(_tier) {
	if (_tier <= 0) return 0;
	if (!TILE_MATERIAL) return 0;
	var _c = tile_mat_config();
	var _n = array_length(_c);
	if (_tier <= _n) return _c[_tier - 1].kind;
	var _cyc = min(6, _n);
	return _c[_n - _cyc + ((_tier - _n - 1) mod _cyc)].kind;
}
