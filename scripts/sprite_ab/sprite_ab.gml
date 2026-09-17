/// @description sprite_ab(sprite) -> the summed effects of what the sprite
/// has EQUIPPED (the sheet's abil slots: four rung indices, -1 empty)
function sprite_ab(_sp) {
	var _sh = sprite_sheet(_sp);
	var _all = sprite_abilities(_sp);
	var _eq = [];
	if (is_array(_sh[$ "abil"])) for (var _i = 0; _i < array_length(_sh.abil); _i++) {
		var _k = _sh.abil[_i];
		if (_k >= 0 && _k < array_length(_all)) array_push(_eq, _all[_k]);
	}
	return ability_effects(_eq);
}
