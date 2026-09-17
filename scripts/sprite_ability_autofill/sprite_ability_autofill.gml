/// @description sprite_ability_autofill(sprite, [newest]) -> true if a slot changed
/// THE SPRITE'S OWN PICK (his ask, 2026-09-17): every EMPTY slot takes
/// the best unequipped ability by its class's judgement (ability_score);
/// and when a rung has just unlocked (`newest` = its index) and the four
/// are full, the new one takes the place of the weakest worn ability if
/// it beats it by a clear margin - so a sprite nobody manages still
/// grows into its best set, and the player can swap any of it after.
function sprite_ability_autofill(_sp, _newest = -1) {
	var _sh = sprite_sheet(_sp);
	if (!is_array(_sh[$ "abil"])) _sh.abil = [-1, -1, -1, -1];
	var _all = sprite_abilities(_sp);
	var _changed = false;
	// the empties, best first
	repeat (4) {
		var _slot = -1;
		for (var _s = 0; _s < array_length(_sh.abil); _s++) if (_sh.abil[_s] < 0 || _sh.abil[_s] >= array_length(_all)) { _slot = _s; break; }
		if (_slot < 0) break;
		var _bk = -1, _bs = -infinity;
		for (var _k = 0; _k < array_length(_all); _k++) {
			if (array_contains(_sh.abil, _k)) continue;
			var _sc = ability_score(_sp, _all[_k]);
			if (_sc > _bs) { _bs = _sc; _bk = _k; }
		}
		if (_bk < 0) break;
		_sh.abil[_slot] = _bk; _changed = true;
	}
	// a fresh rung against a full set: out with the weakest, if the new one is clearly better
	if (_newest >= 0 && _newest < array_length(_all) && !array_contains(_sh.abil, _newest)) {
		var _wi = -1, _wv = infinity;
		for (var _s = 0; _s < array_length(_sh.abil); _s++) {
			var _k2 = _sh.abil[_s];
			if (_k2 < 0 || _k2 >= array_length(_all)) continue;
			var _v2 = ability_score(_sp, _all[_k2]);
			if (_v2 < _wv) { _wv = _v2; _wi = _s; }
		}
		if (_wi >= 0 && ability_score(_sp, _all[_newest]) > _wv * 1.15) { _sh.abil[_wi] = _newest; _changed = true; }
	}
	if (_changed) save_mark_dirty();
	return _changed;
}
