/// @description unfold_reveal_all() - every feature seen, every nudge
/// done: a save from before the unfold, or a player who has clearly
/// been here (game_reset does NOT call this - a new game starts black)
function unfold_reveal_all() {
	unfold_init();
	var _c = unfold_config();
	for (var _i = 0; _i < array_length(_c); _i++) g.unf.seen[$ _c[_i].key] = true;
	var _n = nudge_config();
	for (var _i = 0; _i < array_length(_n); _i++) g.unf.done[$ _n[_i].key] = true;
	g.unf.fresh = [];
	if (variable_global_exists("unfold")) g.unfold = 1;
}
