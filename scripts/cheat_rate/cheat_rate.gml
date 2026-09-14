/// @description cheat_rate(key) -> a row's multiplier (1 = the normal
/// 100%). THE ONE READ every seat uses. 1 until the shop has unfolded
/// (the first rebirth), so a fresh run is untouched by construction.
function cheat_rate(_key) {
	if (!unfold_has("cheat")) return 1;
	cheat_init();
	var _rows = cheat_config().rows;
	for (var _i = 0; _i < array_length(_rows); _i++)
		if (_rows[_i].key == _key) return g.cheat.v[_i] / 100;
	return 1;
}
