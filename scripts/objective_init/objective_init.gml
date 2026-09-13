/// @description objective_init([force]) - THE OBJECTIVES' state (his
/// spec, 2026-09-13). The chain is objective_config; this is where the
/// player is on it.
///   i      the index of the objective being worked (>= the chain's
///          length = every objective done)
///   done   key -> true once an objective completed
///   flags  what the game has SEEN (drawer1 / drawer2 / menu / the
///          panels' opens) and each step's own sticky done mark
///          ("key:i") - a step ticked stays ticked, so "gather 100
///          profit" does not untick when the hundred is spent
///   act    key -> true once an objective became active (its step 0
///          unlocks and the card's arrival happen once)
///   just   the key that completed this frame (the card celebrates it)
/// Saved in section "objectives"; game_reset wipes it (force); a save
/// from before the objectives catches up (objective_catchup).
function objective_init(_force = false) {
	if (!_force && variable_global_exists("obj")) return;
	g.obj = { i : 0, done : {}, flags : {}, act : {}, just : "" };
}
