/// @description autom_tiles();
/// The tile table's upgrade autobuy pulse (his ask, 2026-09-11: "a way
/// to automate tile upgrade autobuy"). One row per tile_upg_config
/// entry, each with its own cap: the most one level may cost, as a
/// share of the SHARDS held - re-read per purchase off the live bank,
/// the dials' semantics. Everything prices through tile_upg, the one
/// lawyer, so the curve, the cap, the inflation and the dirty mark all
/// hold for automation exactly as they hold for a press.
///
/// ONE LEVEL PER ROW PER ATTEMPT, each row on its own clock (t seconds,
/// counted in throttled time - autom_tick hands in this step's share).
/// Every row climbs decades a level, so the clock is never the
/// bottleneck - the shards are - and there is no q/h ramp to keep,
/// unlike the dials. Rows run in roster order, which puts the profit
/// boost first: the one that compounds.
///
/// st is the panel's verdict pill: 0 off, 1 waiting, 2 bought.
/// @param dt   throttled seconds elapsed this step
function autom_tiles(_dt) {
	autom_init();
	if (!variable_global_exists("tiles")) return;
	var _t   = g.autom.tiles;
	var _cfg = tile_upg_config();
	for (var _i = 0; _i < array_length(_cfg); _i++) {
		var _id = _cfg[_i].id;
		var _p  = _t[$ _id];
		if (_p == undefined) continue;
		if (!_p.on) { _p.st = 0; _p.tic = 0; continue; }
		_p.tic -= _dt;
		if (_p.tic > 0) continue;
		_p.tic = max(RAM_TIMER_FLOOR, _p.t);
		var _q = tile_upg(_id, false);
		if (_q.max) { _p.st = 1; continue; }
		// the cap, off the live bank: a share of nothing buys nothing
		if (!(g.tiles.shards >= arb(1))) { _p.st = 1; continue; }
		if (!(do_scale(g.tiles.shards, _p.pct / 100) >= _q.cost)) { _p.st = 1; continue; }
		_p.st = tile_upg(_id, true).ok ? 2 : 1;
	}
}
