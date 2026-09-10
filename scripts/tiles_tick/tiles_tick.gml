/// @description tiles_tick() - one step of the tile-table sim, run by
/// syst_tiletimer EVERY step in EVERY room. this is what makes the
/// table live globally (Myriad's syst_moduletimer behavior): tiles
/// fabricate, automerge, and g.tiles.gps stays current so any system
/// can read the table's bonus without the tile room existing.
/// presentation stays out: board changes push events onto g.tiles.ev
/// and the room view drains them into glow/sounds when one is around.
function tiles_tick(_tmult = 1) {
	tiles_sync();   // slots / period / hopper / luck all derive from the
	                // upgrade levels - see tiles_sync
	var _t = g.tiles;

	// ---- fabricator: fills, banks, drains into the first free slot.
	// at the stored cap the timer CLAMPS full and waits (Myriad's
	// behavior) - the next free slot gets its tile instantly, and no
	// production is ever silently lost ----
	// power (round 3): the throttle scales TIME - alloc 0 or a starved
	// pool parks the fabricator, exactly like a throttled dial slows.
	// _tmult (round 32): the time bank's active-speed multiplier -
	// compressed SIM time for the powered parts (fabrication + the
	// merger); the deadlock failsafe below stays REAL-time (it's a UX
	// guard, not production)
	var _thr = _t[$ "thr"] ?? 1;
	_t.fab += delta * _tmult * _thr;
	if (_t.fab >= _t.fab_t) {
		// ⚖️ THE HOPPER IS OVERFLOW, NOT A CONVEYOR. This used to gate
		// purely on hopper room, which was invisible while the hopper
		// held ten by default and a hard stall the moment it held zero:
		// every tile passed THROUGH the reserve on its way to the board,
		// so a reserve of nothing meant a fabricator that never
		// produced. A tile is finished if there is anywhere for it to
		// go, and the board is the first of those places - the drain
		// below moves it there in this same tick, so the common case
		// still spends no time banked at all.
		var _room = (_t.stored < _t.stored_max);
		if (!_room)
			for (var _i = 0; _i < _t.slots; _i++)
				if (_t.tier[_i] == 0) { _room = true; break; }
		if (!_room) {
			_t.fab = _t.fab_t; // board full AND hopper full: waiting
		} else {
			_t.fab -= _t.fab_t;
			_t.stored++;
			_t.made++;   // lifetime, for the statistics
			// away ledger (round 2): the tile room's own welcome-back
			// window counts live fabrication too
			if (variable_global_exists("away")) g.away.tiles.fab++;
			// ⚖️ DUPLICATION (his upgrade, 2026-09-10): a finished tile
			// comes out as two, at tile_chance_rate("dup") percent. The
			// second one needs somewhere to go - the hopper's room plus
			// the board's free slots, less the one the first will take
			// - and a table with no room simply does not get it. A
			// duplicate that overfilled the hopper would sit there
			// reading "6/5", which is a number the screen cannot mean.
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
		}
	}
	if (_t.stored > 0) {
		var _os = -1;
		for (var _i = 0; _i < _t.slots; _i++)
			if (_t.tier[_i] == 0) { _os = _i; break; }
		if (_os != -1) {
			// tier rolls through the house rarity system at the moment
			// the tile materializes (g.tile_rarity -> calculate_rarity)
			_t.tier[_os] = tile_roll_tier();
			if (_t.tier[_os] > _t.highest) _t.highest = _t.tier[_os];
			_t.stored--;
			_t.dirty = true;
			if (array_length(_t.ev) < 12) array_push(_t.ev, { k : "spawn", i : _os, b : false });
		}
	}

	// ---- auto-merge, the Myriad way: interval = fab interval x mult;
	// the timer runs whenever the feature is on and WAITS full when no
	// pair exists; the candidate pair is persistent (am_ia/am_ib) so a
	// view can glow it in; a click pushes an imminent merge back 10
	// steps so it never fires mid-interaction ----
	_t.am_tic_ = _t.fab_t * _t.am_mult;

	_t.am_ia = -1; _t.am_ib = -1;
	for (var _i = 0; _i < _t.slots && _t.am_ia == -1; _i++) {
		if (_t.tier[_i] == 0 || _i == _t.grab) continue;
		for (var _j = _i + 1; _j < _t.slots; _j++) {
			if (_j == _t.grab) continue;
			if (_t.tier[_j] == _t.tier[_i]) { _t.am_ia = _i; _t.am_ib = _j; break; }
		}
	}

	if (_t.automerge) {
		// the merger is its OWN powered machine (PM order 2026-07-12):
		// power_tick prices it separately (bal.tiles_merge_drain while
		// the toggle is on) and writes its throttle into thr_am - a
		// starved pool slows the cadence, soft, exactly like a machine
		var _thr_am = _t[$ "thr_am"] ?? 1;
		_t.am_tic += delta * _tmult * _thr_am;
		if (mouse_check_button_pressed(mb_left) && _t.am_tic > _t.am_tic_ - 10)
			_t.am_tic = _t.am_tic_ - 10;
		if (_t.am_tic > _t.am_tic_ && _t.am_ia == -1) _t.am_tic = _t.am_tic_; // full, waiting
		if (_t.am_tic >= _t.am_tic_ && _t.am_ia != -1) {
			_t.am_tic = 0;
			var _res = tiles_merge(_t.am_ib, _t.am_ia); // later folds into earlier
			// away ledger (round 2): AUTO merges only - the player's own
			// taps aren't "while you were away" news
			if (variable_global_exists("away")) g.away.tiles.merges++;
			if (array_length(_t.ev) < 12)
				array_push(_t.ev, { k : "merge", i : _t.am_ia, b : (_res == 3) });
		}
	} else _t.am_tic = 0;

	// ---- deadlock failsafe (always on): a board sitting full with no
	// legal merge for 5s tiers its lowest tile up so play never stalls ----
	var _full = true;
	var _pair = false;
	for (var _i = 0; _i < _t.slots && !_pair; _i++) {
		if (_t.tier[_i] == 0) { _full = false; break; }
		for (var _j = _i + 1; _j < _t.slots; _j++)
			if (_t.tier[_j] == _t.tier[_i]) { _pair = true; break; }
	}
	if (_full && !_pair && _t.grab == -1) {
		_t.searching += delta;
		if (_t.searching >= 60 * 5) {
			_t.searching = 0;
			var _low = 0;
			for (var _i = 1; _i < _t.slots; _i++)
				if (_t.tier[_i] < _t.tier[_low]) _low = _i;
			_t.tier[_low] += 1;
			if (_t.tier[_low] > _t.highest) _t.highest = _t.tier[_low];
			_t.dirty = true;
			if (array_length(_t.ev) < 12) array_push(_t.ev, { k : "fail", i : _low, b : false });
		}
	} else _t.searching = 0;

	// ---- the global total: recompute the arb sum only on change,
	// bump rev so views know to refresh, and mark the save dirty so
	// the autosave picks the progress up ----
	if (_t.dirty) {
		_t.dirty = false;
		// ⚖️ THE SUM OF THE FACES. tile_out is each tile's LIVE output -
		// base x the flux boost, floored to whole shards per tile (his
		// ask: the flux shows on the tiles, rounded down) - so the
		// board's rate is exactly what the tiles say it is, added up.
		// The flux boost used to land on the total here; per tile is
		// where it shows now, and the total follows.
		//
		// THE PROFIT UPGRADE IS NOT APPLIED HERE. It scales the board's
		// CONTRIBUTION TO DIAL PROFIT and lives entirely in
		// tile_dial_boost (his ask: DE's module boost, as the upgrade).
		// It was here as well once, and that was a straight double
		// count - the same level scaling gps and then scaling the boost
		// derived FROM gps.
		var _sum = 0;
		for (var _i = 0; _i < _t.slots; _i++)
			if (_t.tier[_i] != 0) _sum = do_add(_sum, tile_out(_t.tier[_i]));
		_t.gps = _sum;
		_t.rev++;
		save_mark_dirty();
	}
}
