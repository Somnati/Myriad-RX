/// @description stk_burn(s, l) -> true when lit: BURN (q317), the one consumable - spark lifts layer l's cap by STK_BURN_PCT for STK_BURN_LEN seconds (long burn stretches it); one burn a layer at a time; the overflow drains back when it ends (stk_tick clamps)
function stk_burn(_s, _l) {
	var _ly = _s.layers[_l];
	if (_ly.burn_t > 0) return false;
	var _base = stk_cap(_s, _l);
	if (_base < 1) return false;
	var _cost = stk_burn_cost(_s);
	if (_s.spark < _cost) return false;
	_s.spark -= _cost;
	_ly.burn_add = max(1, floor(_base * STK_BURN_PCT));
	_ly.burn_t = STK_BURN_LEN * (1 + .5 * stk_perk(_s, "burn"));
	save_mark_dirty();
	return true;
}
