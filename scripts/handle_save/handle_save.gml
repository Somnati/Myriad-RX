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
	g.profit_lock  = handle("profit_lock",  g.profit_lock);
	g.upgrade_rarity = handle("upgrade_rarity", g.upgrade_rarity);
	g.profit       = handle("profit",       g.profit);
	g.total_profit = handle("total_profit", g.total_profit);
	if (action == sv_load) {
		g.profit       = do_floor(g.profit);
		g.total_profit = do_floor(g.total_profit);
		// the reserve is a PORTION of the pile, so it can never be more
		// than the pile - a save written before it existed reads 0, and
		// a hand-edited one heals here rather than at a spend site
		if (!(g.profit_lock >= arb(1))) g.profit_lock = 0;
		else if (g.profit_lock > g.profit) g.profit_lock = g.profit;
	}
	// LIFETIME TAP COUNTERS. These were derived at boot and never
	// written, so "lifetime taps" started at zero every launch - the
	// statistics screen was reporting a session figure under a lifetime
	// label. create_clicker still seeds them, and a load overwrites.
	g.total_taps  = handle("total_taps",  g.total_taps);
	g.total_crits = handle("total_crits", g.total_crits);
	if (action == sv_load) {
		g.total_taps  = max(0, floor(g.total_taps));
		g.total_crits = max(0, floor(g.total_crits));
	}

	// run difficulty (0 easy .. 3 critical), picked at new game.
	// stored only for now - future balance wiring reads it live
	g.difficulty = handle("difficulty", g.difficulty);

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
	if (action == sv_load) {
		g.rebirth.total = max(0, floor(g.rebirth.total));
		if (!(g.rebirth.units >= arb(1))) g.rebirth.units = 0;
		if (!(g.rebirth.prev_units >= arb(1))) g.rebirth.prev_units = 0;
	}

	// ---- history: the spark graphs, which are LIFETIME (his call) and
	// therefore have to outlive the session. A series is 120 reals and a
	// step, joined with pipes - 3 series is about 4KB of ini, which is
	// the whole price of a graph that reaches back months.
	// The buffer decimates itself (stats_hist_push), so this never grows
	// no matter how long the account runs. ----
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
		g.tiles.fab     = handle("fab",     g.tiles.fab);
		g.tiles.stored  = handle("stored",  g.tiles.stored);
		g.tiles.highest = handle("highest", g.tiles.highest);
		g.tiles.merges  = handle("merges",  g.tiles.merges);
		g.tiles.made    = handle("made",    g.tiles.made);
		g.tiles.shards  = handle("shards",  g.tiles.shards);
		g.tiles.earned  = handle("earned",  g.tiles.earned);
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
			var _tp = string_split(_tt, ",");
			for (var _k = 0; _k < g.tiles.slots; _k++) {
				var _d5 = (_k < array_length(_tp)) ? string_digits(_tp[_k]) : "";
				g.tiles.tier[_k] = (_d5 == "") ? 0 : max(0, floor(real(_d5)));
			}
			g.tiles.fab     = clamp(g.tiles.fab, 0, g.tiles.fab_t);
			g.tiles.stored  = clamp(floor(g.tiles.stored), 0, g.tiles.stored_max);
			g.tiles.highest = max(1, floor(g.tiles.highest));
			g.tiles.merges  = max(0, floor(g.tiles.merges));
			g.tiles.made    = max(0, floor(g.tiles.made));
			if (!(g.tiles.shards >= arb(1))) g.tiles.shards = 0;
			if (!(g.tiles.earned >= arb(1))) g.tiles.earned = 0;
			tiles_sync();   // the board takes the loaded levels' shape
		}
	}

	// ---- automation: PREFERENCES only. The q/h pacing ramps are
	// session state by design (autom_init) - a ramp is a guess about
	// the current wallet, and the wallet is not the same after a load ----
	section = "automation";
	autom_init();
	var _an = array_length(g.autom.dial);
	// one string for the toggles, one for the percentages: thirteen
	// dials is thirteen keys twice over otherwise
	var _aon = "", _apc = "";
	for (var _k = 0; _k < _an; _k++) {
		_aon += ((_k > 0) ? "," : "") + (g.autom.dial[_k].on ? "1" : "0");
		_apc += ((_k > 0) ? "," : "") + string(g.autom.dial[_k].pct);
	}
	_aon = handle("dial_on",  _aon);
	_apc = handle("dial_pct", _apc);
	if (action == sv_load) {
		var _p1 = string_split(_aon, ",");
		var _p2 = string_split(_apc, ",");
		for (var _k = 0; _k < _an; _k++) {
			g.autom.dial[_k].on = (_k < array_length(_p1)) && (_p1[_k] == "1");
			var _d2 = (_k < array_length(_p2)) ? string_digits(_p2[_k]) : "";
			g.autom.dial[_k].pct = (_d2 == "") ? 50 : clamp(real(_d2), 1, 100);
		}
	}
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
	g.autom.upg.buy   = handle("upg_buy",   g.autom.upg.buy);
	g.autom.upg.sell  = handle("upg_sell",  g.autom.upg.sell);
	g.autom.upg.pct   = handle("upg_pct",   g.autom.upg.pct);
	g.autom.upg.keep  = handle("upg_keep",  g.autom.upg.keep);
	g.autom.lock_pct  = handle("lock_pct",  g.autom.lock_pct);

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
		g.autom.upg.kind = {};
		if (_fk != "") {
			var _p4 = string_split(_fk, "|");
			for (var _k = 0; _k < array_length(_p4); _k++)
				if (_p4[_k] != "") g.autom.upg.kind[$ _p4[_k]] = false;
		}
	}
	if (action == sv_load) {
		g.autom.lock_pct  = clamp(g.autom.lock_pct, 0, 90);
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

	section = "upgrades";
	upgrade_init();
	g.upg.bought = handle("slots_bought", g.upg.bought);
	g.upg.total  = handle("total",        g.upg.total);
	g.upg.rolls  = handle("rolls",        g.upg.rolls);
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
		if (action == sv_load) {
			// an id the roster no longer carries costs a SLOT, never the
			// savefile - a retired upgrade must fail softly
			var _e = (_id == "") ? -1 : upgrade_entry(_id);
			g.upg.slot[_u] = (_e == -1) ? -1
				: { id : _id, stat : _e.stat, rar : _rar, val : _val,
				    cap : max(0, floor(_cp)), tier : max(0, floor(_tir)) };
			// a zero cap is the pre-depth marker, and upgrade_cap only
			// recognises it as absent - so drop the field entirely
			if (is_struct(g.upg.slot[_u]) && g.upg.slot[_u].cap <= 0)
				variable_struct_remove(g.upg.slot[_u], "cap");
		}
	}
	if (action == sv_load) {
		g.upg.bought = clamp(floor(g.upg.bought), 0, UPG_SLOT_MAX - UPG_SLOT_BASE);
		g.upg.total  = max(0, floor(g.upg.total));
		g.upg.rolls  = max(0, floor(g.upg.rolls));
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
