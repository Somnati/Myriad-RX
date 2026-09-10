/// @description tile_upg_bulk(id, [commit]) - buy (or quote) as many
/// levels of one tile upgrade as the BUY-AMOUNT button asks for.
/// Returns { ok, cost, lv, n, max }: cost is the TOTAL for n levels, n is
/// how many the mode would actually buy right now, lv the level after.
///
/// ⚖️ THE BUY AMOUNT LIVES HERE, NOT IN tile_upg (his ask, 2026-09-10: a
/// buy-amount button for the tiles). tile_upg stays the one-level lawyer
/// - the curve, the cap, the inflation, all of it - and this walks it.
/// A bulk purchase is a sequence of single ones priced individually, so
/// the sum is exact by construction: level 12 costs what level 12 costs
/// whether you arrived by ten presses or one, and there is no second
/// cost formula that could drift from the first.
///
/// g.tile_buy_lv is the mode: 1 / 10 / 100 buy that many at most, "max"
/// buys until the shards run out or the cap lands. For a fixed count
/// that CANNOT all be afforded, the quote is for what CAN - a button
/// reading "x10 1e9" that only sells you three is a button that lies,
/// so it reads "x3" instead. The dial drawer's buy button has the same
/// contract.
///
/// COMMIT WALKS ONE AT A TIME through tile_upg's own commit, so every
/// side effect it owns - the shard deduction, the level write,
/// tiles_sync, the dirty mark - fires exactly as often as levels were
/// bought, in order. Nothing here touches g.tiles directly.
function tile_upg_bulk(_id, _commit = false) {
	var _mode = variable_global_exists("tile_buy_lv") ? g.tile_buy_lv : 1;
	var _want = (_mode == "max") ? 100000 : max(1, _mode);

	// ---- the dry walk: how many, for how much ----
	var _q = tile_upg(_id, false);
	if (_q.max) return { ok : false, cost : arb(1), lv : _q.lv, n : 0, max : true };

	var _bank = g.tiles.shards;
	var _tot  = 0;
	var _n    = 0;
	var _lv   = _q.lv;
	var _cfg  = tile_upg_config();
	var _e    = -1;
	for (var _i = 0; _i < array_length(_cfg); _i++)
		if (_cfg[_i].id == _id) _e = _cfg[_i];
	var _cap  = (_e == -1) ? -1 : (_e[$ "max"] ?? -1);

	// price each next level off tile_upg's formula by TEMPORARILY
	// advancing the level in the struct, then putting it back - the
	// only way to reuse the one formula without a second copy of it.
	// A dry run must leave no trace, and this leaves none.
	var _lv0 = g.tiles.upg[$ _id] ?? 0;
	while (_n < _want) {
		if (_cap >= 0 && _lv >= _cap) break;
		g.tiles.upg[$ _id] = _lv;
		var _qq = tile_upg(_id, false);
		var _c  = _qq.cost;
		var _next = (_tot == 0) ? _c : do_add(_tot, _c);
		if (!(_bank >= _next)) break;          // this one is not affordable
		_tot = _next;
		_lv++;
		_n++;
	}
	g.tiles.upg[$ _id] = _lv0;

	if (_n == 0) {
		// nothing affordable: quote the NEXT level so the button still
		// shows a price to aim for, exactly as the single buy does
		return { ok : false, cost : _q.cost, lv : _lv0, n : 0, max : false };
	}
	if (!_commit)
		return { ok : true, cost : _tot, lv : _lv0, n : _n, max : false };

	// ---- the real walk ----
	var _got = 0;
	repeat (_n) {
		var _r = tile_upg(_id, true);
		if (!_r.ok) break;
		_got++;
	}
	return { ok : (_got > 0), cost : _tot, lv : _lv0 + _got, n : _got, max : false };
}
