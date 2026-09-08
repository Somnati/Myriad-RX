/// @description game_reset(difficulty);
/// @param difficulty 0 easy / 1 standard / 2 hard / 3 critical
/// the ONE fresh-run reset (new game overhaul, 2026-07-10): rebuilds
/// every mechanic's in-memory state exactly like a clean boot, WITHOUT
/// game_restart - new game must never nuke the session, the settings,
/// or the other profiles (his ask). does NOT touch files or g.profile:
/// the caller (obj_save_menu's new-game flow) owns slot choice,
/// deletion and the first save.
/// MYRIAD RX (fresh foundation, 2026-08-14): stripped to the engine -
/// each DE system rebuilt onto RX adds its own _force reset HERE as it
/// lands (the techdemo's version is the shape reference: lazy-init
/// guards leak old-run state into a "new" game unless a _force param
/// punches through).
function game_reset(_diff = 1) {

	// run scalars (setgame's fresh values)
	g.time_played_active     = 0;
	g.time_played_offline    = 0;
	g.profit        = 0;
	g.total_profit  = 0;
	g.profit_flight = 0;

	// dials + the tap: create_dials hard-resets the whole layer and
	// re-derives it (levels, cycles, the tap's own power)
	rebirth_init(true); // a NEW GAME wipes the bank; a rebirth never does
	// only reset what exists: while TILES_LIVE is false the table is
	// lazy, and building one here just to wipe it would spawn the
	// engine into every room of a fresh game
	if (variable_global_exists("tiles")) tiles_init(true);
	if (variable_global_exists("away"))  away_init(true);
	autom_init(true);    // preferences: a new game forgets them, a
	                     // rebirth does not
	timebank_init(true); // meta, like the credits: rebirth keeps it, a
	                     // new game does not
	credits_init(true); // and the credits (DE: they survive rebirth, not a new game)
	upgrade_init(true); // the upgrades ride with the credits - the same
	                    // PRESENCE layer, wiped by a new game and never
	                    // by a rebirth
	// the lifetime graphs belong to the ACCOUNT, so a new game starts
	// them over - and a rebirth deliberately does not, because a rebirth
	// cliff is the most interesting thing on the profit line
	g.stats_hist = {};
	g.hist_meta  = {};
	create_dials(true);
	g.buy_lv = 1; // DE resets the buy mode with the run

	// difficulty: chosen at new game, stored on the save. nothing
	// reads it yet - when it goes live, scale balance knobs off it at
	// read time (never bake it into stored numbers)
	g.difficulty = clamp(floor(_diff), 0, 3);

	// pinned statistics live on the save: fresh run, fresh pins
	g.stats_fav = {};

	// stats "session" deltas re-baseline at zero
	stats_session_base();
	g.save_dirty = false;
}
