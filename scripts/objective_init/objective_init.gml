/// @description objective_init([force]) - THE OBJECTIVES' state (his
/// spec, 2026-09-13). The chain is objective_config; this is where the
/// player is on it. Steps themselves are never stored: they are LIVE
/// (objective_step_done), so a step that stops holding unticks.
///   i      the index of the objective being worked (>= the chain's
///          length = every objective done)
///   done   key -> true once an objective completed (final)
///   act    key -> true once an objective became active
///   just   the key that completed this frame (the card celebrates it)
///   gap    seconds of THE BREATH left after a completion (OBJ_GAP):
///          the next objective is neither worked nor shown until it ends
/// Saved in section "objectives"; game_reset wipes it (force); a save
/// from before the objectives catches up (objective_catchup).
function objective_init(_force = false) {
	if (!_force && variable_global_exists("obj")) return;
	g.obj = { i : 0, done : {}, act : {}, just : "", gap : 0 };
}
