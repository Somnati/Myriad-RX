/// @description send_ability(key, var, [req]) - one ability's
/// discovery eligibility. counts toward the collection totals, and
/// if still locked (and its prerequisite is discovered) its key
/// enters the pool. req: 0 = none, else pass the parent's g.ad_*
/// value - a locked parent keeps the child out of the pool.
/// (merges Myriad's send_ability / send_ability2 / _v2 trio.)
function send_ability(_key, _var, _req = 0) {
	_unlockable_abilities++;
	if (_var != -1) { _new_abilities_unlocked++; exit; }
	if (_req == -1) exit;
	array_push(g.abi_pool, _key);
}
