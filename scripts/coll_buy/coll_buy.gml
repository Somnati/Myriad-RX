/// @description coll_buy(c, what) -> true when bought: an energy upgrade - "field" (x1.15 every tier, both sides), "auto" (the auto-collider's next interval), "magnet" (the clean window x1.5)
function coll_buy(_c, _what) {
	if (_c.inf) return false;
	var _cost = coll_cost(_c, _what);
	if (_cost < 0 || _c.energy < _cost) return false;
	_c.energy = lg_sub(_c.energy, _cost);
	switch (_what) {
		case "field": _c.field += 1; break;
		case "auto":  _c.auto_lv += 1; _c.auto_t = 0; break;
		case "magnet": _c.magnet_lv += 1; break;
	}
	save_mark_dirty();
	return true;
}
