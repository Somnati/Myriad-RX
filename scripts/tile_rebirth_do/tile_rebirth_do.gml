/// @description tile_rebirth_do() - commit a tile rebirth. Returns the
/// FLUX awarded, or 0 if it refused.
///
/// ⚖️ WHAT SURVIVES IS THE POINT. The board, the hopper, the shards and
/// the LIFETIME EARNED all go - earned is the measure, so leaving it
/// would pay for the same work twice and the second rebirth would be
/// free. What survives is the FLUX, the rebirth count, and the
/// UPGRADES.
///
/// Keeping the upgrades is the deliberate one, and it is the same call
/// the game's rebirth made about the core collection (round 14: losing
/// it felt bad). The upgrades are the part you chose; the board is the
/// part that accumulated. A prestige that confiscates your decisions
/// reads as a punishment, and this one is supposed to read as a lever.
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

	tiles_sync();        // the board takes its new shape at once
	// a rare, heavy moment - the save menu's own rule for these
	syst_handle_save.action = sv_save;
	return _c.flux;
}
