/// @description ccore_init([force]) - THE CREDIT CORE's state, and
/// the only thing a save stores about it: the level, the split, what
/// is in the well, the state. Everything else derives (ccore_values).
///   lv     levels bought (credits, ccore_cost); 0 = not yet unlocked
///   split  0..100, the share of the levels that go to CAPACITY; the
///          rest go to RATE (DE's credit_core_lerp slider)
///   xp     credits in the well (producing / full), or the cooldown's
///          countdown (cooling)
///   st     0 locked, 1 producing, 2 full, 3 cooling
///   cool_from  where the cooldown started (its bar reads xp / this)
///   made   credits ever drawn from the well (lifetime; the panel and
///          statistics show it) - and pulls, how many collects
/// SURVIVES REBIRTH (credits are the presence layer, with the upgrades
/// and the battery); game_reset wipes it with force.
function ccore_init(_force = false) {
	if (!_force && variable_global_exists("ccore")) return;
	g.ccore = { lv : 0, split : 50, xp : 0, st : 0, cool_from : 100, made : 0, pulls : 0 };
}
