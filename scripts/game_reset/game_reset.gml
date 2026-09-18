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
	g.offline_pool  = 0;   // an uncollected pile belongs to the run it came from
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
	ticket_init(true);  // the scratch tickets: a new game clears the desk
	cheat_init(true);   // the cheat shop: every row back to 100
	coin_init(true);    // the coin's tally
	create_new_deck();  // the ability deck: every key locked, a fresh discovery seed
	gift_init(true);     // the login calendar starts over with a new game
	battery_init(true);
	ccore_init(true);
	exped_init(true);  // the offline budget: same rule as the bank
	sprites_init(true);  // the helpers: meta, a new game starts without them
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
	g.difficulty = clamp(floor(_diff), 0, 4);   // 4 = custom (nothing reads it yet)
	// the three personality answers (rm_newgame) and THE VEIL: a fresh
	// run opens on black and unfolds on the first tap (syst_unfold)
	g.persona = [-1, -1, -1];
	g.unfold  = 0;
	unfold_init(true);   // and nothing has arrived yet (the unfold)
	objective_init(true); // the chain starts at its first objective

	// THE DIMENSIONS (q223): dims_init deliberately carries `best` across
	// big crunches - a NEW GAME wipes even that, so unstruct it first
	// (the port missed this line; found on the bug hunt)
	if (variable_global_exists("dims")) g.dims = 0;
	dims_init(true);

	// pinned statistics live on the save: fresh run, fresh pins
	g.stats_fav = {};

	// THE ABSENCE THAT IS NOT OURS (his report, 2026-09-13: a new game
	// showed the other profile's offline log): boot loads the active
	// profile and replays its absence, queueing a welcome card the money
	// room has not shown yet. A new game on another profile then walked
	// in under it. The pending report and the session's log both belong
	// to the run that was loaded - drop them with it
	if (variable_global_exists("offline_report")) g.offline_report.shown = true;
	offlog_init(true);

	// stats "session" deltas re-baseline at zero
	stats_session_base();
	g.save_dirty = false;
}
