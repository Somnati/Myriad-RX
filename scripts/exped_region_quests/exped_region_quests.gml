/// @description exped_region_quests(dest, [ri]) -> the three quests the region offers, all different
/// Rolled off the region and the board's deal (exped_quest_gen with a salt
/// each), so they hold still while you look and re-deal when a trip
/// leaves (g.exped.seq moves). A roll that repeats an earlier one (same
/// kind, same place, same foe) is re-rolled with the next salt (his
/// report: "the same quest generated twice"). Cached per (seed, ri, seq).
function exped_region_quests(_d, _ri = 0) {
	if (!variable_global_exists("exped_qcache")) g.exped_qcache = { key : "", list : [] };
	var _k = string(_d.seed) + ":" + string(_ri) + ":" + string(g.exped.seq);
	if (g.exped_qcache.key == _k) return g.exped_qcache.list;
	var _l = [], _sigs = [];
	var _salt = 0;
	while (array_length(_l) < 3 && _salt < 12) {
		var _q = exped_quest_gen(_d, _salt, _ri);
		_salt += 1;
		var _sig = _q.kind + ":" + string(_q.node) + ":" + _q.foe;
		if (array_contains(_sigs, _sig)) continue;
		array_push(_sigs, _sig);
		array_push(_l, _q);
	}
	g.exped_qcache = { key : _k, list : _l };
	return _l;
}
