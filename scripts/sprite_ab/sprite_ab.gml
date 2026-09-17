/// @description sprite_ab(sprite) -> the summed effects of what the sprite
/// WEARS (sprite_ability_worn: four rung indices, -1 an open slot)
function sprite_ab(_sp) {
	var _all = sprite_abilities(_sp), _wn = sprite_ability_worn(_sp);
	var _eq = [];
	for (var _i = 0; _i < array_length(_wn); _i++) {
		var _k = _wn[_i];
		if (_k >= 0 && _k < array_length(_all)) array_push(_eq, _all[_k]);
	}
	return ability_effects(_eq);
}
