	// MYRIAD RX boot (fresh foundation, 2026-08-14): the engine layer
	// only - currencies/systems arrive with the DE parity rebuild, and
	// each one adds its globals HERE as it lands (the techdemo's boot
	// chain is the reference, in the parts bin).

	// visual option globals: initialized here so rooms that READ them
	// never depend on the settings-room toggles having run first
	g.blur = false;
	g.save_dirty = false; // set by save_mark_dirty(), read by autosave

	// ---- the currency ----
	// PROFIT is the one currency: dials generate it, taps generate it,
	// dial levels are bought with it (Myriad DE calls it gold)
	g.profit       = 0;
	g.total_profit = 0;

	// run difficulty (new game overhaul): 0 easy / 1 standard /
	// 2 hard / 3 critical. picked in the new-game flow, stored on the
	// save - nothing reads it yet
	g.difficulty = 1;

	// ---- profiles ----
	// active profile index + a proc name and personal color per profile
	// (myriad style). fresh rolls every boot; a profile's FIRST save
	// stamps its rolls into the savefile, and the save menu syncs the
	// stored ones back, so saved identities stick across boots
	randomize();
	g.profile  = 0;
	g.playtime = 0; // seconds this save has been played, accumulated
	                // by syst_handle_save and stored per savefile
	for (var _i = 0; _i < 4; _i++) {
		g.profile_name[_i]  = gen_name_planet();
		g.profile_color[_i] = color_set_random();
	}

	// statistics session baseline: "session" deltas diff against this
	// boot's starting values (a save LOAD re-snapshots it)
	stats_session_base();

	// ---- dials + the tap ----
	// data only (g.dial structs + the clicker's globals); syst_production
	// ticks it, syst_dials is just a view. create_dials ends by deriving
	// everything, so the first frame is already correct.
	create_dials();

	// THE BUY MODE (Myriad DE's g.buy_lv): 1 / 10 / 100 / 1000 / "max"
	// ("next" joins when milestones land). Session-only in DE too - it
	// is never saved, a fresh boot is x1
	g.buy_lv = 1;

// ---- run gating (title screen, 2026-07-07): nothing plays until
// continue / new game flips this. the header menu checks it ----
g.game_started = false;
g.room_hist = [];
g.room_hist_skip = false;
