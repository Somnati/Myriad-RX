/// ROUND 33, THE HYBRID (his call, un-retiring r32): this replay is
/// LIVE again - offline production returned; the time bank accrues
/// on top and spends live through tiles_tick's _tmult.
/// @description tiles_fastforward(sec) - feed away-time into the tile
/// table. replaces Myriad's unused offline_module_timer estimate (the
/// log2 merge-tree guess) with an EXACT aggregate replay of the live
/// rules: whole fabrication cycles produce tier-1 tiles, whole
/// automerge cycles each fold the lowest equal pair on the board, and
/// banked/fabricated tiles flow into freed slots between merges - the
/// same binary-counter dance the live board does, minus the waiting.
/// the outcome lands in the away ledger for the report to show.
/// ROUND 36 (the uncapped budget-aware replay): the offline_cap
/// seconds clamp is GONE - the whole absence feeds in, however long.
/// the fabrication side is closed form (safe at any span); the merge
/// loop is the O(merges) part, so it rides an optional WALL budget
/// (_wall_us, microseconds - syst_offline hands it the slice left
/// over after the main walk) and bails exactly like its no-pair
/// break when the clock runs out: the timer sits full, live play
/// resumes merging one cycle at a time. returns a small report
/// { merges, avail, bailed } for the debug bench's honesty.
/// called by syst_offline with the save system's time_away.
function tiles_fastforward(_sec, _wall_us = -1) {
	var _t = tiles_init();
	// power (round 3 + merger split): each consumer's budget scales by
	// ITS OWN time-weighted throttle (power_dials_fastforward runs
	// FIRST and computes both - syst_offline owns that order). the
	// fabricator rides thr_avg (alloc-scaled), the merger rides
	// thr_am_avg (its own powered machine, on/off gated) - throttled
	// gear runs slower offline exactly as it would have live, and the
	// formulas are the same ones tiles_tick integrates per step
	// ...and the automation rates (his design, 2026-09-11): the
	// fabricator's and the merger's speed x the RAM throttle, exactly
	// what tiles_tick multiplies by live - so an absence runs at the
	// rate the player left set, and offline == online holds
	var _sec_fab = _sec * clamp(_t[$ "thr_avg"]    ?? 1, 0, 1) * autom_rate("fab");
	var _sec_am  = _sec * clamp(_t[$ "thr_am_avg"] ?? 1, 0, 1) * autom_rate("merge");
	if (_sec_fab < 1 && _sec_am < 1)
		return { merges : 0, avail : 0, bailed : false };

	// ---- fabrication: whole tiles produced, timer carry kept ----
	_t.fab += _sec_fab * 60;
	var _pool = floor(_t.fab / _t.fab_t);
	_t.fab -= _pool * _t.fab_t;
	// duplication over the whole batch: the expected extra tiles, the
	// fractional remainder rolled once - the same odds the live tick
	// rolls per tile, paid in bulk (offline == online, in expectation)
	var _dup = _pool * tile_chance_rate("dup") / 100;
	_pool += floor(_dup) + ((random(1) < frac(_dup)) ? 1 : 0);
	var _made = _pool;

	// ---- automerge cycles earned (timer carry kept) ----
	_t.am_tic_ = _t.fab_t * _t.am_mult;
	var _mavail = 0;
	if (_t.automerge) {
		_t.am_tic += _sec_am * 60;
		_mavail = floor(_t.am_tic / _t.am_tic_);
		_t.am_tic -= _mavail * _t.am_tic_;
	}

	// ---- histogram of the board: parallel arrays, tiers ascending ----
	var _ht = []; // tier
	var _hc = []; // count
	var _used = 0;
	for (var _i = 0; _i < _t.slots; _i++) {
		var _tr = _t.tier[_i];
		if (_tr == 0) continue;
		_used++;
		var _at = -1;
		for (var _k = 0; _k < array_length(_ht); _k++)
			if (_ht[_k] == _tr) { _at = _k; break; }
		if (_at != -1) _hc[_at]++;
		else {
			var _ins = array_length(_ht);
			for (var _k = 0; _k < array_length(_ht); _k++)
				if (_ht[_k] > _tr) { _ins = _k; break; }
			array_insert(_ht, _ins, _tr);
			array_insert(_hc, _ins, 1);
		}
	}

	// ---- the merge loop: top the board up from the banks (stored
	// first, then fresh fabrication - live drain order), fold the
	// lowest pair, repeat. no pair = the timer sat full waiting ----
	var _merges = 0;
	var _hi_from = _t.highest;
	// round 36: the wall deadline (an uncapped year can earn millions
	// of merge cycles - the budget, not a seconds clamp, bounds them)
	var _dl = (_wall_us > 0) ? get_timer() + _wall_us : -1;
	var _bail = false;
	repeat (_mavail) {
		if (_dl > 0 && get_timer() > _dl) {
			// out of budget: same posture as the no-pair break - the
			// timer sits full, live play resumes merging at its cadence
			_bail = true;
			if (_t.automerge) _t.am_tic = _t.am_tic_;
			break;
		}
		// top up: materializing tiles roll their tier through the house
		// rarity system, exactly like the live drain (g.tile_rarity is
		// saved, so offline luck matches live luck)
		while (_used < _t.slots && (_t.stored > 0 || _pool > 0)) {
			if (_t.stored > 0) _t.stored--; else _pool--;
			var _rt = tile_roll_tier();
			if (_rt > _t.highest) _t.highest = _rt;
			var _ra = -1;
			for (var _k = 0; _k < array_length(_ht); _k++)
				if (_ht[_k] == _rt) { _ra = _k; break; }
			if (_ra != -1) _hc[_ra]++;
			else {
				var _ri = array_length(_ht);
				for (var _k = 0; _k < array_length(_ht); _k++)
					if (_ht[_k] > _rt) { _ri = _k; break; }
				array_insert(_ht, _ri, _rt);
				array_insert(_hc, _ri, 1);
			}
			_used++;
		}
		// lowest tier holding a pair
		var _li = -1;
		for (var _k = 0; _k < array_length(_ht); _k++)
			if (_hc[_k] >= 2) { _li = _k; break; }
		if (_li == -1) { if (_t.automerge) _t.am_tic = _t.am_tic_; break; }

		// fold: same rules as tiles_merge (scaled step, bonus_rate roll,
		// frontier guarantee)
		var _tr2 = _ht[_li];
		var _stp = floor(1 + _tr2 / 10000);
		var _nt = _tr2 + _stp;
		if (random(100) < tile_chance_rate("tierup")   // tier up (tiles_merge's roll)
		|| random(100) < _t.bonus_rate
		|| (_t.bonus_rate > 0 && _nt == _t.highest)) _nt += _stp;
		_hc[_li] -= 2;
		if (_hc[_li] <= 0) { array_delete(_ht, _li, 1); array_delete(_hc, _li, 1); }
		var _at2 = -1;
		for (var _k = 0; _k < array_length(_ht); _k++)
			if (_ht[_k] == _nt) { _at2 = _k; break; }
		if (_at2 != -1) _hc[_at2]++;
		else {
			var _ins2 = array_length(_ht);
			for (var _k = 0; _k < array_length(_ht); _k++)
				if (_ht[_k] > _nt) { _ins2 = _k; break; }
			array_insert(_ht, _ins2, _nt);
			array_insert(_hc, _ins2, 1);
		}
		_used--;
		_merges++;
		_t.merges++;
		if (_nt > _t.highest) _t.highest = _nt;
	}

	// ---- write the board back: highest tiers first, then drain the
	// leftover production into free slots / the stored bank ----
	var _s2 = 0;
	for (var _k = array_length(_ht) - 1; _k >= 0; _k--)
		repeat (_hc[_k]) { if (_s2 < _t.slots) _t.tier[_s2++] = _ht[_k]; }
	while (_s2 < _t.slots && (_t.stored > 0 || _pool > 0)) {
		if (_t.stored > 0) _t.stored--; else _pool--;
		var _ft = tile_roll_tier(); // rarity applies to the final fill too
		if (_ft > _t.highest) _t.highest = _ft;
		_t.tier[_s2++] = _ft;
	}
	while (_s2 < _t.slots) _t.tier[_s2++] = 0;
	var _bank = min(_pool, _t.stored_max - _t.stored);
	_t.stored += _bank;
	_pool -= _bank;
	// production beyond capacity never happened: the fabricator WAITS
	// at full when board + bank are stuffed, offline included - the
	// report only counts tiles that actually materialized
	if (_pool > 0) {
		_made -= _pool;
		_t.fab = _t.fab_t;
	}

	// SHARDS FOR THE ABSENCE. The board's rate is recomputed by the next
	// tick, so the honest figure over a stretch where the board was
	// changing is its rate at the END times the span - the same
	// approximation the tick makes every second, applied once.
	// tile_out, the same per-tile figure the live tick sums (offline ==
	// online). This summed tile_gps - the BASE - until 2026-09-10, so
	// an absence paid without the flux boost the live board had.
	var _sh = 0;
	for (var _i2 = 0; _i2 < _t.slots; _i2++)
		if (_t.tier[_i2] != 0) _sh = do_add(_sh, tile_out(_t.tier[_i2]));
	// ⚖️ _sec, NOT _secs. This read `_secs` - a name that does not exist
	// in this function - and every save load with time behind it threw.
	// It survived because TILES_LIVE gated offline_replay's tiles branch
	// until 2026-09-09, so the typo shipped into a path nothing could
	// reach. The FULL span is right here, unlike the fabricator and
	// automerge spans above: those two are throttled (_sec_fab,
	// _sec_am), shard income is not.
	if (_sh >= arb(1) && _sec >= 1) {
		var _sadd = do_scale(_sh, floor(_sec));
		_t.shards = (_t.shards >= arb(1)) ? do_add(_t.shards, _sadd) : _sadd;
		_t.earned = (_t.earned >= arb(1)) ? do_add(_t.earned, _sadd) : _sadd;
	}
	// ...and the board's RATE is that sum, now, not at the next tick:
	// offline_replay reads tile_dial_boost straight after this to price
	// the dials' absence (2026-09-10), and a stale gps was the board
	// you LEFT, not the one you came back to
	_t.gps = _sh;

	_t.dirty = true;
	// round 2 (per-mechanic popups): no direct report anymore - the
	// replay feeds the tile room's AWAY LEDGER, and the room builds its
	// welcome-back from the ledger's own window when it's next opened
	// (so closed-game time and live time elsewhere add up honestly)
	if (!variable_global_exists("away")) away_init();
	// lifetime AND the window, off the same settled figure - _made has
	// had the never-materialised overflow taken back out by here
	_t.made             += _made;
	g.away.tiles.fab    += _made;
	g.away.tiles.merges += _merges;

	return { merges : _merges, avail : _mavail, bailed : _bail };
}
