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
	g.profit       = handle("profit",       g.profit);
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
