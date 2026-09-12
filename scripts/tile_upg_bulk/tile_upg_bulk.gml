/// @description tile_upg_bulk(id, [commit]) - buy (or quote) as many
/// levels of one tile upgrade as the BUY-AMOUNT button asks for.
/// Returns { ok, cost, lv, n, max }: cost is the TOTAL for n levels, n
/// is how many the mode names, ok whether the shards cover it, lv the
/// level after a commit (the level now, for a quote).
///
/// ⚖️ THE BUY AMOUNT LIVES HERE, NOT IN tile_upg (his ask, 2026-09-10: a
/// buy-amount button for the tiles). tile_upg stays the one-level lawyer
/// - the curve, the cap, the inflation, all of it - and this walks it.
/// A bulk purchase is a sequence of single ones priced individually, so
/// the sum is exact by construction: level 12 costs what level 12 costs
/// whether you arrived by ten presses or one, and there is no second
/// cost formula that could drift from the first.
///
/// ⚖️ THE MODES MEAN WHAT THEY MEAN IN THE DIAL DRAWER (his report,
/// 2026-09-10: "the buy amounts dont do anything"). The first version
/// quoted only what could be AFFORDED - x10 read "x3" when three were
/// in reach and, when none were, every mode fell back to the single
/// next level, so cycling the button changed nothing on screen. That
/// was honest and useless: the point of x10 is to see what ten COST.
/// So now, buy_resolve's contract:
///   1 / 10 / 100   exactly that many (or up to the next round level,
///                  the "rounded bulk buys" setting - DE's rule), the
///                  cap permitting. Quoted whether or not the shards
///                  cover it; ok says if they do; a commit takes ALL OF
///                  THEM OR NONE - the button never sells part of what
///                  it priced.
///   "max"          as many as the shards cover, at least one - the
///                  one adaptive mode. Nothing affordable quotes the
///                  next single level, unaffordable.
///
/// COMMIT WALKS ONE AT A TIME through tile_upg's own commit, so every
/// side effect it owns - the shard deduction, the level write,
/// tiles_sync, the dirty mark - fires exactly as often as levels were
/// bought, in order. Nothing here touches the levels directly except
/// the dry walk, which advances the struct's level to price each next
/// rung off the one formula and puts it back - a dry run must leave no
/// trace, and this leaves none.
/// @param [mode]  the buy amount - the drawer's button by default
///                (g.tile_buy_lv); autobuy hands in "max"
/// @param [bank]  what the walk may spend - the shards by default;
///                autobuy hands in its cap share (his call, 2026-09-12)
function tile_upg_bulk(_id, _commit = false, _mode = undefined, _bank_in = undefined) {
	if (is_undefined(_mode)) _mode = variable_global_exists("tile_buy_lv") ? g.tile_buy_lv : 1;

	var _q = tile_upg(_id, false);
	if (_q.max) return { ok : false, cost : arb(1), lv : _q.lv, n : 0, max : true };

	var _cfg  = tile_upg_config();
	var _e    = -1;
	for (var _i = 0; _i < array_length(_cfg); _i++)
		if (_cfg[_i].id == _id) _e = _cfg[_i];
	var _cap  = (_e == -1) ? -1 : (_e[$ "max"] ?? -1);
	var _lv0  = _q.lv;
	var _bank = _bank_in ?? g.tiles.shards;

	// ---- how many the mode names ----
	var _n = 1;
	var _adaptive = false;
	if (is_real(_mode) && _mode > 1) {
		var _k = floor(_mode);
		var _round = (!variable_global_exists("buy_round") || g.buy_round);
		var _to = _round ? floor((_lv0 + _k) / _k) * _k : _lv0 + _k;
		if (_cap >= 0) _to = min(_to, _cap);
		_n = max(1, _to - _lv0);
	}
	else if (is_string(_mode) && _mode == "max") {
		_adaptive = true;
		_n = 1000000;   // until the shards or the cap say stop
	}

	// ---- the dry walk: price each rung off tile_upg's formula ----
	var _tot = 0;
	var _got = 0;
	var _lv  = _lv0;
	while (_got < _n) {
		if (_cap >= 0 && _lv >= _cap) break;
		g.tiles.upg[$ _id] = _lv;
		var _c = tile_upg(_id, false).cost;
		var _next = (_got == 0) ? _c : do_add(_tot, _c);
		// max stops at the first rung the shards do not reach (past the
		// first - the first is always quoted); a fixed count keeps
		// pricing, because the quote is the whole bundle
		if (_adaptive && _got > 0 && !(_bank >= _next)) break;
		_tot = _next;
		_lv++;
		_got++;
	}
	g.tiles.upg[$ _id] = _lv0;
	_n = _got;

	var _ok = (_n > 0) && (_bank >= _tot);
	if (!_commit || !_ok)
		return { ok : _ok, cost : _tot, lv : _lv0, n : _n, max : false };

	// ---- the real walk: all of them, one at a time ----
	var _did = 0;
	repeat (_n) {
		var _r = tile_upg(_id, true);
		if (!_r.ok) break;
		_did++;
	}
	return { ok : (_did > 0), cost : _tot, lv : _lv0 + _did, n : _did, max : false };
}
