/// @description mood_pers(sprite) -> the personality's name ("" when none) - the temperament every push is shaped by (q261)
function mood_pers(_sp) {
	var _pl = sprite_personalities();
	if (is_undefined(_sp)) return "";
	return _pl[clamp(_sp[$ "pers"] ?? 0, 0, array_length(_pl) - 1)].name;
}
