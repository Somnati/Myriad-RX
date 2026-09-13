/// @description unfold_reveal_all() - every feature seen, every
/// objective done: a save from before the unfold, a player who has
/// clearly been here (game_reset does NOT call this - a new game starts
/// black). The keys: the time-gated rows AND everything the objectives
/// grant (objective_catchup(true) walks the chain granting quietly).
function unfold_reveal_all() {
	unfold_init();
	var _c = unfold_config();
	for (var _i = 0; _i < array_length(_c); _i++) g.unf.seen[$ _c[_i].key] = true;
	objective_catchup(true);
	g.unf.fresh = [];
	if (variable_global_exists("unfold")) g.unfold = 1;
}
