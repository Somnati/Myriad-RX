	// MYRIAD RX boot (fresh foundation, 2026-08-14): the engine layer
	// only - currencies/systems arrive with the DE parity rebuild, and
	// each one adds its globals HERE as it lands (the techdemo's boot
	// chain is the reference, in the parts bin).

	// visual option globals: initialized here so rooms that READ them
	// never depend on the settings-room toggles having run first
	g.blur = true;   // settings > display "menu blur"
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
	// TWO CLOCKS (2026-09-06, his ask - DE tracks both and the port kept
	// only half). They never overlap, so their SUM is the whole life of
	// the save:
	//   active   ticks in syst_handle_save's Step while the game runs
	//   offline  accrues in offline_replay, the one place an absence is
	//            measured (a suspend and a closed app both land there)
	// DE keeps ONE combined number (total_seconds_played: +1 a second
	// while running, + the away gap on load). RX splits it so "how long
	// have I actually played" and "how old is this save" are both
	// answerable. Anything wanting DE's figure adds them.
	g.time_played_active = 0; // seconds this save has been played, accumulated
	g.time_played_offline = 0; // seconds this save has spent away
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
	rebirth_init(); // the meta layer, before the dials derive from it
	// ---- DIAL MILESTONES (his spec, 2026-09-02) - THE TABLE, edit here ----
	// A dial that reaches a rung's level earns its bonus for good:
	// "speed" = its cycle runs mult times faster, "profit" = every
	// cycle pays mult times more. Bonuses derive from the level
	// (milestone_get), so nothing here is saved.
	// THE PREMIUM: the one level that crosses a rung costs
	// milestone_cost_mult times its normal price (level 24 -> 25 at
	// ten times what dial_cost would otherwise charge for it).
	g.milestone_cost_mult = 10;
	g.milestones = [
		{ level : 25,  kind : "speed",  mult : 2 },
		{ level : 50,  kind : "profit", mult : 2 },
		{ level : 75,  kind : "profit", mult : 2 },
		{ level : 100, kind : "speed",  mult : 2 },
	];

	// ---- CREDITS (the second currency; Myriad DE's dropper) - THE KNOBS ----
	// a pool refills over time; every tap has a chance to pull a few
	// credits out of it. credit_tick / credit_drop read these live.
	g.credit_cap        = 7;    // the pool's ceiling
	g.credit_refill     = 12;   // credits per HOUR into the pool
	g.credit_maxpull    = 3;    // the most one drop can pay
	g.credit_tap_chance = 2;    // percent chance per tap
	g.credit_cool_min   = 5;    // seconds between drops, rolled in
	g.credit_cool_max   = 8;    //   this range (halved one time in ten)
	// ---- THE TILE TABLE (Techdemo II's, ported whole) ----
	// tile_rarity is the fabricator's luck: every fabricated tile rolls
	// its tier through calculate_rarity with this as the rate, so
	// raising it slides the whole tier window up. rarity_rate is the
	// general-purpose one the same engine reads for anything else.
	// the fabricator's BASE luck. tiles_sync adds the alloy-quality
	// upgrade on top and writes the total into g.tile_rarity, so this is
	// the seat any future modifier feeds rather than the live value.
	g.tile_luck_base = 0;
	g.tile_rarity   = 0;
	g.rarity_rate   = 0;
	// two ability-deck flags the tech demo's tile code reads. Nothing
	// grants them yet; they are here so the ported code finds them
	// rather than dying at the first roll.
	g.ad_tilerarity = 0;   // +400 fabricator luck
	g.ad_hotswap    = 0;   // pick a tile straight off the board
	tiles_init();

	credits_init();

	// ---- THE TIME BANK (Techdemo II's, ported) ----
	// away time banks ON TOP of production and is spent live as speed.
	// The invariant these numbers must respect: banked minutes per real
	// hour stay under 60, so the rate and its ceiling are both minutes
	// per hour and timebank_rate hard-clamps at 55 regardless.
	// TUNED IN datafiles/timebank_twin.py - run it before touching these.
	// The two knobs are COMPLEMENTS: rate decides how fast an absence
	// banks, cap decides how much of it survives, and a purchase of
	// either is only worth anything while the OTHER one is the binder.
	// The twin's invariant 7 walks a real absence pattern and refuses a
	// pairing where one of them is ever a dead buy.
	g.tb_rate      = 5;    // minutes banked per hour away, at rate_lv 0
	g.tb_rate_step = 2;    // per rate purchase
	// 45, not 40: 5 + 2n hits 45 exactly and skips over 40, so a 40
	// ceiling was one the ladder could never actually reach (it stopped
	// at 39 and the last level bought nothing).
	g.tb_rate_cap  = 45;   // the tuned ceiling (a hard 55 sits above it)
	// 30, not 60: at the base rate a 60-minute cap does not clip until
	// TWELVE HOURS away, so the first capacity purchase bought nothing
	// at all for anyone whose sessions are a normal day apart. At 30 it
	// binds on an overnight, which is what makes it a purchase.
	g.tb_cap       = 30;   // bank capacity in MINUTES, at cap_lv 0

	// ⚖️ THE BANK PAYS FOR ITSELF (his call). Both upgrades cost BANKED
	// TIME, not profit, which makes the bank a currency with two uses:
	// spend it as speed now, or invest it in banking more later. That is
	// a real decision every time, where a profit price was just another
	// line on the profit sink pile.
	//
	// AND IT FORCES THE COST CURVE'S SHAPE. You can never hold more than
	// the cap, so any price above it is a price you can never save for -
	// a geometric cost against a linear cap would have gone unbuyable
	// two or three levels in. So both prices are a FRACTION OF THE
	// CURRENT CAP, always affordable with a full bank and never with
	// much less, and it is the CAP that grows geometrically instead.
	g.tb_cap_mult  = 150;  // percent: capacity x1.5 a level
	// ⚖️ THE TWO FEES ARE EQUAL, and that is a fix rather than laziness.
	// Both are priced off the same capacity, so a cheaper one is
	// cheaper at EVERY level - and the twin's invariant 7 showed a
	// player following the cheaper price buying capacity fourteen times
	// running while the rate stayed the binder and the bank never moved.
	// A price that is always lower on the option that is usually wrong
	// is a trap, not a choice. Equal fees put the decision back where it
	// belongs: which of the two is actually limiting you, which the
	// screen now says on the rows.
	g.tb_cap_cost  = 80;   // a capacity level costs 80% of current capacity
	g.tb_rate_cost = 80;   // and so does a rate level
	// The wall-clock price is what actually decelerates: cost/rate hours
	// of absence, with the cap geometric and the rate capped at 45 min
	// per hour. datafiles/timebank_twin.py walks it - run that first.
	timebank_init();

	create_dials();

	// THE BUY MODE (Myriad DE's g.buy_lv): 1 / 10 / 100 / 1000 / "max"
	// ("next" joins when milestones land). Session-only in DE too - it
	// is never saved, a fresh boot is x1
	g.buy_lv = 1;
	// DE hid the "buy bulk" button until 3,000,000 lifetime profit. This
	// is that gate; 0 = always shown (his ask, 2026-09-03)
	g.buylv_unlock = 0;

// ---- run gating (title screen, 2026-07-07): nothing plays until
// continue / new game flips this. the header menu checks it ----
g.game_started = false;
g.room_hist = [];
g.room_hist_skip = false;
