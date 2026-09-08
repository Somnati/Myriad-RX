/// @description tile_upg(id, [commit]);
/// @param id       "speed" / "luck" / "slots" / "bank"
/// @param [commit]
/// The tile table's ONE upgrade lawyer, priced in SHARDS.
///     cost(level) = base x mult^level
/// commit = false gives a dry quote { ok, cost, lv }; cost is a packed
/// arb, because shards outgrow a plain real about as fast as profit
/// does.
///
/// The closed form lives in log space and packs exactly once - the
/// house rule for anything geometric, and the reason a level-40 price
/// costs the same to quote as a level-1 one.
function tile_upg(_id, _commit = true) {
	tiles_init();
	var _cfg = tile_upg_config();
	var _e = -1;
	for (var _i = 0; _i < array_length(_cfg); _i++)
		if (_cfg[_i].id == _id) _e = _cfg[_i];
	if (_e == -1) return { ok : false, cost : arb(1), lv : 0 };

	var _lv = g.tiles.upg[$ _id] ?? 0;
	var _cost = do_ceil(log_to_arb(log10(_e.base) + _lv * log10(_e.mult)));

	if (!_commit) return { ok : (g.tiles.shards >= _cost), cost : _cost, lv : _lv };
	if (!(g.tiles.shards >= _cost)) return { ok : false, cost : _cost, lv : _lv };

	g.tiles.shards = do_subtract(g.tiles.shards, _cost);
	g.tiles.upg[$ _id] = _lv + 1;
	tiles_sync();          // the board takes its new shape at once
	save_mark_dirty();
	return { ok : true, cost : _cost, lv : _lv + 1 };
}
