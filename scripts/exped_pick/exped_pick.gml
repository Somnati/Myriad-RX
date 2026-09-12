/// @description exped_pick(weights) -> a key drawn by weight
/// The one weighted draw the expedition uses (rooms, loot, names).
/// @param weights   a struct of key -> weight
function exped_pick(_w) {
	var _k = variable_struct_get_names(_w);
	var _t = 0;
	for (var _i = 0; _i < array_length(_k); _i++) _t += _w[$ _k[_i]];
	var _r = random(_t);
	for (var _i = 0; _i < array_length(_k); _i++) {
		_r -= _w[$ _k[_i]];
		if (_r <= 0) return _k[_i];
	}
	return _k[array_length(_k) - 1];
}
