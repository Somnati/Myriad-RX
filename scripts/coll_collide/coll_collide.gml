/// @description coll_collide(c, [pct]) -> the energy gained, LOG10 (COLL_LZ = nothing): ANNIHILATION - min(matter, antimatter) x pct pairs leave BOTH stocks; each pair gives COLL_PAIR_E energy, x the clean factor. The stocks are also what buys tiers - every press trades growth for score. The lifetime pairs ledger rides pairs_lg
function coll_collide(_c, _pct = -1) {
	if (_c.inf) return COLL_LZ;
	if (_pct < 0) _pct = _c.pct;
	var _mn = min(_c.m.stock, _c.a.stock);
	if (_mn < COLL_LZ * .5 || _mn < 0) return COLL_LZ;   // (under one pair - nothing to annihilate)
	var _lp = _mn + log10(_pct / 100), _clean = coll_clean(_c);   // pairs, log10 (the clean factor read BEFORE the stocks move)
	if (_lp < 0) return COLL_LZ;
	_c.m.stock = lg_sub(_c.m.stock, _lp);
	_c.a.stock = lg_sub(_c.a.stock, _lp);
	var _le = _lp + log10(COLL_PAIR_E) + log10(_clean);
	_c.energy = lg_add(_c.energy, _le);
	_c.pairs_lg = lg_add(_c.pairs_lg, _lp);
	_c.collisions += 1;
	if (_c.energy >= COLL_WALL) {   // THE HORIZON: the run ends, the room's banner takes over
		_c.energy = COLL_WALL; _c.inf = true; _c.run = universal_now() - _c.start;
		if (_c.best < 0 || _c.run < _c.best) _c.best = _c.run;
	}
	save_mark_dirty();
	return _le;
}
