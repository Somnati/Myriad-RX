/// @description stk_perk_buy(s, key) -> true when bought: cinders HELD pay (and lose their passive - the tree's tension), the rank climbs; headstart lifts the well now
function stk_perk_buy(_s, _key) {
	var _c = stk_perk_cost(_s, _key);
	if (_c < 0 || _s.cinders < _c) return false;
	_s.cinders -= _c; _s.spent += _c;
	_s.perks[$ _key] = stk_perk(_s, _key) + 1;
	if (_key == "headstart") { var _w = _s.layers[0].sinks[3]; _w.level = max(_w.level, 3 * stk_perk(_s, "headstart")); }
	save_mark_dirty();
	return true;
}
