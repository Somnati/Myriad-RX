/// @description exped_stat(key, [n]) - the expeditions' LEDGER (his ask,
/// 2026-09-15: "a statistic in the stats for expeditions"): g.exped.st,
/// one counter a key, added to at the moment it happens; saved as
/// "ex_stats" (handle_save). The keys, and where they count:
///   trips       exped_start          hauls      exped_collect
///   quests      home, a quest done   aborted    exped_abort
///   fights_won / fights_lost / slain / downs     a fight's end (exped_tick_one)
///   routs       a rout               levels     exped_xp_grant
///   road_h / flight_h / world_h / explore_h     hours (exped_agent, exped_tick_one)
///   delves      a delve walked through (exped_act_step)   camps   a camp's chest
///   inns / taverns / bought / bounties / finds / gear_found / met / beats
///   credits     credits collected from hauls (exped_collect)
///   recruits    a found sprite kept
/// Regions and worlds DISCOVERED are a set, g.exped.seen ("seed:ri"),
/// kept at the landing (exped_tick_one); the stats folder counts it.
function exped_stat(_key, _n = 1) {
	exped_init();
	var _e = g.exped;
	if (!is_struct(_e[$ "st"])) _e.st = {};
	_e.st[$ _key] = (_e.st[$ _key] ?? 0) + _n;
}
