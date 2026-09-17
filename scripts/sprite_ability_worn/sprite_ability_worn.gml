/// @description sprite_ability_worn(sprite) -> the four rung indices the
/// sprite WEARS (-1 = an open slot), in rung order - THE ONE READ every
/// consumer (sprite_ab, the sheet) goes through.
/// With the picker vaulted (SPRITE_AB_PICK false - his call, 2026-09-17:
/// "leave it to the sprite") the set DERIVES: the best four of every rung
/// unlocked, by the class's own judgement (ability_score), read fresh -
/// nothing to fill, nothing to evict, an old save's sprites just wear
/// their best. With the picker live it is the sheet's saved abil slots
/// (the player's picks, sprite_ability_autofill's fills).
function sprite_ability_worn(_sp) {
	var _sh = sprite_sheet(_sp);
	if (!is_array(_sh[$ "abil"])) _sh.abil = [-1, -1, -1, -1];
	if (SPRITE_AB_PICK) return _sh.abil;
	var _all = sprite_abilities(_sp), _n = array_length(_all);
	var _out = [-1, -1, -1, -1];
	if (_n <= 4) { for (var _i = 0; _i < _n; _i++) _out[_i] = _i; return _out; }
	// the scores, then the top four - stable: a tie keeps the LOWER rung
	var _sc = array_create(_n, 0);
	for (var _i = 0; _i < _n; _i++) _sc[_i] = ability_score(_sp, _all[_i]);
	var _pick = [];
	repeat (4) {
		var _bk = -1, _bs = -infinity;
		for (var _k = 0; _k < _n; _k++) { if (array_contains(_pick, _k)) continue; if (_sc[_k] > _bs) { _bs = _sc[_k]; _bk = _k; } }
		if (_bk < 0) break;
		array_push(_pick, _bk);
	}
	array_sort(_pick, true);   // (worn in rung order - the sheet reads top to bottom)
	for (var _i = 0; _i < array_length(_pick); _i++) _out[_i] = _pick[_i];
	return _out;
}
