/// @description exped_board_roll() - three destinations, seeded by the
/// trip count so the board is the same after a restart until a trip
/// changes it. A destination: a seed (its face and its name), a biome,
/// a tier (1..depth, weighted toward the top), the distance in seconds
/// (EXPED_DIST0 x 2^(tier-1)), and the rarity rate its hauls roll at.
function exped_board_roll() {
	exped_init();
	var _e = g.exped;
	var _rs = random_get_seed();
	random_set_seed(74123 + _e.seq * 7919);
	_e.board = [];
	var _bi = exped_biomes();
	for (var _i = 0; _i < 3; _i++) {
		var _tier = clamp(1 + irandom(max(0, _e.depth - 1)), 1, _e.depth);
		if (_i == 2 && _e.depth > 1) _tier = _e.depth;   // one at the frontier, always
		var _b = irandom(array_length(_bi) - 1);
		var _seed = irandom($7fffffff);
		array_push(_e.board, {
			seed  : _seed,
			name  : exped_name(_seed),
			biome : _b,
			tier  : _tier,
			dist  : EXPED_DIST0 * power(2, _tier - 1),
			rate  : 60 * _tier + 40 * (_b == 2),   // ruins roll a rung richer
		});
	}
	rng_release(_rs);
}
