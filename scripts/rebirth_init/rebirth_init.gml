/// @description rebirth_init([force]) - the rebirth META, the layer
/// that outlives every run (Myriad DE's units / total_units /
/// total_rebirths globals, gathered into one struct). Lazy: every
/// reader may call it, the first one pays. force = true is the
/// new-game wipe (game_reset); a REBIRTH never calls it - the bank
/// is exactly what a rebirth keeps.
///   units       the bank, a packed arb once it holds anything
///               (plain 0 while empty - never do_add onto arb(0))
///   total       rebirths so far (seeds the flavor names, gates the
///               first-rebirth timeclamp exemption)
///   run_pt0     g.playtime when this run began - the run clock is
///               g.playtime - run_pt0, so lifetime playtime survives
///   prev_*      the last run's report card for the overlay footer
function rebirth_init(_force = false) {
	if (variable_global_exists("rebirth") && !_force) return;
	g.rebirth = {
		units       : 0,
		total       : 0,
		run_pt0     : 0,
		prev_units  : 0,
		prev_secs   : 0,
		prev_profit : 0,
	};
}
