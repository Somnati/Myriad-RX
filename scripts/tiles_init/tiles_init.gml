/// @description tiles_init() - the tile table's whole state, one struct.
/// idempotent: call it from anything that touches the table (the room
/// controller calls it in Create). everything lives under g.tiles and
/// the sim is pure scripts (tiles_merge / tiles_sort / tile_gps /
/// tile_color), so the framework is modular: no save hooks, no other
/// systems touched. to persist later, save g.tiles.tier + fab + stored
/// through handle_save and call tiles_init() before loading into it.
/// the Myriad lesson kept on purpose: the flat tier array IS the whole
/// game state (0 = empty slot) - controllers are just views over it.
/// _force = true rebuilds even when the struct exists (new game's
/// hard reset path)
function tiles_init(_force = false) {
	// the ENGINE rides along: a persistent singleton that ticks the
	// sim every step in every room (fabrication, automerge, gps total
	// all run globally - the Myriad behavior). lazy-spawned here so
	// including the framework anywhere is just "call tiles_init()"
	if (!instance_exists(syst_tiletimer)) create_obj(0, 0, syst_tiletimer);

	if (variable_global_exists("tiles") && is_struct(g.tiles) && !_force)
		return g.tiles;

	var _n = 16;
	g.tiles = {
		// board
		slots : _n,
		cols  : 4,
		tier  : array_create(_n, 0),

		// fabricator: fills over time, banks tiles while the board is
		// full, drains into the first free slot (Myriad base: 10s).
		// stored is HARD-capped: at the cap the fab timer sits full
		// and waits (Myriad's clamp) - production never evaporates
		fab        : 0,
		fab_t      : 60 * 10,
		stored     : 0,
		stored_max : 10,

		// auto-merge, timed the Myriad way: the merge interval is a
		// MULTIPLE of the fab interval (get_fab_time's tic_ = fab x1.5),
		// so fabrication upgrades speed both. am_tic_ is recomputed
		// every step by the controller
		automerge : false,
		am_tic    : 0,
		am_mult   : 1.5,
		am_tic_   : 60 * 15,

		// drop-aim anchor (round 2 toggle, his ask): false = drops land
		// where the MOUSE points (the classic feel), true = where the
		// held tile's own CENTER hovers (hands match eyes)
		aim_center : false,

		// power (round 3, his ask: tiles joined the allocation board).
		// alloc = the player's draw allocation 0..1 (saved); thr = the
		// live throttle power_tick writes (global squeeze x alloc) -
		// it scales FABRICATION speed; thr_avg = time-weighted throttle
		// over an offline replay window (power_dials_fastforward
		// computes it, tiles_fastforward consumes it)
		alloc   : 1,
		thr     : 1,
		thr_avg : 1,

		// the MERGER is its own powered machine (PM work order
		// 2026-07-12): while automerge is ON it draws bal.tiles_merge_
		// drain from the battery pool like a production machine - full
		// pull, independent of the fabricator's alloc slider (the toggle
		// IS its on/off switch). thr_am = the live throttle power_tick
		// writes back (0 while off); thr_am_avg = its time-weighted
		// offline twin. a starved pool slows the merge cadence exactly
		// like a starving machine - never a hard stop
		thr_am     : 1,
		thr_am_avg : 1,

		// bonus double-tier on merge (Myriad's merge_tierrate): the
		// base % chance, scaled live by g.rarity_rate in tiles_merge
		bonus_rate : 10,

		// deadlock failsafe clock: steps the board has sat full with
		// no legal merge (see syst_tiles - the lowest tile tiers up)
		searching : 0,

		// stats + change tracking. dirty = the board changed (engine
		// recomputes gps, then bumps rev); rev = what views watch to
		// rebuild their display caches
		merges  : 0,
		highest : 1,
		// lifetime fabricated. The away ledger counts a WINDOW and the
		// board only says what is on it right now, so neither could
		// answer "how many tiles has this account ever made" - which is
		// the one number a statistics screen is actually asked for.
		made    : 0,
		dirty   : true,
		rev     : 0,
		gps     : 0,

		// engine <-> view plumbing: the automerger's live candidate
		// pair, the view's held slot (engine leaves it alone), and an
		// event queue so glow/sounds only happen where a view drains
		// them (the table is silent from other rooms)
		am_ia : -1,
		am_ib : -1,
		grab  : -1,
		ev    : [],

		// offline: away-seconds cap and the welcome-back report the
		// view shows once (undefined = nothing to show)
		offline_cap : 60 * 60 * 8,
		report      : undefined,
	};

	// two starter tiles so the very first visit can drag-merge
	g.tiles.tier[0] = 1;
	g.tiles.tier[1] = 1;
	return g.tiles;
}
