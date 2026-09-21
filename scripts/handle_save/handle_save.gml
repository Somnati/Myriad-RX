/// @description handle_save();
/// progress ONLY: display/options moved out to handle_settings()
/// (settings.ini), so an exported/imported savefile carries the run,
/// not the device setup.
/// MYRIAD RX (fresh foundation, 2026-08-14): stripped to the engine
/// sections. Every DE system rebuilt onto RX adds its own section
/// HERE as it lands - `handle(key, default)` is bidirectional
/// (driven by `action` + `section`), so one block serves save AND
/// load. The techdemo's handle_save is the shape reference for
/// section idioms (arrays, packed arbs, load-side clamps).

function handle_save(){

	//////////////////////////////////////////////////////////////////
	ini_open(file_to_handle);
	if system.debug = true or in_room(rm_gameload) show("opened > " + string(file_to_handle));
	//////////////////////////////////////////////////////////////////

	section = "system";
	last_datetime = handle("save_datetime",date_current_datetime());
	// THE RARITY LADDER'S VERSION (2026-09-17): 14 = the tech demo's rungs.
	// A save without the key is from DE's eight, and every rarity it holds
	// - sprites, their gear, the upgrade slots, the histogram, the finds,
	// the autosell flags - is lifted through rarity_remap8 as it loads,
	// while g.rarity_old is up
	g.rarity_v = (action == sv_save) ? 14 : 8;
	g.rarity_v = handle("rarity_v", g.rarity_v);
	g.rarity_old = (action == sv_load && real(g.rarity_v) < 14);

	section = "player";
	// the profile's identity lives IN its savefile: until a save exists
	// the name and color are just this boot's setgame rolls, and the
	// first save locks them in
	g.profile_name[g.profile]  = handle("name",g.profile_name[g.profile]);
	g.profile_color[g.profile] = handle("color",g.profile_color[g.profile]);
	// the ACTIVE clock keeps the original key so saves written before
	// the split still load their playtime; the away clock is new
	g.time_played_active = handle("playtime",g.time_played_active); // seconds, shown by slots
	g.time_played_offline = handle("playtime_off",g.time_played_offline);
	// THE CURRENCY: profit is a packed arb, which rides the ini as a
	// plain real. both move in whole units, so floor on load heals any
	// fraction-caught save
	g.upgrade_rarity = handle("upgrade_rarity", g.upgrade_rarity);
	g.profit       = handle("profit",       g.profit);
	g.offline_pool = handle("offline_pool", g.offline_pool);   // the uncollected pile
	g.total_profit = handle("total_profit", g.total_profit);
	if (action == sv_load) {
		g.profit       = do_floor(g.profit);
		g.total_profit = do_floor(g.total_profit);
	}
	// LIFETIME TAP COUNTERS. These were derived at boot and never
	// written, so "lifetime taps" started at zero every launch - the
	// statistics screen was reporting a session figure under a lifetime
	// label. create_clicker still seeds them, and a load overwrites.
	g.total_taps  = handle("total_taps",  g.total_taps);
	g.total_crits = handle("total_crits", g.total_crits);
	// the overcharger's level and charge (DE saved both; a charge that
	// died with the app would make closing the game a punishment)
	g.overcharge_lv = handle("overcharge_lv", g.overcharge_lv);
	g.overcharge_xp = handle("overcharge_xp", g.overcharge_xp);
	if (action == sv_load) {
		g.total_taps  = max(0, floor(g.total_taps));
		g.total_crits = max(0, floor(g.total_crits));
		g.overcharge_lv = clamp(floor(g.overcharge_lv), 1, 10);
		g.overcharge_xp = max(0, g.overcharge_xp);
	}

	// run difficulty (0 easy .. 3 critical), picked at new game.
	// stored only for now - future balance wiring reads it live
	g.difficulty = handle("difficulty", g.difficulty);
	// the three personality answers as one "a,b,c" string, and the veil
	var _ps = string(g.persona[0]) + "," + string(g.persona[1]) + "," + string(g.persona[2]);
	_ps = handle("persona", _ps);
	if (action == sv_load) {
		var _pp = string_split(string(_ps), ",");
		for (var _k = 0; _k < 3; _k++)
			g.persona[_k] = (_k < array_length(_pp) && _pp[_k] != "") ? floor(real(_pp[_k])) : -1;
	}
	g.unfold = handle("unfold", g.unfold);

	// ---- credits: the second currency (survives rebirth) + the
	// dropper's pool and cooldown ----
	section = "credits";
	credits_init();
	g.credits       = handle("credits",       g.credits);
	g.total_credits = handle("total_credits", g.total_credits);
	g.credit_pool   = handle("pool",          g.credit_pool);
	g.credit_cool   = handle("cool",          g.credit_cool);
	if (action == sv_load) {
		if (!(g.credits >= arb(1)))       g.credits = 0;
		if (!(g.total_credits >= arb(1))) g.total_credits = 0;
		g.credit_pool = clamp(g.credit_pool, 0, g.credit_cap);
		g.credit_cool = max(0, g.credit_cool);
	}

	// ---- rebirth: the meta layer that outlives runs (units bank as a
	// packed arb, plain 0 while empty) ----
	section = "rebirth";
	rebirth_init();
	g.rebirth.units       = handle("units",       g.rebirth.units);
	g.rebirth.total       = handle("total",       g.rebirth.total);
	g.rebirth.run_pt0     = handle("run_pt0",     g.rebirth.run_pt0);
	g.rebirth.prev_units  = handle("prev_units",  g.rebirth.prev_units);
	g.rebirth.prev_secs   = handle("prev_secs",   g.rebirth.prev_secs);
	g.rebirth.prev_profit = handle("prev_profit", g.rebirth.prev_profit);
	g.rebirth.hi_ms       = handle("hi_ms",       g.rebirth.hi_ms);
	g.rebirth.best_profit = handle("best_profit", g.rebirth.best_profit);
	g.rebirth.fed         = handle("fed",         g.rebirth.fed);
	if (action == sv_load) {
		g.rebirth.total = max(0, floor(g.rebirth.total));
		if (!(g.rebirth.units >= arb(1))) g.rebirth.units = 0;
		g.rebirth.hi_ms = max(0, floor(g.rebirth.hi_ms));
		if (!(g.rebirth.best_profit >= arb(1))) g.rebirth.best_profit = 0;
		// a save from before the fed profit: the pile is what it would have fed
		if (!(g.rebirth.fed >= arb(1))) g.rebirth.fed = (g.profit >= arb(1)) ? g.profit : 0;
		// ...and the milestone ledger heals from it silently (a pre-key save's
		// rungs are not news, and must not hand out a milestone ticket on the
		// first feed - rebirth_milestone_tick)
		if (g.rebirth.fed >= arb(1)) {
			var _flg = floor(g.rebirth.fed) + max(0, ((frac(g.rebirth.fed) * 10) - 1) / 9);
			g.rebirth.hi_ms = max(g.rebirth.hi_ms, ceil(max(0, (_flg - 16) / 10)));
		}
		// the best-run pennant heals from the run before (a pre-key save)
		if (g.rebirth.prev_profit >= arb(1) && !(g.rebirth.best_profit >= g.rebirth.prev_profit))
			g.rebirth.best_profit = g.rebirth.prev_profit;
		if (!(g.rebirth.prev_units >= arb(1))) g.rebirth.prev_units = 0;
	}

	// ---- history: the spark graphs, which are LIFETIME (his call) and
	// therefore have to outlive the session. A series is 120 reals and a
	// step, joined with pipes - 3 series is about 4KB of ini, which is
	// the whole price of a graph that reaches back months.
	// The buffer decimates itself (stats_hist_push), so this never grows
	// no matter how long the account runs. ----
	// ALLUVIUM (q314): the delta whole - its ledger and its four grids - as one string
	section = "delta";
	delta_init();
	var _dlt = handle("grid", delta_pack());
	if (action == sv_load) delta_unpack(_dlt);

	section = "history";
	if (!variable_global_exists("stats_hist")) g.stats_hist = {};
	if (!variable_global_exists("hist_meta"))  g.hist_meta  = {};
	var _hk = ["h_profit", "h_units", "h_ps"];
	for (var _h = 0; _h < array_length(_hk); _h++) {
		var _k = _hk[_h];
		var _arr = g.stats_hist[$ _k];
		var _mt  = g.hist_meta[$ _k];
		var _stp = is_struct(_mt) ? _mt.step : 1;

		// serialise. string_format, NOT string(): GM's default gives two
		// decimals, and a packed arb carries its coefficient in the
		// fraction - two decimals would flatten every curve to steps.
		var _s = "";
		if (is_array(_arr))
			for (var _i = 0; _i < array_length(_arr); _i++)
				_s += (_i > 0 ? "|" : "") + string_format(_arr[_i], 1, 5);

		_s   = handle(_k + "_buf",  _s);
		_stp = handle(_k + "_step", _stp);

		if (action == sv_load) {
			var _out = [];
			if (is_string(_s) && _s != "") {
				var _parts = string_split(_s, "|");
				for (var _i = 0; _i < array_length(_parts); _i++) {
					var _v = real(_parts[_i]);
					if (is_real(_v)) array_push(_out, _v);
				}
			}
			g.stats_hist[$ _k] = _out;
			g.hist_meta[$ _k]  = { step : max(1, floor(_stp)), acc : 0 };
		}
	}

	// ---- upgrades: the SLOTS and nothing else. Every effective number
	// derives from these at read time (upgrade_bonus), so this is the
	// whole of it - and a rebalance of any value reaches old saves for
	// free, which it could not if the effects had been written down. ----
	// ---- the tile table. THE FLAT TIER ARRAY IS THE WHOLE GAME STATE
	// (tiles_init's own law: 0 = an empty slot, controllers are views
	// over it), so one comma string carries the board. Everything else
	// - gps, the merge timer's period, the colour of anything - derives
	// on the next tick ----
	section = "tiles";
	// NOT WHILE THE TABLE IS BEING FINALISED (TILES_LIVE). A system
	// whose state shape is still moving has no business in a real
	// savefile: every iteration would churn the section, and a
	// half-finished writer is how a save gets corrupted rather than
	// merely stale.
	if (TILES_LIVE) {
		tiles_init();
		var _tt = "";
		for (var _k = 0; _k < g.tiles.slots; _k++)
			_tt += ((_k > 0) ? "," : "") + string(g.tiles.tier[_k]);
		_tt = handle("board", _tt);
		var _tsk = "";
		for (var _k = 0; _k < g.tiles.slots; _k++)
			_tsk += ((_k > 0) ? "," : "") + string((_k < array_length(g.tiles.skin)) ? g.tiles.skin[_k] : 0);
		_tsk = handle("skins", _tsk);   // each tile's material, parallel to the board (2026-09-13)
		g.tiles.fab     = handle("fab",     g.tiles.fab);
		// ⚖️ THE AUTOMERGE SWITCH WAS NEVER SAVED (his report,
		// 2026-09-11: "I want the automerger to work offline"). It
		// defaults off in tiles_init, so every closed-app absence
		// replayed with the merger OFF - tiles_fastforward's merge loop
		// was right all along and simply never armed. Its timer carry
		// rides with it, so a merge due at the moment you left lands.
		g.tiles.automerge = handle("automerge", g.tiles.automerge);
		g.tiles.am_tic    = handle("am_tic",    g.tiles.am_tic);
		g.tiles.aim_center = handle("aim_center", g.tiles.aim_center ?? false);
		g.tiles.stored  = handle("stored",  g.tiles.stored);
		g.tiles.highest = handle("highest", g.tiles.highest);
		g.tiles.merges  = handle("merges",  g.tiles.merges);
		g.tiles.made    = handle("made",    g.tiles.made);
		g.tiles.shards  = handle("shards",  g.tiles.shards);
		g.tiles.earned  = handle("earned",  g.tiles.earned);
		// the table's own prestige - units are the whole point of it,
		// so they are the one thing here that must never be derivable
		g.tiles.flux     = handle("flux",     g.tiles.flux);
		g.tiles.rb_total = handle("rb_total", g.tiles.rb_total);
		// the four upgrade levels. Everything they DO derives (tiles_sync),
		// so the levels are the whole of what a save carries about them.
		var _tuc = tile_upg_config();
		for (var _k = 0; _k < array_length(_tuc); _k++) {
			var _tid = _tuc[_k].id;
			g.tiles.upg[$ _tid] = handle("upg_" + _tid, g.tiles.upg[$ _tid] ?? 0);
			if (action == sv_load)
				g.tiles.upg[$ _tid] = max(0, floor(g.tiles.upg[$ _tid]));
		}
		if (action == sv_load) {
			// the board's size is an upgrade level now (slots row,
			// 2026-09-10): lay the board out from the levels just read
			// BEFORE parsing the tiles into it, or a 20-slot save reads
			// its first twelve and the rest are gone on every load
			tiles_sync();
			var _tp = string_split(_tt, ",");
			for (var _k = 0; _k < g.tiles.slots; _k++) {
				var _d5 = (_k < array_length(_tp)) ? string_digits(_tp[_k]) : "";
				g.tiles.tier[_k] = (_d5 == "") ? 0 : max(0, floor(real(_d5)));
			}
			// the surfaces: absent (a save from before them) or short reads
			// as unrolled, and tiles_skin_heal rolls those below
			var _sp = (_tsk != "") ? string_split(_tsk, ",") : [];
			for (var _k = 0; _k < g.tiles.slots; _k++) {
				var _d7 = (_k < array_length(_sp)) ? string_digits(_sp[_k]) : "";
				g.tiles.skin[_k] = (_d7 == "") ? -1 : floor(real(_d7));
			}
			// a save from a WIDER board (sixteen slots before the slots
			// row, 2026-09-10): the tiles past the edge take free slots
			// inside it rather than vanishing; only a full board drops
			// them. One-time, and it costs nothing to keep.
			for (var _k = g.tiles.slots; _k < array_length(_tp); _k++) {
				var _d6 = string_digits(_tp[_k]);
				var _v6 = (_d6 == "") ? 0 : max(0, floor(real(_d6)));
				if (_v6 == 0) continue;
				for (var _j = 0; _j < g.tiles.slots; _j++)
					if (g.tiles.tier[_j] == 0) { g.tiles.tier[_j] = _v6; g.tiles.skin[_j] = -1; break; }
			}
			tiles_skin_heal();   // after the tiers are in, not before (tiles_sync's own heal ran on an empty board)
			g.tiles.fab     = clamp(g.tiles.fab, 0, g.tiles.fab_t);
			g.tiles.stored  = clamp(floor(g.tiles.stored), 0, g.tiles.stored_max);
			g.tiles.highest = max(1, floor(g.tiles.highest));
			g.tiles.merges  = max(0, floor(g.tiles.merges));
			g.tiles.made    = max(0, floor(g.tiles.made));
			if (!(g.tiles.shards >= arb(1))) g.tiles.shards = 0;
			if (!(g.tiles.earned >= arb(1))) g.tiles.earned = 0;
			g.tiles.flux     = max(0, floor(g.tiles.flux));
			g.tiles.rb_total = max(0, floor(g.tiles.rb_total));
			tiles_sync();   // the board takes the loaded levels' shape
		}
	}
	// THE FLUX LADDER (tile_flux_config), by key like the shard rows -
	// permanent, so it is simply stored and read back. A save from
	// before the split carries a shard-bought "upg_profit" level: it
	// moves to the ladder whole (they paid for it) and the shard key is
	// zeroed so the drawer cannot show a row that no longer exists
	if (!variable_struct_exists(g.tiles, "fupg")) g.tiles.fupg = {};
	var _fcfg = tile_flux_config();
	for (var _k = 0; _k < array_length(_fcfg); _k++) {
		var _fid = _fcfg[_k].id;
		g.tiles.fupg[$ _fid] = handle("fupg_" + _fid, g.tiles.fupg[$ _fid] ?? 0);
		if (action == sv_load) g.tiles.fupg[$ _fid] = clamp(floor(g.tiles.fupg[$ _fid]), 0, _fcfg[_k].max);
	}
	if (action == sv_load) {
		var _oldp = handle("upg_profit", 0);
		if (is_real(_oldp) && _oldp > 0) {
			g.tiles.fupg.profit = max(g.tiles.fupg[$ "profit"] ?? 0, min(50, floor(_oldp)));
			g.tiles.upg[$ "profit"] = 0;
		}
	}

	// ---- automation: PREFERENCES only. The q/h pacing ramps are
	// session state by design (autom_init) - a ramp is a guess about
	// the current wallet, and the wallet is not the same after a load ----
	section = "automation";
	autom_init();
	var _an = array_length(g.autom.dial);
	// THE FILTER: one string of flags (thirteen dials is thirteen keys
	// otherwise). autom_v says what shape the save has: 2 = the master
	// row (2026-09-14); absent = a row per dial, migrated below
	var _aon = "";
	for (var _k = 0; _k < _an; _k++)
		_aon += ((_k > 0) ? "," : "") + (g.autom.dial[_k].on ? "1" : "0");
	_aon = handle("dial_on", _aon);
	var _av = handle("autom_v", (action == sv_save) ? 2 : 0);   // absent on load = the old shape
	if (action == sv_load) {
		var _p1 = string_split(_aon, ",");
		for (var _k = 0; _k < _an; _k++)
			g.autom.dial[_k].on = (_k < array_length(_p1)) ? (_p1[_k] == "1") : true;
	}
	g.autom.reb.on    = handle("reb_on",    g.autom.reb.on);
	g.autom.reb.t_on  = handle("reb_t_on",  g.autom.reb.t_on);
	g.autom.reb.t_min = handle("reb_t_min", g.autom.reb.t_min);
	g.autom.reb.u_on  = handle("reb_u_on",  g.autom.reb.u_on);
	g.autom.reb.u_min = handle("reb_u_min", g.autom.reb.u_min);
	g.autom.reb.g_on  = handle("reb_g_on",  g.autom.reb.g_on);
	g.autom.reb.g_pct = handle("reb_g_pct", g.autom.reb.g_pct);
	g.autom.reb.c_on  = handle("reb_c_on",  g.autom.reb.c_on);
	g.autom.reb.p_on  = handle("reb_p_on",  g.autom.reb.p_on);
	g.autom.reb.p_oom = handle("reb_p_oom", g.autom.reb.p_oom);
	g.autom.upg.roll  = handle("upg_roll",  g.autom.upg.roll);
	if (action == sv_load) g.autom.upg.roll = false;   // (no auto roll since 2026-09-17: offers turn up by the meter)
	g.autom.upg.buy   = handle("upg_buy",   g.autom.upg.buy);
	g.autom.upg.sell  = handle("upg_sell",  g.autom.upg.sell);
	g.autom.upg.pct   = handle("upg_pct",   g.autom.upg.pct);
	g.autom.upg.keep  = handle("upg_keep",  g.autom.upg.keep);
	g.autom.lock_pct  = handle("lock_pct",  g.autom.lock_pct);
	g.autom.lock_peak = handle("lock_peak", g.autom.lock_peak);

	// THE FILTER. Rarities are a fixed-length row of flags, so a comma
	// string of 0/1 says it exactly. KINDS are keyed BY ID and only the
	// ones switched to SELL are written - a roster entry added later
	// then defaults to keep rather than inheriting a flag from whatever
	// happened to sit at its index, which is the same reason the slots
	// store an id and not a position.
	var _fr = "";
	for (var _k = 0; _k < UPG_RARITY_N; _k++)
		_fr += ((_k > 0) ? "," : "") + (g.autom.upg.rar[_k] ? "1" : "0");
	_fr = handle("upg_rar", _fr);

	var _fk = "";
	var _kn = variable_struct_get_names(g.autom.upg.kind);
	for (var _k = 0; _k < array_length(_kn); _k++)
		if (!g.autom.upg.kind[$ _kn[_k]])
			_fk += ((_fk == "") ? "" : "|") + _kn[_k];
	_fk = handle("upg_sellkinds", _fk);

	if (action == sv_load) {
		var _p3 = string_split(_fr, ",");
		for (var _k = 0; _k < UPG_RARITY_N; _k++)
			g.autom.upg.rar[_k] = (_k < array_length(_p3)) ? (_p3[_k] == "1") : true;
		if (g.rarity_old) {   // eight flags onto fourteen rungs
			var _o8 = array_create(8, true);
			for (var _k = 0; _k < 8; _k++) _o8[_k] = (_k < array_length(_p3)) ? (_p3[_k] == "1") : true;
			for (var _k = 0; _k < UPG_RARITY_N; _k++) g.autom.upg.rar[_k] = true;
			for (var _k = 0; _k < 8; _k++) g.autom.upg.rar[rarity_remap8(_k)] = _o8[_k];
		}
		g.autom.upg.kind = {};
		if (_fk != "") {
			var _p4 = string_split(_fk, "|");
			for (var _k = 0; _k < array_length(_p4); _k++)
				if (_p4[_k] != "") g.autom.upg.kind[$ _p4[_k]] = false;
		}
	}
	// THE TILE AUTOBUY, keyed by id like the kinds: "id=on:pct:t|..." -
	// a roster entry added later reads as off/50/1s rather than as
	// whatever sat at its index
	var _ft = "";
	var _tn = variable_struct_get_names(g.autom.tiles);
	for (var _k = 0; _k < array_length(_tn); _k++) {
		var _tp = g.autom.tiles[$ _tn[_k]];
		_ft += ((_ft == "") ? "" : "|") + _tn[_k] + "="
		     + (_tp.on ? "1" : "0") + ":" + string(_tp.pct) + ":" + string(_tp.t);
	}
	_ft = handle("tiles_auto", _ft);
	if (action == sv_load && _ft != "") {
		var _p5 = string_split(_ft, "|");
		for (var _k = 0; _k < array_length(_p5); _k++) {
			var _kv = string_split(_p5[_k], "=");
			if (array_length(_kv) != 2) continue;
			var _tp = g.autom.tiles[$ _kv[0]];
			if (_tp == undefined) continue;
			var _op = string_split(_kv[1], ":");
			_tp.on  = (array_length(_op) > 0) && (_op[0] == "1");
			_tp.pct = (array_length(_op) > 1 && _op[1] != "") ? clamp(real(_op[1]), 1, 100) : 50;
			_tp.t   = (array_length(_op) > 2 && _op[2] != "") ? ram_snap("timer", real(_op[2])) : 30;
		}
	}

	// the upgrade buy clock, and RAM: the two default automations with
	// their speeds, the merger's speed, the modes
	g.autom.upg.t     = handle("upg_t",     g.autom.upg.t);
	g.autom.tap.on    = handle("tap_on",    g.autom.tap.on);
	g.autom.tap.rate  = handle("tap_rate",  g.autom.tap.rate);
	g.autom.run.on    = handle("run_on",    g.autom.run.on);
	g.autom.run.spd   = handle("run_spd",   g.autom.run.spd);
	g.autom.fab.on    = handle("fab_on",    g.autom.fab.on);
	g.autom.fab.spd   = handle("fab_spd",   g.autom.fab.spd);
	g.autom.am_speed  = handle("am_speed",  g.autom.am_speed);
	// THE MODES: a count, then name / pack / away per mode (up to eight).
	// The three numbered slots this replaced ("preset0..2") migrate on
	// load into named modes
	var _pn = handle("mode_n", array_length(g.autom.presets));
	for (var _k = 0; _k < 8; _k++) {
		var _has = (_k < array_length(g.autom.presets));
		var _nm = handle("mode" + string(_k) + "_name", _has ? g.autom.presets[_k].name : "");
		var _pk = handle("mode" + string(_k) + "_pack", _has ? g.autom.presets[_k].pack : "");
		var _of = handle("mode" + string(_k) + "_away", _has ? g.autom.presets[_k].offline : false);
		if (action == sv_load && _k < _pn && is_string(_pk) && _pk != "")
			g.autom.presets[_k] = { name : (is_string(_nm) && _nm != "") ? _nm : ("mode " + string(_k + 1)),
			                        pack : _pk, offline : (_of == true || _of == 1) };
	}
	if (action == sv_load) {
		array_resize(g.autom.presets, min(array_length(g.autom.presets), max(0, floor(_pn))));
		if (array_length(g.autom.presets) == 0)
			for (var _k = 0; _k < 3; _k++) {
				var _old = handle("preset" + string(_k), "");
				if (is_string(_old) && _old != "")
					array_push(g.autom.presets, { name : "mode " + string(array_length(g.autom.presets) + 1), pack : _old, offline : false });
			}
	}
	g.autom.oc        = handle("oc",        g.autom.oc);   // the overclock toggle (ram_oc)
	g.autom.strat        = handle("strat",     g.autom.strat);        // the dials' strategy (autom_order)
	g.autom.dial_all.on  = handle("da_on",     g.autom.dial_all.on);  // ...and its one row
	g.autom.dial_all.pct = handle("da_pct",    g.autom.dial_all.pct);
	g.autom.dial_all.t   = handle("da_t",      g.autom.dial_all.t);
	if (action == sv_load) {
		// every overclockable value snaps to its ladder (normal stops or
		// a notch), then the notches close if the toggle is off
		g.autom.upg.t    = ram_snap("timer", g.autom.upg.t);
		g.autom.tap.rate = ram_snap("tap",   g.autom.tap.rate);
		g.autom.run.spd  = ram_snap("speed", g.autom.run.spd);
		g.autom.fab.spd  = ram_snap("speed", g.autom.fab.spd);
		g.autom.am_speed = ram_snap("speed", g.autom.am_speed);
		g.autom.strat        = clamp(floor(g.autom.strat), 0, 4);
		g.autom.dial_all.pct = clamp(g.autom.dial_all.pct, 1, 100);
		g.autom.dial_all.t   = ram_snap("timer", g.autom.dial_all.t);
		// A SAVE FROM BEFORE THE MASTER ROW (autom_v absent): its per-dial
		// rows become the filter as they are, and NOBODY'S AUTOMATION
		// STOPS ON THE UPDATE - "a row per dial" with any row on becomes
		// the master on, robin, at the highest cap and the fastest timer
		// those rows had (read straight off the old keys; nothing writes
		// them any more). A save already on a strategy had a live master
		// row and flags the old code never read: every dial goes in
		if (floor(_av) < 2) {
			if (g.autom.strat == 0) {
				var _old_on = false, _old_pct = 0, _old_t = RAM_TIMER_MAX;
				var _op2 = string_split(ini_read_string(section, "dial_pct", ""), ",");
				var _ot2 = string_split(ini_read_string(section, "dial_auto_t", ""), ",");
				for (var _k = 0; _k < _an; _k++) {
					if (!g.autom.dial[_k].on) continue;
					_old_on = true;
					var _pk2 = (_k < array_length(_op2)) ? string_digits(_op2[_k]) : "";
					if (_pk2 != "") _old_pct = max(_old_pct, real(_pk2));
					var _tk = (_k < array_length(_ot2)) ? string_digits(_ot2[_k]) : "";
					if (_tk != "") _old_t = min(_old_t, real(_ot2[_k]));
				}
				if (_old_on) {
					g.autom.dial_all.on  = true;
					g.autom.dial_all.pct = clamp((_old_pct > 0) ? _old_pct : 50, 1, 100);
					g.autom.dial_all.t   = ram_snap("timer", _old_t);
				} else for (var _k = 0; _k < _an; _k++) g.autom.dial[_k].on = true;
			} else for (var _k = 0; _k < _an; _k++) g.autom.dial[_k].on = true;
		}
		if (g.autom.strat == 0) g.autom.strat = 3;
		if (!g.autom.oc) ram_oc_clamp();
	}

	if (action == sv_load) {
		g.autom.lock_pct  = clamp(g.autom.lock_pct, 0, 90);
		// the watermark is a packed arb, and a save written before it
		// existed reads whatever handle's default was. Heal by taking
		// the pile itself: a run already in progress has held at least
		// what it is holding, so the reserve starts honest rather than
		// at zero (which would have made the whole pile spendable on
		// the first load after the update).
		if (!(g.autom.lock_peak >= arb(1))) g.autom.lock_peak = 0;
		if (g.profit > g.autom.lock_peak)   g.autom.lock_peak = g.profit;
		g.autom.upg.pct   = clamp(g.autom.upg.pct,  1, 100);
		g.autom.upg.keep  = clamp(g.autom.upg.keep, 1, 100);
		g.autom.reb.t_min = max(1, g.autom.reb.t_min);
		g.autom.reb.u_min = max(1, g.autom.reb.u_min);
		g.autom.reb.g_pct = max(1, g.autom.reb.g_pct);
		g.autom.reb.p_oom = max(1, g.autom.reb.p_oom);
	}

	// ---- the time bank: the bank itself and the two purchase counts.
	// The cap and the rate DERIVE from those counts (timebank_cap /
	// timebank_rate), so a tuning change reaches saves that exist ----
	// ---- the battery: the charge, the two ladders, the offline rates.
	// Meta, like the time bank - a rebirth keeps it, a new game wipes it ----
	// ---- the sprites: one packed string, "name/col/pers/job/taps/fx/fy/
	// away/asleep" per sprite, "|"-joined. Meta: a rebirth keeps them ----
	section = "sprites";
	sprites_init();
	var _sps = "";
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		var _sp = g.sprites[_k];
		_sps += ((_k > 0) ? "|" : "") + _sp.name + "/" + string(_sp.col) + "/" + string(_sp.pers)
		      + "/" + _sp.job + "/" + string(_sp.taps) + "/" + string_format(_sp.fx, 1, 3)
		      + "/" + string_format(_sp.fy, 1, 3) + "/" + string(_sp.away) + "/" + (_sp.asleep ? "1" : "0")
		      + "/" + string(_sp[$ "eyes"] ?? 0) + "/" + string(_sp[$ "mat"] ?? 0) + "/" + string(_sp[$ "col2"] ?? _sp.col)
		      + "/" + string(_sp[$ "rar"] ?? 0);
		// the diary's memory (five fields; the planet name carries no "/" or "|")
		var _mm = is_struct(_sp[$ "mem"]) ? _sp.mem : { trips : 0, wins : 0, routs : 0, last : "", streak : 0 };
		_sps += "/" + string(_mm.trips) + "/" + string(_mm.wins) + "/" + string(_mm.routs) + "/" + _mm.last + "/" + string(_mm.streak);
		// THE SHEET (2026-09-14): class / level / xp / skill seed / worn / pocket,
		// six more fields (sprite_sheet_pack; items regenerate from their seeds)
		_sps += "/" + sprite_sheet_pack(_sp);
		// THE ID (2026-09-14, the inspection): bonds, trips in flight and the
		// `trip` flags are keyed by it - it must survive a load (field 25)
		_sps += "/" + string(_sp.id);
		// hp / mp at home, and the resting nap (2026-09-15; fields 26-28)
		_sps += "/" + string_format(_sp[$ "hpf"] ?? 1, 1, 3) + "/" + string_format(_sp[$ "mpf"] ?? 1, 1, 3) + "/" + ((_sp[$ "resting"] ?? false) ? "1" : "0");
	}
	_sps = handle("sprites", _sps);
	g.sprite_seq = handle("sprite_seq", g.sprite_seq);
	// THE XP LAW'S STAMP (2026-09-15): a save from an older law (or none)
	// has levels earned under the old need - every sheet goes back to
	// level 1 / 0 xp on load, gear and notes kept (his ask)
	var _law = handle("sprite_xp_law", (action == sv_load) ? 1 : SPRITE_XP_LAW);
	if (action == sv_load) {
		g.sprites = [];
		if (_sps != "") {
			var _pp = string_split(_sps, "|");
			for (var _k = 0; _k < array_length(_pp); _k++) {
				var _f = string_split(_pp[_k], "/");
				if (array_length(_f) < 9) continue;
				// THE TAIL, FROM THE END (his crash 2026-09-16: "unable to convert string '' to number" at field 26): the
				// sheet between the head and the tail GREW (notes, learned, elixirs, the title) while the id / hpf / mpf /
				// resting stayed read at 25..28 - the id read the learned skills, hpf the elixirs. The packer appends the
				// four LAST, so they are the last four; a save from before the naps (2026-09-15 morning) ends with the id
				// alone - told apart by its last field not being a 0/1 flag. An id already taken in this load is re-dealt
				// (the misread left every sprite at 0 in the saves between).
				var _nf = array_length(_f), _last = _f[_nf - 1];
				var _tail4 = (_nf >= 18 + 6 + 4 && (_last == "0" || _last == "1"));
				var _idf = _tail4 ? _f[_nf - 4] : ((_nf > 25) ? _f[_nf - 1] : "");
				var _hpf = _tail4 ? _f[_nf - 3] : "", _mpf = _tail4 ? _f[_nf - 2] : "", _rsf = _tail4 ? _last : "0";
				var _sid = (_idf != "" && string_digits(_idf) == _idf) ? real(_idf) : g.sprite_seq++;
				for (var _q = 0; _q < array_length(g.sprites); _q++) if (g.sprites[_q].id == _sid) { _sid = g.sprite_seq++; break; }
				g.sprite_seq = max(g.sprite_seq, _sid + 1);
				array_push(g.sprites, {
					id : _sid, name : _f[0], col : real(_f[1]), pers : real(_f[2]),
					job : _f[3], taps : real(_f[4]), fx : real(_f[5]), fy : real(_f[6]),
					away : real(_f[7]), asleep : (_f[8] == "1"), acc : 0,
					// the look (2026-09-11): a sprite saved before it had one is a matte dot-eyed one
					eyes : (array_length(_f) > 9)  ? real(_f[9])  : 0,
					mat  : (array_length(_f) > 10) ? real(_f[10]) : 0,
					col2 : (array_length(_f) > 11) ? real(_f[11]) : real(_f[1]),
					rar  : (array_length(_f) > 12) ? real(_f[12]) : 0,
					mem  : (array_length(_f) > 17)
						? { trips : real(_f[13]), wins : real(_f[14]), routs : real(_f[15]), last : _f[16], streak : real(_f[17]) }
						: { trips : 0, wins : 0, routs : 0, last : "", streak : 0 },
				});
				if (g.rarity_old) g.sprites[array_length(g.sprites) - 1].rar = rarity_remap8(g.sprites[array_length(g.sprites) - 1].rar);   // (DE's eight -> the fourteen)
				// the sheet, from field 18 on (a save from before: a fresh one, sprite_sheet)
				sprite_sheet_unpack(g.sprites[array_length(g.sprites) - 1], _f, 18);
				var _nsp = g.sprites[array_length(g.sprites) - 1];
				_nsp.hpf = (_hpf != "") ? clamp(real(_hpf), 0, 1) : 1;
				_nsp.mpf = (_mpf != "") ? clamp(real(_mpf), 0, 1) : 1;
				_nsp.resting = (_rsf == "1");
				if (real(_law) < SPRITE_XP_LAW) { var _rsh = sprite_sheet(g.sprites[array_length(g.sprites) - 1]); _rsh.lv = 1; _rsh.xp = 0; }
			}
		}
	}

	section = "exped";
	// THE GALAXY'S SEED first (2026-09-15): exped_init's board roll builds
	// the galaxy (ten thousand stars, a moment), so the save's seed must be
	// in before it - one generation a load, not two
	if (!variable_global_exists("galaxy_seed")) g.galaxy_seed = 1337;
	g.galaxy_seed = handle("ex_galaxy", g.galaxy_seed);
	if (action == sv_load) g.galaxy_seed = max(1, floor(g.galaxy_seed));
	exped_init();
	g.exped.depth  = handle("ex_depth",  g.exped.depth);
	// THE OWED SECONDS (q231): the trip clock's debt while the chart was not there (exped_tick) - kept across a close, so
	// a session shut before the chart landed still walks its minutes on the next boot
	g.exped_owed = handle("ex_owed", g[$ "exped_owed"] ?? 0);
	if (action == sv_load) g.exped_owed = max(0, real(g.exped_owed));
	// THE STAR MAP'S WORLDS (2026-09-16): star:pi|... - read before the board roll below rebuilds the board
	var _xww = "";
	if (is_array(g.exped[$ "worlds"])) for (var _i = 0; _i < array_length(g.exped.worlds); _i++) _xww += ((_i > 0) ? "|" : "") + string(g.exped.worlds[_i].star) + ":" + string(g.exped.worlds[_i].pl);
	_xww = handle("ex_worlds", _xww);
	if (action == sv_load) { g.exped.worlds = []; if (_xww != "") { var _wl = string_split(_xww, "|"); for (var _i = 0; _i < array_length(_wl); _i++) { var _wf = string_split(_wl[_i], ":"); if (array_length(_wf) == 2) array_push(g.exped.worlds, { star : real(_wf[0]), pl : real(_wf[1]) }); } } }
	g.exped.charms = handle("ex_charms", g.exped.charms);
	// THE EGGS (2026-09-16): col:seed:hatch:word:from (the word and the world scrubbed of the separators)
	var _xeg = "";
	if (is_array(g.exped[$ "eggs"])) for (var _i = 0; _i < array_length(g.exped.eggs); _i++) { var _eg = g.exped.eggs[_i]; _xeg += ((_i > 0) ? "|" : "") + string(_eg.col) + ":" + string(_eg.seed) + ":" + string(_eg.hatch) + ":" + string_replace_all(string_replace_all(_eg.word, "|", " "), ":", " ") + ":" + string_replace_all(string_replace_all(_eg.from, "|", " "), ":", " "); }
	_xeg = handle("ex_eggs", _xeg);
	if (action == sv_load) { g.exped.eggs = []; if (_xeg != "") { var _egl = string_split(_xeg, "|"); for (var _i = 0; _i < array_length(_egl); _i++) { var _eq = string_split(_egl[_i], ":"); if (array_length(_eq) >= 5) array_push(g.exped.eggs, { col : real(_eq[0]), seed : real(_eq[1]), hatch : real(_eq[2]), word : _eq[3], from : _eq[4] }); } } }
	g.exped.seq    = handle("ex_seq",    g.exped.seq);
	var _xm = "";
	var _xk = variable_struct_get_names(g.exped.mats);
	for (var _i = 0; _i < array_length(_xk); _i++)
		_xm += ((_i > 0) ? "|" : "") + _xk[_i] + "=" + string(g.exped.mats[$ _xk[_i]]);
	_xm = handle("ex_mats", _xm);
	var _xt = handle("ex_trip", exped_pack());
	// the bonds (exped_bond): "lo:hi=n|..." - forty-five pairs at most
	var _xb = "";
	var _bk = variable_struct_get_names(g.bonds);
	for (var _i = 0; _i < array_length(_bk); _i++)
		_xb += ((_i > 0) ? "|" : "") + _bk[_i] + "=" + string(g.bonds[$ _bk[_i]]);
	_xb = handle("ex_bonds", _xb);
	var _xr = handle("ex_retired", string_join_ext("|", g.exped.retired));
	// THE LEDGER (exped_stat) and the discovered set (2026-09-15)
	var _xs = "";
	var _stk = variable_struct_get_names(g.exped[$ "st"] ?? {});
	for (var _i = 0; _i < array_length(_stk); _i++)
		_xs += ((_i > 0) ? "|" : "") + _stk[_i] + "=" + string_format(g.exped.st[$ _stk[_i]], 1, 3);
	_xs = handle("ex_stats", _xs);
	var _xsn = "";
	var _seen = g.exped[$ "seen"] ?? [];
	for (var _i = 0; _i < array_length(_seen); _i++) _xsn += ((_i > 0) ? "|" : "") + _seen[_i];
	_xsn = handle("ex_seen", _xsn);
	// THE BESTIARY (2026-09-16): kind=seen:slain:vars,vars:boss|...
	var _xbt = "";
	var _bst = g.exped[$ "best"];
	if (is_struct(_bst)) {
		var _bkn = variable_struct_get_names(_bst);
		for (var _i = 0; _i < array_length(_bkn); _i++) { var _bv = _bst[$ _bkn[_i]]; _xbt += ((_i > 0) ? "|" : "") + _bkn[_i] + "=" + string(_bv.seen) + ":" + string(_bv.slain) + ":" + string_join_ext(",", _bv.vars) + ":" + string(_bv.boss) + ":" + string(_bv[$ "paid"] ?? 0); }   // (:paid - the hunt's last rung, 2026-09-16)
	}
	_xbt = handle("ex_best", _xbt);
	var _xbl = string_join_ext("|", g.exped[$ "blands"] ?? []);   // THE LANDS COMPLETE (bestiary_payout, 2026-09-16)
	_xbl = handle("ex_blands", _xbl);
	var _xof = handle("ex_offer", exped_offer_pack());   // THE QUEST BOARDS (2026-09-15)
	var _xmm = handle("ex_mem", exped_mem_pack());       // THE WORLD REMEMBERS (2026-09-16)
	var _xln = handle("ex_lanes", lane_pack());          // REGION LANES - the sum, not the list (q259)
	var _xst = handle("ex_seat", seat_pack());           // THE SEATS (q260)
	var _xsc = handle("ex_scars", scar_pack());          // THE SCARS (q260)
	var _xfc = handle("ex_fac", faction_pack());         // FACTION STRENGTH (q283)
	var _xpp = handle("ex_pop", pop_pack());             // POPULATION (q284)
	var _xnw = handle("ex_news", news_pack());           // THE NEWS (q285)
	var _xrv = handle("ex_regv", (action == sv_save) ? 4 : 1);   // THE REGION LAW'S VERSION (q287 / q288 / q306): 4 = the count by the ground, isles on islets, harbours; an older save drops what its regions held
	var _xvl = "";   // THE VILLAINS' THREADS (2026-09-16): key=stage|...
	if (is_struct(g.exped[$ "vil"])) { var _vkn = variable_struct_get_names(g.exped.vil); for (var _i = 0; _i < array_length(_vkn); _i++) _xvl += ((_i > 0) ? "|" : "") + _vkn[_i] + "=" + string(g.exped.vil[$ _vkn[_i]]); }
	_xvl = handle("ex_vil", _xvl);
	if (action == sv_load) {
		exped_offer_unpack(_xof);
		exped_mem_unpack(_xmm);
		lane_unpack(_xln);
		seat_unpack(_xst);
		scar_unpack(_xsc);
		faction_unpack(_xfc);
		pop_unpack(_xpp);
		news_unpack(_xnw);
		g.exped.vil = {};
		if (_xvl != "") { var _vl2 = string_split(_xvl, "|"); for (var _i = 0; _i < array_length(_vl2); _i++) { var _kv = string_split(_vl2[_i], "="); if (array_length(_kv) == 2) g.exped.vil[$ _kv[0]] = clamp(real(_kv[1]), 0, 3); } }
		g.exped.st = {};
		if (_xs != "") {
			var _sl = string_split(_xs, "|");
			for (var _i = 0; _i < array_length(_sl); _i++) {
				var _kv = string_split(_sl[_i], "=");
				if (array_length(_kv) == 2) g.exped.st[$ _kv[0]] = max(0, real(_kv[1]));
			}
		}
		g.exped.seen = (_xsn != "") ? string_split(_xsn, "|") : [];
		g.exped.blands = (_xbl != "") ? string_split(_xbl, "|") : [];
		g.exped.best = {};
		if (_xbt != "") {
			var _bl2 = string_split(_xbt, "|");
			for (var _i = 0; _i < array_length(_bl2); _i++) {
				var _kv = string_split(_bl2[_i], "=");
				if (array_length(_kv) != 2) continue;
				var _fv = string_split(_kv[1], ":");
				if (array_length(_fv) >= 4) g.exped.best[$ foe_legacy(_kv[0])] = { seen : max(0, real(_fv[0])), slain : max(0, real(_fv[1])), vars : (_fv[2] != "") ? string_split(_fv[2], ",") : [], boss : max(0, real(_fv[3])), paid : (array_length(_fv) >= 5) ? max(0, real(_fv[4])) : 0 };
			}
		}
		g.exped.depth  = clamp(floor(g.exped.depth), 1, 8);
		g.exped.charms = max(0, floor(g.exped.charms));
		g.exped.seq    = max(0, floor(g.exped.seq));
		g.bonds = {};
		if (_xb != "") {
			var _bl = string_split(_xb, "|");
			for (var _i = 0; _i < array_length(_bl); _i++) {
				var _kv = string_split(_bl[_i], "=");
				if (array_length(_kv) == 2) g.bonds[$ _kv[0]] = clamp(real(_kv[1]), 0, 100);
			}
		}
		g.exped.retired = (_xr != "") ? string_split(_xr, "|") : [];
		g.exped.mats = {};
		if (_xm != "") {
			var _xl = string_split(_xm, "|");
			for (var _i = 0; _i < array_length(_xl); _i++) {
				var _kv = string_split(_xl[_i], "=");
				if (array_length(_kv) == 2) g.exped.mats[$ _kv[0]] = real(_kv[1]);
			}
		}
		exped_unpack(_xt);
		if (_xrv < 4) exped_regions_reset();   // THE REGION BREAK (q287 / q288, his call): an older save's trips come home, its region records go
		exped_board_roll();
	}

	section = "ccore";
	ccore_init();
	g.ccore.lv        = handle("cc_lv",    g.ccore.lv);
	g.ccore.split     = handle("cc_split", g.ccore.split);
	g.ccore.xp        = handle("cc_xp",    g.ccore.xp);
	g.ccore.st        = handle("cc_st",    g.ccore.st);
	g.ccore.cool_from = handle("cc_cool",  g.ccore.cool_from);
	g.ccore.made      = handle("cc_made",  g.ccore[$ "made"] ?? 0);    // the well's lifetime
	g.ccore.pulls     = handle("cc_pulls", g.ccore[$ "pulls"] ?? 0);
	if (action == sv_load) {
		g.ccore.made  = max(0, floor(g.ccore.made));
		g.ccore.pulls = max(0, floor(g.ccore.pulls));
		g.ccore.lv    = max(0, floor(g.ccore.lv));
		g.ccore.split = clamp(round(g.ccore.split / 5) * 5, 0, 100);
		g.ccore.st    = clamp(floor(g.ccore.st), 0, 3);
		g.ccore.xp    = max(0, g.ccore.xp);
		if (g.ccore.lv <= 0) g.ccore.st = 0;
	}

	section = "battery";
	battery_init();
	g.battery.charge     = handle("bat_charge",  g.battery.charge);
	g.battery.cap_lv     = handle("bat_cap_lv",  g.battery.cap_lv);
	g.battery.rate_lv    = handle("bat_rate_lv", g.battery.rate_lv);
	g.battery.rate.run   = handle("bat_r_run",   g.battery.rate.run);
	g.battery.rate.fab   = handle("bat_r_fab",   g.battery.rate.fab);
	g.battery.rate.merge = handle("bat_r_merge", g.battery.rate.merge);
	if (action == sv_load) {
		g.battery.cap_lv     = max(0, floor(g.battery.cap_lv));
		g.battery.rate_lv    = max(0, floor(g.battery.rate_lv));
		g.battery.charge     = clamp(g.battery.charge, 0, battery_cap());
		g.battery.rate.run   = clamp(g.battery.rate.run,   5, 100);
		g.battery.rate.fab   = clamp(g.battery.rate.fab,   5, 100);
		g.battery.rate.merge = clamp(g.battery.rate.merge, 5, 100);
	}

	section = "timebank";
	timebank_init();
	g.timebank.bank    = handle("bank",    g.timebank.bank);
	g.timebank.cap_lv  = handle("cap_lv",  g.timebank.cap_lv);
	g.timebank.rate_lv = handle("rate_lv", g.timebank.rate_lv);
	g.timebank.spd     = handle("spd",     g.timebank.spd);
	if (action == sv_load) {
		g.timebank.cap_lv  = max(0, floor(g.timebank.cap_lv));
		g.timebank.rate_lv = max(0, floor(g.timebank.rate_lv));
		// a bank saved under a bigger cap must not survive a tune-down
		g.timebank.bank = clamp(g.timebank.bank, 0, timebank_cap());
		// 50, not 10: the speed row is [off x2 x4 x10 x50] (his set), and
		// a clamp written against the old ladder would silently demote
		// anyone who had saved on the top one
		g.timebank.spd  = clamp(floor(g.timebank.spd), 1, 50);
		g.timebank.live_m = 1;
	}

	// daily gift: the login calendar. FOUR numbers is the whole save -
	// claims (level/xp derive from it via gift_level), the board slot,
	// the cycle (the board re-rolls from it), the last collect's day
	section = "gift";
	gift_init();
	g.gift.claims   = handle("claims",   g.gift.claims);
	g.gift.pos      = handle("pos",      g.gift.pos);
	g.gift.cycle    = handle("cycle",    g.gift.cycle);
	g.gift.last_day = handle("last_day", g.gift.last_day);
	if (action == sv_load) {
		g.gift.claims = max(0, floor(g.gift.claims));
		g.gift.cycle  = max(0, floor(g.gift.cycle));
		g.gift.pos    = clamp(floor(g.gift.pos), 0, g.gift_cfg.days - 1);
	}

	// ---- scratch tickets (2026-09-13): the pile as "seed:rar:src|...",
	// the lifetime counts. A ticket mid-scratch saves unscratched (the
	// foil is session state) ----
	section = "tickets";
	ticket_init();
	var _tp = "";
	if (action == sv_save) {
		for (var _i = 0; _i < array_length(g.tickets.pile); _i++) {
			var _tk = g.tickets.pile[_i];
			_tp += ((_i > 0) ? "|" : "") + string(_tk.seed) + ":" + string(_tk.rar) + ":" + _tk.src;
		}
	}
	_tp = handle("pile", _tp);
	g.tickets.scratched = handle("scratched", g.tickets.scratched);
	g.tickets.won       = handle("won",       g.tickets.won);
	g.tickets.best      = handle("best",      g.tickets.best);
	g.tickets.best_txt  = handle("best_txt",  g.tickets.best_txt);
	g.tickets.seq       = handle("seq",       g.tickets.seq);
	// OWED (2026-09-17): tickets earned while the objective chain still
	// runs wait here, "src|src", and land when it completes (ticket_release)
	var _tow = "";
	if (action == sv_save && is_array(g.tickets[$ "owed"]))
		for (var _i = 0; _i < array_length(g.tickets.owed); _i++)
			_tow += ((_i > 0) ? "|" : "") + string(g.tickets.owed[_i]);
	_tow = handle("owed", _tow);
	if (action == sv_load) {
		g.tickets.owed = [];
		if (string(_tow) != "") g.tickets.owed = string_split(string(_tow), "|");
	}
	if (action == sv_load) {
		g.tickets.pile = [];
		if (string(_tp) != "") {
			var _tl = string_split(string(_tp), "|");
			for (var _i = 0; _i < array_length(_tl); _i++) {
				var _f = string_split(_tl[_i], ":");
				if (array_length(_f) < 3) continue;
				array_push(g.tickets.pile, { seed : floor(real(_f[0])), rar : clamp(floor(real(_f[1])), 0, 4),
					src : _f[2], cells : undefined, cleared : 0 });
			}
		}
		g.tickets.scratched = max(0, floor(g.tickets.scratched));
		g.tickets.won       = clamp(floor(g.tickets.won), 0, g.tickets.scratched);
		g.tickets.best      = clamp(floor(g.tickets.best), -1, 4);
		g.tickets.seq       = max(0, floor(g.tickets.seq));
	}

	// ---- the coin's tally (2026-09-13) ----
	section = "coin";
	coin_init();
	g.coin.flips  = handle("flips",  g.coin.flips);
	g.coin.heads  = handle("heads",  g.coin.heads);
	g.coin.tails  = handle("tails",  g.coin.tails);
	g.coin.streak = handle("streak", g.coin.streak);
	g.coin.best   = handle("best",   g.coin.best);
	g.coin.last   = handle("last",   g.coin.last);
	if (action == sv_load) {
		g.coin.flips = max(0, floor(g.coin.flips)); g.coin.heads = max(0, floor(g.coin.heads)); g.coin.tails = max(0, floor(g.coin.tails));
		g.coin.streak = max(0, floor(g.coin.streak)); g.coin.best = max(0, floor(g.coin.best)); g.coin.last = clamp(floor(g.coin.last), 0, 2);
	}

	// ---- THE ABILITY DECK (2026-09-13, with the real roster): every key's
	// state (-1 locked / 0 off / 1 on / 100 new) and the discovery seed;
	// the counts and the pool re-derive (fetch_new_ability) ----
	section = "abilities";
	if (!variable_global_exists("abi_keys")) create_new_deck();
	for (var _i = 0; _i < array_length(g.abi_keys); _i++) {
		var _k = g.abi_keys[_i];
		variable_global_set(_k, handle(_k, variable_global_get(_k)));
	}
	g.abi_seed = handle("abi_seed", g.abi_seed);
	if (action == sv_load) {
		for (var _i = 0; _i < array_length(g.abi_keys); _i++) {
			var _k = g.abi_keys[_i];
			var _v = floor(variable_global_get(_k));
			if (_v != -1 && _v != 0 && _v != 1 && _v != 100) _v = -1;
			variable_global_set(_k, _v);
		}
		g.abi_seed = floor(g.abi_seed) & $7fffffff;
		fetch_new_ability();   // the counts, the pool, the titles, the failsafes
	}

	// ---- the cheat shop (2026-09-13): the rows' percentages, as a list;
	// a load that no longer fits the cap (a tuned-down macro) lowers the
	// tallest rows until it does ----
	// AFTER THE ABILITIES (bug hunt, 2026-09-14): the row ceiling and the
	// points pool read the deck (Cheat Ceiling / Cheat Points), so a row
	// saved at 170 loaded before the deck was clamped to 120 by a deck
	// that was still reset. The deck loads first now
	section = "cheat";
	cheat_init();
	var _cv = "";
	if (action == sv_save) {
		for (var _i = 0; _i < array_length(g.cheat.v); _i++) _cv += ((_i > 0) ? "," : "") + string(g.cheat.v[_i]);
	}
	_cv = handle("v", _cv);
	if (action == sv_load) {
		var _cn = array_length(cheat_config().rows);
		g.cheat.v = array_create(_cn, 100);
		if (string(_cv) != "") {
			var _cp = string_split(string(_cv), ",");
			for (var _i = 0; _i < min(_cn, array_length(_cp)); _i++)
				g.cheat.v[_i] = clamp(round(real(_cp[_i]) / CHEAT_STEP) * CHEAT_STEP, CHEAT_ROW_MIN, CHEAT_ROW_MAX);
		}
		var _guard = 0;
		while (cheat_free() < 0 && _guard++ < 400) {
			var _top = 0;
			for (var _i = 1; _i < _cn; _i++) if (g.cheat.v[_i] > g.cheat.v[_top]) _top = _i;
			if (g.cheat.v[_top] <= CHEAT_ROW_MIN) break;
			g.cheat.v[_top] -= CHEAT_STEP;
		}
	}

	section = "upgrades";
	upgrade_init();
	g.upg.bought = handle("slots_bought", g.upg.bought);
	g.upg.total  = handle("total",        g.upg.total);
	g.upg.rolls  = handle("rolls",        g.upg.rolls);
	// THE UPGRADE LEVEL (2026-09-17, DE's upgrade_level / upgrade_xp)
	g.upg.level  = handle("level",        g.upg.level);
	g.upg.xp     = handle("xp",           g.upg.xp);
	if (action == sv_load) {
		g.upg.level = max(1, floor(real(g.upg.level)));
		g.upg.xp    = max(0, real(g.upg.xp));
	}
	// THE OFFER METER (2026-09-17, DE's uxp / utic / uhit / offline_upgrades)
	g.upg.meter.uxp  = handle("uxp",  g.upg.meter.uxp);
	g.upg.meter.utic = handle("utic", g.upg.meter.utic);
	g.upg.meter.uhit = handle("uhit", g.upg.meter.uhit);
	g.upg.meter.umax = handle("umax", g.upg.meter.umax);
	g.upg.meter.uoff = handle("uoff", g.upg.meter.uoff);
	if (action == sv_load) {
		g.upg.meter.uxp  = max(0, real(g.upg.meter.uxp));
		g.upg.meter.utic = max(0, real(g.upg.meter.utic));
		g.upg.meter.uhit = (real(g.upg.meter.uhit) > 0);
		g.upg.meter.umax = clamp(real(g.upg.meter.umax), 50, 100);
		g.upg.meter.uoff = clamp(floor(real(g.upg.meter.uoff)), 0, 6);
	}
	// the rarity histogram, one comma string - a short fixed-length
	// list has no business being one key per rung
	var _seen_txt = "";
	for (var _u = 0; _u < UPG_RARITY_N; _u++)
		_seen_txt += ((_u > 0) ? "," : "") + string(g.upg.seen[_u]);
	_seen_txt = handle("seen", _seen_txt);
	if (action == sv_load) {
		var _seen_p = string_split(_seen_txt, ",");
		for (var _u = 0; _u < UPG_RARITY_N; _u++) {
			// string_digits, not real(): a save edited by hand or a
			// widened ladder must read as zero, never as an error
			var _d = (_u < array_length(_seen_p)) ? string_digits(_seen_p[_u]) : "";
			g.upg.seen[_u] = (_d == "") ? 0 : floor(real(_d));
		}
		if (g.rarity_old) {   // the histogram's eight onto the fourteen
			var _s8 = array_create(8, 0);
			for (var _u = 0; _u < 8; _u++) _s8[_u] = g.upg.seen[_u];
			g.upg.seen = array_create(UPG_RARITY_N, 0);
			for (var _u = 0; _u < 8; _u++) g.upg.seen[rarity_remap8(_u)] += _s8[_u];
		}
	}
	// THE COMPLETED LEDGER, one string, one entry per ROSTER ID:
	// "id:sum:count|id:sum:count|...". Bounded by the roster however
	// long the account runs - see upgrade_init for the size argument
	// this shape exists to win. As a list it was ~26 bytes of savefile
	// per completed upgrade, all inside ONE ini value.
	var _done_txt = "";
	var _dk = variable_struct_get_names(g.upg.done);
	for (var _u = 0; _u < array_length(_dk); _u++) {
		var _dn = g.upg.done[$ _dk[_u]];
		if (!is_struct(_dn)) continue;
		_done_txt += ((_done_txt == "") ? "" : "|") + _dk[_u] + ":"
			+ string_format(_dn.sum, 1, 4) + ":" + string(_dn.n);
	}
	_done_txt = handle("done", _done_txt);
	if (action == sv_load) {
		g.upg.done = {};
		if (_done_txt != "") {
			var _dp = string_split(_done_txt, "|");
			for (var _u = 0; _u < array_length(_dp); _u++) {
				var _f = string_split(_dp[_u], ":");
				if (array_length(_f) < 3) continue;
				// an id the roster has retired drops out of the ledger
				// rather than taking the savefile with it - the same
				// rule the slots follow
				var _de = upgrade_entry(_f[0]);
				if (_de == -1) continue;

				// MIGRATION. The old shape was one entry per completed
				// upgrade - "id:rar:val:tier", four fields where this is
				// three. Each of those folds into its id's total as it
				// is read, so an existing save keeps every bonus it
				// earned and simply arrives in the smaller form.
				var _old = (array_length(_f) >= 4);
				var _sum = _old ? (real(_f[2]) * max(1, floor(real(_f[3]))))
				                : real(_f[1]);
				var _cnt = _old ? 1 : max(1, floor(real(_f[2])));

				var _cur = g.upg.done[$ _f[0]];
				if (!is_struct(_cur)) {
					_cur = { stat : _de.stat, sum : 0, n : 0 };
					g.upg.done[$ _f[0]] = _cur;
				}
				_cur.sum += _sum;
				_cur.n   += _cnt;
			}
		}
	}

	for (var _u = 0; _u < UPG_SLOT_MAX; _u++) {
		var _s = g.upg.slot[_u];
		var _has = is_struct(_s);
		var _id  = handle("u" + string(_u) + "_id",   _has ? _s.id   : "");
		var _rar = handle("u" + string(_u) + "_rar",  _has ? _s.rar  : 0);
		var _val = handle("u" + string(_u) + "_val",  _has ? _s.val  : 0);
		var _tir = handle("u" + string(_u) + "_tier", _has ? _s.tier : 0);
		// how deep the offer rolled - part of its identity, like the
		// rarity. 0 means "saved before offers had a depth"; upgrade_cap
		// reads that as absent and falls back to the old formula.
		var _cp  = handle("u" + string(_u) + "_cap",  _has ? (_s[$ "cap"] ?? 0) : 0);
		// a burst offer's clock (2026-09-16) - part of the roll, like the value
		var _du  = handle("u" + string(_u) + "_dur",  _has ? (_s[$ "dur"] ?? 0) : 0);
		// the level it was rolled at and DE's banked +1% (2026-09-17)
		var _lv  = handle("u" + string(_u) + "_lv",   _has ? (_s[$ "lv"] ?? 1) : 1);
		var _xtr = handle("u" + string(_u) + "_xtra", _has ? (_s[$ "xtra"] ?? 0) : 0);
		if (action == sv_load) {
			// an id the roster no longer carries costs a SLOT, never the
			// savefile - a retired upgrade must fail softly
			var _e = (_id == "") ? -1 : upgrade_entry(_id);
			if (g.rarity_old) _rar = rarity_remap8(_rar);
			g.upg.slot[_u] = (_e == -1) ? -1
				: { id : _id, stat : _e.stat, rar : _rar, val : _val,
				    cap : max(0, floor(_cp)), tier : max(0, floor(_tir)),
				    dur : max(0, floor(_du)), lv : max(1, floor(_lv)), xtra : max(0, _xtr) };
			// a zero cap is the pre-depth marker, and upgrade_cap only
			// recognises it as absent - so drop the field entirely
			if (is_struct(g.upg.slot[_u]) && g.upg.slot[_u].cap <= 0)
				variable_struct_remove(g.upg.slot[_u], "cap");
		}
	}
	// THE RUNNING BURSTS (2026-09-16): "kind:mult:until:dur|..." on the
	// wall clock - a burst bought before a save keeps its clock through
	// it, and what has run out by the load simply drops
	var _bt = "";
	if (is_array(g.upg[$ "bursts"])) for (var _u = 0; _u < array_length(g.upg.bursts); _u++) {
		var _bb = g.upg.bursts[_u];
		_bt += ((_bt == "") ? "" : "|") + _bb.kind + ":" + string_format(_bb.mult, 1, 4) + ":"
			+ string_format(_bb.ends, 1, 2) + ":" + string(round(_bb.dur));
	}
	_bt = handle("bursts", _bt);
	if (action == sv_load) {
		g.upg.bursts = [];
		if (_bt != "") {
			var _bp = string_split(_bt, "|");
			var _bnow = universal_now();
			for (var _u = 0; _u < array_length(_bp); _u++) {
				var _bf = string_split(_bp[_u], ":");
				if (array_length(_bf) < 4) continue;
				var _un = real(_bf[2]);
				if (_un <= _bnow) continue;
				array_push(g.upg.bursts, { kind : _bf[0], mult : real(_bf[1]), ends : _un, dur : max(1, real(_bf[3])) });
			}
		}
	}
	if (action == sv_load) {
		g.upg.bought = clamp(floor(g.upg.bought), 0, UPG_SLOT_MAX - UPG_SLOT_BASE);
		g.upg.total  = max(0, floor(g.upg.total));
		g.upg.rolls  = max(0, floor(g.upg.rolls));
		// THE THREE-SLOT TABLE (2026-09-16): a save from the eight-slot days
		// may hold offers past the visible range - they slide down into
		// free visible slots, the rest drop (upgrade_bonus walks every
		// index, so a hidden bought slot would keep paying invisibly)
		var _vis = upgrade_slots();
		for (var _u = _vis; _u < UPG_SLOT_MAX; _u++) {
			if (!is_struct(g.upg.slot[_u])) continue;
			var _to = -1;
			for (var _k = 0; _k < _vis; _k++) if (!is_struct(g.upg.slot[_k])) { _to = _k; break; }
			if (_to >= 0) g.upg.slot[_to] = g.upg.slot[_u];
			g.upg.slot[_u] = -1;
		}
	}

	// ---- dials: the LEVEL is the only owned number (every rate, cost
	// and payout derives from it via update_dials), plus the in-flight
	// cycle so a save never quietly refunds progress ----
	section = "dials";
	if (!variable_global_exists("dial")) create_dials();
	for (var _i = 0; _i < g.dial_total; _i++) {
		var _d = g.dial[_i];
		_d.level = handle("d" + string(_i) + "_lv",    _d.level);
		_d.cycle = handle("d" + string(_i) + "_cycle", _d.cycle);
		_d.auto  = handle("d" + string(_i) + "_auto",  _d.auto);
	}
	if (action == sv_load) {
		for (var _i = 0; _i < g.dial_total; _i++) {
			var _d = g.dial[_i];
			_d.level = max(0, floor(_d.level));
			_d.cycle = clamp(_d.cycle, 0, 1);
		}
		update_dials(); // THE resync: every derived number, then the tap
	}

	// ---- THE UNFOLD + THE OBJECTIVES load AFTER EVERYTHING THEY READ (bug
	// hunt, 2026-09-14): the catch-up for a save from before the chain
	// evaluates every step - dial levels, the table, the automation, the
	// credits - and those sections used to load after this one, so the
	// catch-up saw the reset run and stopped at the first objective ----
	section = "unfold";
	unfold_init();
	var _us = handle("unf_seen",   string_join_ext("|", variable_struct_get_names(g.unf.seen)));
	var _ud = handle("unf_done",   string_join_ext("|", variable_struct_get_names(g.unf.done)));
	var _uo = handle("unf_opened", string_join_ext("|", variable_struct_get_names(g.unf.opened)));
	var _uf = handle("unf_fresh",  string_join_ext("|", g.unf.fresh));
	var _uv = handle("unf_v", 1);   // the key that says "this save knows the unfold"
	if (action == sv_load) {
		g.unf.seen = {}; g.unf.done = {}; g.unf.opened = {}; g.unf.fresh = [];
		var _sl = (_us != "") ? string_split(_us, "|") : [];
		for (var _i = 0; _i < array_length(_sl); _i++) g.unf.seen[$ _sl[_i]] = true;
		var _dl = (_ud != "") ? string_split(_ud, "|") : [];
		for (var _i = 0; _i < array_length(_dl); _i++) g.unf.done[$ _dl[_i]] = true;
		var _ol = (_uo != "") ? string_split(_uo, "|") : [];
		for (var _i = 0; _i < array_length(_ol); _i++) g.unf.opened[$ _ol[_i]] = true;
		g.unf.fresh = (_uf != "") ? string_split(_uf, "|") : [];
		// a save from before the unfold: a dial owned and no unfold key
		// means a player who has been here - reveal everything, re-teach
		// nobody. (handle() reads the default, 1, when the key is absent;
		// the write above stores 1 too, so the tell is the seen list
		// being empty against a real run)
		// ...read STRAIGHT OFF THE FILE (bug hunt, 2026-09-14): the dials
		// section loads LAST, so g.dial[0].level here was whatever the run
		// in memory had - after the load's reset, zero - and this never fired
		var _d0lv = ini_read_real("dials", "d0_lv", 0);
		if (_us == "" && _d0lv > 0) unfold_reveal_all();
	}

	// ---- the objectives (his spec, 2026-09-13): where the chain stands ----
	section = "objectives";
	objective_init();
	var _oi = handle("obj_i",     g.obj.i);
	var _od = handle("obj_done",  string_join_ext("|", variable_struct_get_names(g.obj.done)));
	var _oa = handle("obj_act",   string_join_ext("|", variable_struct_get_names(g.obj.act)));
	if (action == sv_load) {
		var _was_all = (_us == "" && ini_read_real("dials", "d0_lv", 0) > 0);   // reveal_all ran above (the file's own level - see there)
		g.obj.i = max(0, floor(_oi)); g.obj.done = {}; g.obj.act = {}; g.obj.just = ""; g.obj.gap = 0;
		var _l1 = (_od != "") ? string_split(_od, "|") : [];
		for (var _i = 0; _i < array_length(_l1); _i++) g.obj.done[$ _l1[_i]] = true;
		// THE INDEX FOLLOWS THE KEYS (2026-09-14: the chain's order moved -
		// abilities now come after the second rebirth - and a saved index
		// would have pointed at the wrong objective). The chain is
		// sequential: the first objective not done is where it stands
		{
			var _oc = objective_config(), _k2 = 0;
			while (_k2 < array_length(_oc) && (g.obj.done[$ _oc[_k2].key] ?? false)) _k2++;
			g.obj.i = _k2;
		}
		var _l3 = (_oa != "") ? string_split(_oa, "|") : [];
		for (var _i = 0; _i < array_length(_l3); _i++) g.obj.act[$ _l3[_i]] = true;
		// a save that has played but never had objectives (no objective
		// ever ACTIVATED - the first activates on the first tick after the
		// veil - and a dial owned): catch up to where it stands - or, for
		// a save from before the unfold itself, the whole chain is done
		if (_oa == "" && _od == "" && ini_read_real("dials", "d0_lv", 0) > 0)
			objective_catchup(_was_all);
	}

	// pinned statistics (favorites) ride the save as a pipe-joined
	// path list; the tree itself derives live
	section = "statistics";
	// whether the per-row star gutter is drawn at all - part of the same
	// preference as which lines are pinned, so it rides with them
	if (!variable_global_exists("stats_fav_show")) g.stats_fav_show = false;
	g.stats_fav_show = handle("stats_fav_show", g.stats_fav_show);
	if (!variable_global_exists("stats_fav")) g.stats_fav = {};
	var _fav_keys = struct_get_names(g.stats_fav);
	var _fav_txt = "";
	for (var _i = 0; _i < array_length(_fav_keys); _i++)
		_fav_txt += ((_i > 0) ? "|" : "") + _fav_keys[_i];
	_fav_txt = handle("stats_fav", _fav_txt);
	if (action == sv_load) {
		g.stats_fav = {};
		var _fs = string_split(_fav_txt, "|", true);
		for (var _i = 0; _i < array_length(_fs); _i++)
			g.stats_fav[$ _fs[_i]] = true;
	}

	// THE DIMENSIONS (the antimatter-dimensions cascade, ported from the tech demo 2026-09-18; stand-alone). counts/dark matter are
	// LOG10 values now (the float era hit 1.8e308 and drowned in NaN -
	// keys renamed ldark/lc* so old float saves are simply ignored, the
	// pre-split "gold" precedent; no migration). `last` is the wall
	// clock stamp - saving it is what makes closed-game absence count:
	// the next dims_tick advances the exact closed form over the gap
	section = "dimensions";
	if (!variable_global_exists("dims")) dims_init();
	// format version: missing key = the float era (v1); v2 = log10 but
	// pre-balance (the 10-minute runaway). old versions are wiped
	// WHOLESALE below - counts/dark matter/bought are one coupled economy,
	// half-loading it strands the bench (bought-driven prices with no
	// dark matter to pay them). best survives a wipe (dims_init carries it)
	var _dims_v = handle("v", (action == sv_load) ? 1 : 3);
	g.dims.dark        = handle("ldark", g.dims.dark);
	g.dims.tick_bought = handle("tick", g.dims.tick_bought);
	g.dims.last        = handle("last", g.dims.last);
	g.dims.start       = handle("start", g.dims.start);
	g.dims.best        = handle("best", g.dims.best);
	g.dims.run         = handle("run", g.dims.run);
	g.dims.inf         = (handle("inf", g.dims.inf ? 1 : 0) == 1);
	for (var _i = 0; _i < g.dims.n; _i++) {
		g.dims.bought[_i] = handle("b" + string(_i), g.dims.bought[_i]);
		g.dims.count[_i]  = handle("lc" + string(_i), g.dims.count[_i]);
	}
	if (action == sv_load) {
		if (_dims_v < 3) dims_init(true); // stale-format save: fresh bench
		// and sanitize: a poisoned/hand-edited save (inf/NaN) must
		// never re-freeze the bench
		if (is_nan(g.dims.dark) || is_infinity(g.dims.dark))
			g.dims.dark = 1;
		for (var _i = 0; _i < g.dims.n; _i++)
			if (is_nan(g.dims.count[_i]) || is_infinity(g.dims.count[_i]))
				g.dims.count[_i] = g.dims.lz;
	}

	//////////////////////////////////////////////////////////////////
	ini_close();
	//////////////////////////////////////////////////////////////////


	// (the three debug prints that used to live here - filename_path,
	// game_save_id and a time_away readout - fired on EVERY write, so
	// once the autosave clock got a ladder they were a line a minute in
	// the console. The absence they measured is not measured here
	// anyway: syst_handle_save's Step hands the real span to
	// offline_replay right after this returns. Behind the debug flag if
	// they are ever wanted back.)
	if (system.debug) {
		show("saved > " + filename_path(file_to_handle));
		show("away  > " + crunch_time_long(
			date_second_span(last_datetime, date_current_datetime()) * 60));
	}

	// a load restarts the "session" as far as statistics deltas care
	if action = sv_load stats_session_base();
}
