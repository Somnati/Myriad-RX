/// @description stk_perk_cost(s, key) -> the next rank's price in cinders, or -1 at the top
function stk_perk_cost(_s, _key) {
	var _pk = stk_perks();
	for (var _i = 0; _i < array_length(_pk); _i++) if (_pk[_i].key == _key) {
		var _r = stk_perk(_s, _key);
		if (_r >= _pk[_i].max) return -1;
		return _pk[_i].base + _pk[_i].step * _r;
	}
	return -1;
}
