/// @description cheat_free() -> the points not on any row (the cap less
/// the sum). Raising a row spends from here; lowering one refunds to it.
function cheat_free() {
	cheat_init();
	var _v = g.cheat.v, _sum = 0;
	for (var _i = 0; _i < array_length(_v); _i++) _sum += _v[_i];
	return cheat_cap() - _sum;
}
