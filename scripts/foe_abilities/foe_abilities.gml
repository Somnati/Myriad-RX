/// @description foe_abilities(seed, lv, [n]) -> a foe's abilities: the
/// rungs its level has passed, generated off ITS seed, the highest tiers
/// kept (four at most - it wears what a sprite would). A studied kind's
/// tricks are learnable because they are the same roster.
function foe_abilities(_seed, _lv, _n = 4) {
	var _lad = ability_unlocks();
	var _out = [];
	for (var _i = 0; _i < array_length(_lad); _i++) {
		if (_lv < _lad[_i].lv) break;
		array_push(_out, ability_gen(hash_mix(_seed & $7fffffff, 9000 + _i), _lad[_i].tier));
	}
	while (array_length(_out) > _n) array_delete(_out, 0, 1);   // (the oldest rungs drop - the lowest tiers)
	return _out;
}
