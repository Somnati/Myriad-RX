/// @description potion_pick(rar) -> a potion key drawn by weight among the
/// kinds whose starting rarity is at or under `rar` (a find's rung, a
/// shop's top rung) - the red one most often, the rare draughts rarely
function potion_pick(_rar) {
	var _c = potion_config(), _sum = 0;
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i].rar <= _rar) _sum += _c[_i].w;
	var _r = random(max(.001, _sum));
	for (var _i = 0; _i < array_length(_c); _i++) {
		if (_c[_i].rar > _rar) continue;
		if (_r < _c[_i].w) return _c[_i].key;
		_r -= _c[_i].w;
	}
	return "hp";
}
