/// @description tile_fupg(id, [commit]) -> { ok, cost, lv, max }
/// THE FLUX LAWYER - one level of a flux-ladder row: the price
/// (base x curve^lv, whole flux), whether the held flux covers it, and
/// on commit the purchase: flux off the pile (tile_rebirth_boost reads
/// the pile, so the table's own boost drops by what was spent - the
/// decision), the level up, the caches bumped. Never touched by a
/// reset.
/// @param id        the row (tile_flux_config)
/// @param [commit]  true to buy; false is a dry quote
function tile_fupg(_id, _commit = false) {
	tiles_init();
	var _t = g.tiles;
	var _cfg = tile_flux_config();
	var _e = -1;
	for (var _i = 0; _i < array_length(_cfg); _i++) if (_cfg[_i].id == _id) _e = _cfg[_i];
	if (_e == -1) return { ok : false, cost : 1, lv : 0, max : false };
	var _lv = _t.fupg[$ _id] ?? 0;
	if (_lv >= _e.max) return { ok : false, cost : 0, lv : _lv, max : true };
	var _cost = ceil(_e.base * power(_e.curve, _lv));
	var _ok = ((_t[$ "flux"] ?? 0) >= _cost);
	if (!_commit || !_ok) return { ok : _ok, cost : _cost, lv : _lv, max : false };
	_t.flux -= _cost;
	_t.fupg[$ _id] = _lv + 1;
	_t.dirty = true;
	_t.rev++;
	tiles_sync();
	save_mark_dirty();
	return { ok : true, cost : _cost, lv : _lv + 1, max : false };
}
