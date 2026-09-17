/// @description treasure_gen(seed, rar, tier) -> a treasure item { slot "treasure", kind, name, col, rar, val, lv, seed .. }
/// The kind off the seed, the name by the rarity's band (basic..rare the
/// low name, epic..ancient the middle, legendary and up the high), the
/// value = base x (1 + .45 a rung) x (1 + .35 a tier past the first).
/// The item struct carries the gear fields the pocket and the sheet
/// expect (empty), so it rides sprite_take / the pocket / gear_pack like a
/// potion does.
function treasure_gen(_seed, _rar, _tier = 1) {
	var _c = treasure_config();
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _k = irandom(array_length(_c) - 1);
	rng_release(_old);
	var _t = _c[_k];
	_rar = clamp(floor(_rar), 0, 13);
	var _band = (_rar >= 9) ? 2 : ((_rar >= 4) ? 1 : 0);
	var _val = max(1, round(_t.val * (1 + _rar * .45) * (1 + max(0, _tier - 1) * .35)));
	var _col = (_band == 0) ? merge_colour(_t.col, rgb(150, 140, 130), .4) : _t.col;
	return { slot : "treasure", kind : _t.key, name : _t.names[_band], col : _col, rar : _rar, val : _val, lv : max(1, floor(_tier)), seed : _seed & $7fffffff,
	         tag : "", own : "", gen : 1, pts : {}, quirks : [], holds : "", crit : 0, cnt : 0, erode : 1, mp0 : 0, fam : "treasure", score0 : 0, size : 1, line : "" };
}
