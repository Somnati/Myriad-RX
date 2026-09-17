/// @description sprite_abilities(sprite) -> every ability the sprite has
/// UNLOCKED, in rung order (ability_unlocks x its level), each generated
/// off its id and the rung - derived, never stored.
function sprite_abilities(_sp) {
	var _lv = sprite_sheet(_sp).lv;
	var _lad = ability_unlocks();
	var _out = [];
	for (var _i = 0; _i < array_length(_lad); _i++) {
		if (_lv < _lad[_i].lv) break;
		array_push(_out, ability_gen(hash_mix(_sp.id, 9000 + _i), _lad[_i].tier));
	}
	return _out;
}
