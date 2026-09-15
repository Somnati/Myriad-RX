/// @description gear_score(sprite, item) -> what the item is worth TO THIS SPRITE
/// Each stat line weighed by the class shape (a warrior counts atk and
/// def, a mage counts mag and mp), so "better" is per class and a staff
/// is nearly nothing to a warrior. The sheet compares, sprite_take decides.
function gear_score(_sp, _it) {
	if (is_undefined(_it)) return 0;
	var _c = sprite_classes()[sprite_sheet(_sp).cls];
	var _k = variable_struct_get_names(_it.pts);
	var _s = 0;
	for (var _i = 0; _i < array_length(_k); _i++) _s += _it.pts[$ _k[_i]] * (_c.shape[$ _k[_i]] ?? 1);
	// the quirks (the proc-gear pass, 2026-09-15): each worth its val, on the class's scale (~5 a line)
	var _ql = _it[$ "quirks"] ?? [];
	if (array_length(_ql) > 0) {
		var _qs = gear_quirks();
		for (var _i = 0; _i < array_length(_ql); _i++) for (var _j = 0; _j < array_length(_qs); _j++) if (_qs[_j].key == _ql[_i]) _s += _qs[_j].val * 5;
	}
	return _s;
}
