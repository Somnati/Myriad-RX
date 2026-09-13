/// @description objective_by_key(key) -> that row of objective_config,
/// or undefined ("" included). The card holds a KEY through its
/// celebration rather than an index, so the chain moving on under it
/// cannot swap the words mid-flash.
function objective_by_key(_key) {
	if (_key == "") return undefined;
	var _c = objective_config();
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i].key == _key) return _c[_i];
	return undefined;
}
