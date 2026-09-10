	// MYRIAD RX boot (fresh foundation, 2026-08-14): the engine layer
	// only - currencies/systems arrive with the DE parity rebuild, and
	// each one adds its globals HERE as it lands (the techdemo's boot
	// chain is the reference, in the parts bin).

	// visual option globals: initialized here so rooms that READ them
	// never depend on the settings-room toggles having run first
	g.blur = true;   // settings > display "menu blur"
	g.cursor_ray = true;   // settings > visuals "raycast pointer" (sh_cursor)
	g.motion_blur = true;  // settings > visuals "motion blur" (the puck's sweep, sh_puck)
	g.save_dirty = false; // set by save_mark_dirty(), read by autosave

	// ---- the currency ----
	// PROFIT is the one currency: dials generate it, taps generate it,
	// dial levels are bought with it (Myriad DE calls it gold)
	g.profit       = 0;
	g.total_profit = 0;
	// THE OFFLINE PILE (DE's global.offline_gold, ported 2026-09-10):
	// what an absence earned, held here until the button in the money
	// room is tapped - see obj_offlinegold. Saved with profit.
	g.offline_pool = 0;
	g.offline_pooling = false;   // true only inside offline_replay's replay

	// run difficulty (new game overhaul): 0 easy / 1 standard /
	// 2 hard / 3 critical. picked in the new-game flow, stored on the
	// save - nothing reads it yet
	g.difficulty = 1;
	// the new-game flow's other two answers (rm_newgame): three
	// personality picks, and whether the money room has UNFOLDED - 1 by
	// default so a save from before the veil existed is not veiled;
	// game_reset sets 0 and the first tap sets 1
	g.persona = [-1, -1, -1];
	g.unfold  = 1;

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
	g.tile_rarity_base = 0;
	g.tile_rarity   = TILE_RARITY_BASE;  // DE's base - see tile_rarity_rate
	g.rarity_rate   = 0;
	// two ability-deck flags the tech demo's tile code reads. Nothing
	// grants them yet; they are here so the ported code finds them
	// rather than dying at the first roll.
	g.ad_tilerarity = 0;   // +400 fabricator luck
	g.ad_hotswap    = 0;   // pick a tile straight off the board
	// no tiles_init() here on purpose: while TILES_LIVE is false the
	// table is lazy - syst_tiles' Create builds it when you open the
	// room, and until then the engine does not exist to tick
	if (TILES_LIVE) tiles_init();

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
	// ⚖️ +30 MINUTES A LEVEL (his call, 2026-09-10), not x1.5. Linear:
	// the tenth capacity buy adds what the first did. The geometric
	// version compounded to days inside a dozen levels, and a bank that
	// holds days is a bank nobody needs to think about.
	g.tb_cap_step  = 30;   // minutes of capacity a level

	// ⚖️ THE BANK PAYS FOR ITSELF (his call). Both upgrades cost BANKED
	// TIME, not profit, which makes the bank a currency with two uses:
	// spend it as speed now, or invest it in banking more later. That is
	// a real decision every time, where a profit price was just another
	// line on the profit sink pile.
	//
	// ⚖️ TWO LADDERS, EACH OFF ITS OWN LEVEL (his report, 2026-09-10:
	// "the costs seem shared"). They were: both fees read 80% of the
	// current capacity, so a rate level cost exactly what a capacity
	// level cost, and buying rate never moved the price of the next
	// rate level. Now a capacity level is priced off how many capacity
	// levels you hold, a rate level off how many rate levels, in MINUTES
	// of banked time, both linear like the cap:
	//   cap  fee = tb_cap_cost  + tb_cap_cost_step  x cap_lv
	//   rate fee = tb_rate_cost + tb_rate_cost_step x rate_lv
	// A capacity fee always fits the capacity it buys (20+15n under
	// 30+30n). A rate fee can outgrow a SMALL cap - the twentieth rate
	// level is 205 minutes, which needs cap_lv 6 to hold - and the row
	// then simply reads as unaffordable until the cap is raised. That
	// is the one coupling left, and it is the honest one: you cannot
	// bank what you cannot hold.
	g.tb_cap_cost       = 20;   // minutes, capacity level 0
	g.tb_cap_cost_step  = 15;   // more per capacity level held
	g.tb_rate_cost      = 15;   // minutes, rate level 0
	g.tb_rate_cost_step = 10;   // more per rate level held
	// The wall-clock price is what actually decelerates: cost/rate hours
	// of absence, with the cap geometric and the rate capped at 45 min
	// per hour. datafiles/timebank_twin.py walks it - run that first.
	timebank_init();

	create_dials();

	// ---- THE ABILITY DECK (techdemo II port, 2026-09-08) ----
	// ⚖️ A PLACEHOLDER, and deliberately an inert one (his words: "as a
	// placeholder until im ready"). The screen, the draft, the AP budget
	// and the card art all work; the ROSTER is still the techdemo's -
	// survey / fleet / colony / combat abilities for systems Myriad does
	// not have - so every ad_* flag it sets is currently read by nothing.
	// That is the point of landing it now: the six-touchpoint shape in
	// create_new_deck's header is what a Myriad roster gets written INTO,
	// and it is much easier to rewrite a roster than to port a framework.
	//
	// NOT SAVED YET, on purpose. handle_save has no "abilities" section,
	// so a deck resets every launch and abi_seed rolls fresh - which is
	// the right trade while the roster is going to be thrown away. The
	// section is one handle() block when the roster is real; until then a
	// save would only be persisting names that are about to change.
	create_new_deck();

	// THE BUY MODE (Myriad DE's g.buy_lv): 1 / 10 / 100 / 1000 / "max"
	// ("next" joins when milestones land). Session-only in DE too - it
	// is never saved, a fresh boot is x1
	g.buy_lv = 1;
	g.tile_buy_lv = 1;   // the tile drawer's own buy amount (tile_upg_bulk)
	// DE hid the "buy bulk" button until 3,000,000 lifetime profit. This
	// is that gate; 0 = always shown (his ask, 2026-09-03)
	g.buylv_unlock = 0;

// THE POINTER (his sprite). Seated once from here because setgame runs
// in the boot room before anything else; obj_cursor is persistent, so
// this is the only time it is ever created.
create_obj(0, 0, obj_cursor);

// ---- THE BOOT SOUND (his ask) ----
// A wood-and-metal cue, take one spliced out of the same six-take
// library file the continue sound came from.
//
// PLAYED FROM THE VERY END OF THIS EVENT, deliberately: settings_defaults
// and the saved settings both land above, so by here g.vol_sfx is real
// and the sound respects the player's own mix on the first frame rather
// than blaring at whatever the default happened to be. play_sound_ext
// guards for the global's absence anyway - this is about being right,
// not about not crashing.
//
// Quiet on purpose. The library masters these cues at a tenth of full
// scale and the import normalises to 0.85, so the asset is hot and the
// call has to take it back out (the same trim the continue sound needed
// after his report).
play_sound_ext(snd_boot, 1, 1, .25, 0);

// ---- run gating (title screen, 2026-07-07): nothing plays until
// continue / new game flips this. the header menu checks it ----
g.game_started = false;
g.room_hist = [];
g.room_hist_skip = false;
