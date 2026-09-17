/// @description sprite_would_wear(sprite, item) -> true when the item beats what the sprite wears in that slot (sprite_take's own test, no dumb moment)
function sprite_would_wear(_sp, _it) {
	if ((_it[$ "slot"] ?? "") == "use") return false;
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _sc = gear_score(_sp, _it);
	if (_it.slot == "w1" || _it.slot == "w2") { var _old = _sh[$ _it.slot]; return is_undefined(_old) || (_sc > gear_score(_sp, _old)); }
	var _arr = _sh[$ _it.slot];
	var _cap = (_it.slot == "armor") ? _c.armor : _c.talis;
	if (array_length(_arr) < _cap) return true;
	var _worst = infinity;
	for (var _i = 0; _i < array_length(_arr); _i++) _worst = min(_worst, gear_score(_sp, _arr[_i]));
	return (_sc > _worst);
}
