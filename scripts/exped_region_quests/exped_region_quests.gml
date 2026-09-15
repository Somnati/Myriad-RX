/// @description exped_region_quests(dest) -> the three quests the region offers
/// Rolled off the world and the board's deal (exped_quest_gen with a salt
/// each), so they hold still while you look and re-deal when a trip
/// leaves (g.exped.seq moves). Cached per (seed, seq).
function exped_region_quests(_d) {
	if (!variable_global_exists("exped_qcache")) g.exped_qcache = { key : "", list : [] };
	var _k = string(_d.seed) + ":" + string(g.exped.seq);
	if (g.exped_qcache.key == _k) return g.exped_qcache.list;
	var _l = [];
	for (var _i = 0; _i < 3; _i++) array_push(_l, exped_quest_gen(_d, _i));
	g.exped_qcache = { key : _k, list : _l };
	return _l;
}
