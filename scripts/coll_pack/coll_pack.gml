/// @description coll_pack() -> the collider as one string for the save: the ledger, then each side as stock/bought.../count...
function coll_pack() {
	var _c = coll_init(), _s = "1|" + string(_c.energy) + "|" + string(_c.field) + "|" + string(_c.auto_lv) + "|" + string(_c.magnet_lv) + "|" + string(_c.pct) + "|" + string(_c.auto_t) + "|" + string(_c.last) + "|" + string(_c.start) + "|" + (_c.inf ? "1" : "0") + "|" + string(_c.run) + "|" + string(_c.best) + "|" + string(_c.crunches) + "|" + string(_c.pairs_lg) + "|" + string(_c.collisions);
	var _sides = [_c.m, _c.a];
	for (var _k = 0; _k < 2; _k++) {
		var _cs = _sides[_k], _b = "", _n = "";
		for (var _i = 0; _i < COLL_N; _i++) { _b += ((_i > 0) ? "," : "") + string(_cs.bought[_i]); _n += ((_i > 0) ? "," : "") + string(_cs.count[_i]); }
		_s += "|" + string(_cs.stock) + "/" + _b + "/" + _n;
	}
	return _s;
}
