/// @description flaw_gen(seed) -> one FLAW off a seed: { key, name, rar, val, tier 0, cfg, flaw true }
/// THE FIFTH SLOT (his call, 2026-09-17: "give all sprites/enemies at least
/// 1 flaw... 5th slot will be the negative"): a kind drawn evenly from the
/// roster's flaws (ability_config, `flaw : true`), its number the band
/// DIVIDED by the rarity's multiplier - a rare flaw is a mild one, the one
/// good roll a sprite can get here. Same seed, same flaw, for good.
function flaw_gen(_seed) {
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _c = ability_config(), _pool = [];
	for (var _i = 0; _i < array_length(_c); _i++) if (_c[_i][$ "flaw"] ?? false) array_push(_pool, _c[_i]);
	var _pick = _pool[irandom(array_length(_pool) - 1)];
	var _rar = clamp(calculate_rarity(100, .3, .03, 800, 14), 0, 13);
	var _val = random_range(_pick.band[0], _pick.band[1]) / ability_rarity_mult(_rar);
	_val = round(_val * 10) / 10;
	if (ability_lane_pts(_pick.lane)) _val = sign(_val) * max(1, round(abs(_val)));
	rng_release(_old);
	return { key : _pick.key, name : _pick.name, rar : _rar, val : _val, tier : 0, cfg : _pick, flaw : true };
}
