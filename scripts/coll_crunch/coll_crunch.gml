/// @description coll_crunch(c) - THE BIG CRUNCH: the horizon's only exit - both cascades, the energy and the upgrades let go; best, the crunch count (+1 - the residue: the next run's tier costs step x0.99 gentler) and the pairs ledger survive through coll_init
function coll_crunch(_c) {
	if (!_c.inf) return false;
	_c.crunches += 1;
	coll_init(true);
	save_mark_dirty();
	return true;
}
