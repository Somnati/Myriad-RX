/// @description coll_init([force]) -> g.coll: THE COLLIDER's state (q319) - matter + antimatter cascades (cas_new), energy (LOG10), the field / auto / yield levels, the collide pct, the run clock + the wall; best time and the crunch count SURVIVE a force (the score and the residue: every crunch shaves the tier cost steps - coll_stepk)
function coll_init(_force = false) {
	if (!_force && variable_global_exists("coll") && is_struct(g.coll)) return g.coll;
	var _best = -1, _crunch = 0, _pairs = COLL_LZ, _pct = 50;
	if (variable_global_exists("coll") && is_struct(g.coll)) { _best = g.coll[$ "best"] ?? -1; _crunch = g.coll[$ "crunches"] ?? 0; _pairs = g.coll[$ "pairs_lg"] ?? COLL_LZ; _pct = g.coll[$ "pct"] ?? 50; }
	var _now = universal_now();
	g.coll = {
		m : cas_new(), a : cas_new(),
		energy : COLL_LZ, field : 0, auto_lv : 0, magnet_lv : 0, pct : _pct, auto_t : 0,
		last : _now, start : _now, inf : false, run : -1,
		best : _best, crunches : _crunch, pairs_lg : _pairs, collisions : 0,
	};
	return g.coll;
}
