/// @description exped_board_roll() - deal the three destinations on
/// offer, seeded by how many trips have started so the deal is stable
/// across boots. A world a crew is still OUT TO stays on the board (his
/// ask: back out and send another crew to the same planet) - its slot is
/// rolled and discarded so the stream stays in step.
function exped_board_roll() {
	exped_init();
	var _e = g.exped;
	var _rs = random_get_seed();
	random_set_seed(74123 + _e.seq * 7919);
	var _old = _e.board;
	_e.board = [];
	var _bi = exped_biomes();
	for (var _i = 0; _i < EXPED_BOARD_N; _i++) {   // (one world for now, his call 2026-09-14)
		var _tier = clamp(1 + irandom(max(0, _e.depth - 1)), 1, _e.depth);
		if (_i == EXPED_BOARD_N - 1 && _e.depth > 1) _tier = _e.depth;   // one at the frontier, always
		var _b = irandom(array_length(_bi) - 1);
		if (_i == 0 && _e.depth <= 1) _b = 1;   // the first world on the first board is a LIVING one - blue water, green grass (his first scope, 2026-09-14)
		var _seed = irandom($7fffffff);
		var _keep = undefined;
		if (_i < array_length(_old))
			for (var _t = 0; _t < array_length(_e.trips); _t++)
				if (_e.trips[_t].dest.seed == _old[_i].seed) _keep = _old[_i];
		if (!is_undefined(_keep)) { array_push(_e.board, _keep); continue; }
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
	// THE QUEST each world offers (slice three): rolled off the world and
	// the deal, after the seeded block - a fresh one every re-deal
	for (var _i = 0; _i < array_length(_e.board); _i++) if (!is_struct(_e.board[_i][$ "quest"])) _e.board[_i].quest = exped_quest_gen(_e.board[_i]);
}
