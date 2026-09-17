/// @description sprite_ab(sprite) -> the summed effects of what the sprite
/// WEARS (sprite_ability_worn: four rung indices, -1 an open slot) AND
/// ITS FLAW (the fifth slot, sprite_flaw - his call, 2026-09-17).
/// Cached on the sprite for the session (`abc`, keyed by the level - and
/// the picks when the picker is live): sprite_rate, the staff, the road
/// and every draw read this, and the abilities regenerate off seeds.
/// ⚖️ never MUTATE the struct this returns (the auras set their own
/// fields on the pawn instead)
function sprite_ab(_sp) {
	var _sh = sprite_sheet(_sp);
	var _ck = string(_sh.lv) + (SPRITE_AB_PICK ? ("/" + string(_sh.abil)) : "");
	var _cc = _sp[$ "abc"];
	if (is_struct(_cc) && _cc.k == _ck) return _cc.ab;
	var _all = sprite_abilities(_sp), _wn = sprite_ability_worn(_sp);
	var _eq = [];
	for (var _i = 0; _i < array_length(_wn); _i++) {
		var _k = _wn[_i];
		if (_k >= 0 && _k < array_length(_all)) array_push(_eq, _all[_k]);
	}
	array_push(_eq, sprite_flaw(_sp));   // THE FLAW: always on
	var _ab = ability_effects(_eq);
	_sp.abc = { k : _ck, ab : _ab };
	return _ab;
}
