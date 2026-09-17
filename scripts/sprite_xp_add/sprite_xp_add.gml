/// @description sprite_xp_add(sprite, xp) -> levels gained (0 = none)
/// xp into the sheet; every time it clears sprite_xp_need the level
/// climbs (a big grant can climb several). Nothing else changes here -
/// stats derive from the level (sprite_stats), a new skill appears at
/// 10 and 20 (sprite_skills). Marks the save dirty.
function sprite_xp_add(_sp, _xp) {
	var _sh = sprite_sheet(_sp);
	_sh.xp += max(0, _xp);
	var _got = 0;
	var _n0 = array_length(sprite_abilities(_sp));   // the rungs unlocked before
	while (_sh.lv < SPRITE_LV_MAX && _sh.xp >= sprite_xp_need(_sh.lv)) {
		_sh.xp -= sprite_xp_need(_sh.lv);
		_sh.lv += 1;
		_got += 1;
	}
	if (_sh.lv >= SPRITE_LV_MAX) _sh.xp = 0;
	// A NEW RUNG (2026-09-17): the sprite picks for itself (the best by its
	// class, the newest against the weakest worn), and "new" waits on the
	// sheet until the player looks (sprite_sheet's abnew, the picker clears it)
	var _n1 = array_length(sprite_abilities(_sp));
	if (_n1 > _n0) {
		_sh.abnew = true;
		for (var _r = _n0; _r < _n1; _r++) sprite_ability_autofill(_sp, _r);
	}
	save_mark_dirty();
	return _got;
}
