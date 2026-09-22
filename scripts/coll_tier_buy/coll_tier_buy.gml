/// @description coll_tier_buy(c, side, i, [qty]) -> units bought: a tier of one side, paid from the other's stock (side 0 matter pays antimatter, 1 antimatter pays matter)
function coll_tier_buy(_c, _side, _i, _q = 1) {
	if (_c.inf) return 0;
	var _k = coll_stepk(_c), _did = (_side == 0) ? cas_buy(_c.m, _i, _c.a, _q, _k) : cas_buy(_c.a, _i, _c.m, _q, _k);
	if (_did > 0) save_mark_dirty();
	return _did;
}
