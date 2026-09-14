/// @description coin_init([force]) - the coin's tally (obj_coin): flips,
/// heads, tails, the current run of one side and the best. Saved in
/// "coin"; a new game clears it, a rebirth keeps it (a toy's record).
function coin_init(_force = false) {
	if (variable_global_exists("coin") && !_force) return;
	g.coin = { flips : 0, heads : 0, tails : 0, streak : 0, best : 0, last : 0 };
}
