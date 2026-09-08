/// @description timebank_init([force]);
/// @param [force]
/// THE TIME BANK's state (Techdemo II's, ported). His offline design,
/// and it is a HYBRID rather than a replacement: while you are away
/// production RUNS exactly as it always did (offline_replay), and the
/// bank accrues ON TOP. What the bank buys is not catch-up - it is
/// SPEED, spent live and deliberately, whenever you want it.
///   bank      banked SECONDS (a plain real; 30 days is 2.6m, fine)
///   cap_lv    capacity purchases  - timebank_cap derives from it
///   rate_lv   conversion purchases - timebank_rate derives from it
///   spd       the active multiplier (1/2/4/6/8/10; 1 = off)
///   live_m    this frame's GRANTED multiplier, set by timebank_spend
///   last_add / last_full   the latest conversion, for the away report
/// SURVIVES REBIRTH by rebirth_do never touching it - it is meta, like
/// credits and upgrades. A new game wipes it (game_reset). Save section
/// "timebank".
function timebank_init(_force = false) {
	if (variable_global_exists("timebank") && !_force) return;
	g.timebank = {
		bank      : 0,
		cap_lv    : 0,
		rate_lv   : 0,
		spd       : 1,
		live_m    : 1,
		last_add  : 0,
		last_full : false,
	};
}
