/// @description sprite_ability_autofill(sprite) -> how many slots it filled
/// A new rung has unlocked (a level-up): any EMPTY slot takes the newest
/// unequipped ability, so a sprite nobody manages still grows - the
/// player can empty or swap a slot after (the sheet's picker). Never
/// evicts a pick.
function sprite_ability_autofill(_sp) {
	var _sh = sprite_sheet(_sp);
	if (!is_array(_sh[$ "abil"])) _sh.abil = [-1, -1, -1, -1];
	var _all = sprite_abilities(_sp);
	var _n = 0;
	for (var _k = array_length(_all) - 1; _k >= 0; _k--) {
		if (array_contains(_sh.abil, _k)) continue;
		var _slot = -1;
		for (var _s = 0; _s < array_length(_sh.abil); _s++) if (_sh.abil[_s] < 0) { _slot = _s; break; }
		if (_slot < 0) break;
		_sh.abil[_slot] = _k; _n++;
	}
	if (_n > 0) save_mark_dirty();
	return _n;
}
