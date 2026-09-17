/// @description ability_gen(seed, maxtier) -> { key, name, rar, val, tier, cfg }
/// One ability off a seed: a kind from every tier up to `maxtier`, the
/// top tier weighted three to one (a level-30 rung is mostly exotic), a
/// rarity off the gear ladder (no luck lean - the list must stand), the number = the kind's
/// band x the rarity's multiplier. The same seed always makes the same
/// ability - a sprite's line of them is its own, like its face.
function ability_gen(_seed, _maxtier = 1) {
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _c = ability_config();
	var _pool = [], _wsum = 0;
	for (var _i = 0; _i < array_length(_c); _i++) {
		if (_c[_i].tier > _maxtier) continue;
		var _w = (_c[_i].tier == _maxtier) ? 3 : 1;
		array_push(_pool, { e : _c[_i], w : _w }); _wsum += _w;
	}
	var _r = random(_wsum), _pick = _pool[0].e;
	for (var _i = 0; _i < array_length(_pool); _i++) { if (_r < _pool[_i].w) { _pick = _pool[_i].e; break; } _r -= _pool[_i].w; }
	var _rar = clamp(calculate_rarity(100 + _maxtier * 40, .3, .03, 800, 14), 0, 13);   // (no luck lean: the list must never move under a sprite)
	var _val = random_range(_pick.band[0], _pick.band[1]) * ability_rarity_mult(_rar);
	_val = round(_val * 10) / 10;
	if (string_pos("immune", _pick.lane) == 1 || ability_lane_pts(_pick.lane)) _val = max(1, round(_val));   // (the flags and the point lanes: whole numbers)
	rng_release(_old);
	return { key : _pick.key, name : _pick.name, rar : _rar, val : _val, tier : _pick.tier, cfg : _pick };
}
