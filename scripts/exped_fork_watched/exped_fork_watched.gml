/// @description exped_fork_watched(trip) -> true when you are looking at this trip's page right now (the card waits for you; else the crew decides at once) (q258)
/// Never during the offline replay (g.offline_replaying), never with the
/// panel closing or on the sprite menu. The one reason a fork ever holds
/// the clock - and it holds it only EXPED_FORK_WINDOW wall seconds
function exped_fork_watched(_tr) {
	if (variable_global_exists("offline_replaying") && g.offline_replaying) return false;   // (offline_replay's flag - the replay decides every fork at once)
	if ((g[$ "exped_owed"] ?? 0) > 0) return false;   // (the owed hours paying back in slices: the same - a held fork would pay them back in one step; bug hunt q263)
	if (!instance_exists(syst_exped_panel)) return false;
	var _w = false;
	with (syst_exped_panel) {
		if (!closing && view == "trip" && mode != "sprites") { var _t = __trip(); _w = (_t == _tr); }
	}
	return _w;
}
