/// @description potion_find(key) -> the potion's config row, or undefined
function potion_find(_k) {
	var _c = potion_config();
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i].key == _k) return _c[_i];
	return undefined;
}
