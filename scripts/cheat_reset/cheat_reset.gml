/// @description cheat_reset() - Disgaea's [default]: every row back to
/// 100 (the pool takes whatever the cap has over the base).
function cheat_reset() {
	cheat_init();
	var _v = g.cheat.v, _moved = false;
	for (var _i = 0; _i < array_length(_v); _i++) {
		if (_v[_i] != 100) _moved = true;
		_v[_i] = 100;
	}
	if (_moved) { cheat_apply(); save_mark_dirty(); }
	return _moved;
}
