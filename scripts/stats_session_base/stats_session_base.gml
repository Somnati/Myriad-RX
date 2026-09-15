/// @description stats_session_base() - snapshot the "session zero"
/// values that the statistics session-view diffs against. called at
/// boot (setgame) and again whenever a save LOADS, so "session" always
/// means "since this run started". arb-packed values (resin, profit,
/// units) are plain reals, so a straight copy is a real snapshot.
function stats_session_base() {
	g.stats_base = {
		playtime : variable_global_exists("time_played_active") ? g.time_played_active : 0,
		playtime_off : variable_global_exists("time_played_offline") ? g.time_played_offline : 0,
		resin    : variable_global_exists("resin")    ? g.resin    : 0,
		profit   : variable_global_exists("profit")   ? g.profit   : 0,
		units    : variable_global_exists("units")    ? g.units    : 0,
		merges   : variable_global_exists("tiles")    ? g.tiles.merges : 0,
		taps     : variable_global_exists("total_taps")  ? g.total_taps  : 0,
		crits    : variable_global_exists("total_crits") ? g.total_crits : 0,
		// the expeditions' ledger, whole (exped_stat's keys; the folder diffs each)
		exped    : (variable_global_exists("exped") && is_struct(g.exped[$ "st"])) ? variable_clone(g.exped.st) : {},
	};
}
