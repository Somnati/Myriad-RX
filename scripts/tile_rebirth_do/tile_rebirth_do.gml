/// @description tile_rebirth_do() - commit a tile rebirth. Returns the
/// FLUX awarded, or 0 if it refused.
///
/// ⚖️ WHAT SURVIVES IS THE POINT. The board, the hopper, the shards,
/// the LIFETIME EARNED and EVERY UPGRADE LEVEL all go - earned is the
/// measure, so leaving it would pay for the same work twice and the
/// second rebirth would be free. What survives is the FLUX and the
/// rebirth count. Nothing else.
///
/// ⚖️ THE UPGRADES GO TOO (his call, 2026-09-10 - reversing my first
/// draft, which kept them on the game rebirth's precedent that losing
/// the core collection felt bad). The difference is what the two
/// prestiges are FOR. The core collection is a thing you found; the
/// tile upgrades are a thing you bought with the board's own currency,
/// and flux is the compounding replacement for them: +1% of output per
/// point, forever, on a board that starts over. Keeping the upgrades
/// would have made the second run a strictly bigger first run and the
/// flux a footnote; wiping them makes the flux the whole reason the
/// second run climbs faster - which is what a prestige currency is.
/// It also means the profit upgrade's gate closes: the table is
/// unwired from the dials again until level 1 is rebought.
function tile_rebirth_do() {
	tiles_init();
	var _c = tile_rebirth_calc();
	if (!_c.can || _c.flux <= 0) return 0;

	var _t = g.tiles;
	// FLUX ACCUMULATES - it is a currency, and the pile is the point
	_t.flux     = (_t[$ "flux"] ?? 0) + _c.flux;
	_t.rb_total = (_t[$ "rb_total"] ?? 0) + 1;

	// the board back to nothing
	for (var _i = 0; _i < _t.slots; _i++) _t.tier[_i] = 0;
	_t.stored  = 0;
	_t.fab     = 0;
	_t.am_tic  = 0;
	_t.shards  = 0;
	_t.earned  = 0;      // the measure resets with the thing it measured
	_t.highest = 1;
	_t.gps     = 0;
	_t.ev      = [];
	_t.dirty   = true;
	_t.rev++;

	// EVERY upgrade level, by key rather than by roster - a level that
	// survived here would be a level the save writes back out, and the
	// upg struct can hold keys the roster no longer lists (slots, and
	// whatever a later roster adds)
	var _ks = variable_struct_get_names(_t.upg);
	for (var _k = 0; _k < array_length(_ks); _k++) _t.upg[$ _ks[_k]] = 0;

	tiles_sync();        // the board takes its new shape at once
	// a rare, heavy moment - the save menu's own rule for these
	syst_handle_save.action = sv_save;
	return _c.flux;
}
