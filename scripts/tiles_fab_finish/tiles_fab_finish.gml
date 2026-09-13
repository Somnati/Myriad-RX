/// @description tiles_fab_finish() -> did a tile come off the line? THE
/// ONE SITE a fabrication completes (tiles_tick when the bar fills;
/// tiles_fab_charge when a charge pushes it over - possibly more than
/// once). The bar must already be at or past full.
///
/// ⚖️ THE HOPPER IS OVERFLOW, NOT A CONVEYOR: a tile is finished if
/// there is anywhere for it to go - the hopper's room or a free slot
/// (the tick's drain moves it there in the same step). With nowhere,
/// the bar CLAMPS full and waits (Myriad's behaviour) - no production
/// is ever silently lost, and this returns false.
/// DUPLICATION (his upgrade, 2026-09-10): a finished tile comes out as
/// two at tile_chance_rate("dup") percent, if the table has room for
/// the second one - a duplicate that overfilled the hopper would read
/// "6/5", which is a number the screen cannot mean.
function tiles_fab_finish() {
	var _t = g.tiles;
	var _room = (_t.stored < _t.stored_max);
	if (!_room)
		for (var _i = 0; _i < _t.slots; _i++)
			if (_t.tier[_i] == 0) { _room = true; break; }
	if (!_room) {
		_t.fab = _t.fab_t;   // board full AND hopper full: waiting
		return false;
	}
	_t.fab -= _t.fab_t;
	_t.stored++;
	_t.made++;   // lifetime, for the statistics
	// away ledger (round 2): the tile room's own welcome-back window
	// counts live fabrication too
	if (variable_global_exists("away")) g.away.tiles.fab++;
	var _free = 0;
	for (var _i = 0; _i < _t.slots; _i++) if (_t.tier[_i] == 0) _free++;
	if (_t.stored < _t.stored_max + _free)
	if (random(100) < tile_chance_rate("dup")) {
		_t.stored++;
		_t.made++;
		if (variable_global_exists("away")) g.away.tiles.fab++;
		if (array_length(_t.ev) < 12) array_push(_t.ev, { k : "dup", i : -1, b : false });
	}
	_t.dirty = true;
	return true;
}
