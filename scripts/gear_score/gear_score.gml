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
	return _s;
}
