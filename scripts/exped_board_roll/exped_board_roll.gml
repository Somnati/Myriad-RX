/// @description exped_board_roll() - deal the three destinations on
/// offer, seeded by how many trips have started so the deal is stable
/// across boots. A world a crew is still OUT TO stays on the board (his
/// ask: back out and send another crew to the same planet) - its slot is
/// rolled and discarded so the stream stays in step.
function exped_board_roll() {
	exped_init();
	var _e = g.exped;
	if (!galaxy_ready()) return;   // (the chart is still in the background - exped_tick rolls the board the moment it lands; 2026-09-17)
	// THE HOME WORLD first (2026-09-15): galaxy_home builds the galaxy on its
	// first call - a seeded section of its own - so it runs BEFORE the deal's
	// seeded block, or its release would scramble the deal's later rolls
	var _hm = galaxy_home();
	var _rs = random_get_seed();
	random_set_seed(74123 + _e.seq * 7919);
	var _old = _e.board;
	_e.board = [];
	var _bi = exped_biomes();
	for (var _i = 0; _i < EXPED_BOARD_N; _i++) {   // (one world for now, his call 2026-09-14)
		var _tier = clamp(1 + irandom(max(0, _e.depth - 1)), 1, _e.depth);
		if (_i == EXPED_BOARD_N - 1 && _e.depth > 1) _tier = _e.depth;   // one at the frontier, always
		var _b = irandom(array_length(_bi) - 1);
		if (_bi[_b].name == "cloud") _b = hash_mix(_e.seq * 31 + _i, 909) mod 8;   // (the deal never offers a gas world - no landing there; the roll itself still runs, so the stream holds - q243)
		if (_i == 0 && _e.depth <= 1) _b = 1;   // the first world on the first board is a LIVING one - blue water, green grass (his first scope, 2026-09-14)
		var _seed = irandom($7fffffff);
		// THE HOME WORLD (2026-09-15): the first world on the board is the
		// planet we are on - a real star's temperate rock (galaxy_home), so
		// the sky over it is its real neighbourhood and the star is on the
		// map. (The roll above still runs: the deal's stream stays in step)
		var _hname = "";
		if (_i == 0) { _seed = _hm.planet_seed; _hname = _hm.name; }
		var _keep = undefined;
		if (_i < array_length(_old))
			for (var _t = 0; _t < array_length(_e.trips); _t++)
				if (_e.trips[_t].dest.seed == _old[_i].seed) _keep = _old[_i];
		if (!is_undefined(_keep)) { array_push(_e.board, _keep); continue; }
		array_push(_e.board, {
			seed  : _seed,
			name  : _hname,   // (a rolled world is named after the block - exped_name seeds, and its release would scramble the deal)
			biome : _b,
			tier  : _tier,
			dist  : EXPED_DIST0 * power(2, _tier - 1),
			rate  : 60 * _tier + 40 * (_b == 2),   // ruins roll a rung richer
			star  : (_i == 0) ? _hm.star : -1, pl : (_i == 0) ? _hm.planet : -1,   // (the home world's star - the star map's worlds carry theirs, 2026-09-16)
		});
	}
	rng_release(_rs);
	// THE STAR MAP'S WORLDS (2026-09-16): every world opened on the map, after the home world, and it STAYS (the old struct kept where one is: its caches)
	if (!is_array(_e[$ "worlds"])) _e.worlds = [];
	for (var _wi = 0; _wi < array_length(_e.worlds); _wi++) {
		var _gw = galaxy_world(_e.worlds[_wi].star, _e.worlds[_wi].pl);
		if (is_undefined(_gw)) continue;
		var _dup = false;
		for (var _bj = 0; _bj < array_length(_e.board); _bj++) if (_e.board[_bj].seed == _gw.seed) _dup = true;
		if (_dup) continue;
		for (var _oj = 0; _oj < array_length(_old); _oj++) if (_old[_oj].seed == _gw.seed) _gw = _old[_oj];
		array_push(_e.board, _gw);
	}
	for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].name == "") _e.board[_i].name = exped_name(_e.board[_i].seed);
	// THE QUEST each world offers (slice three): rolled off the world and
	// the deal, after the seeded block - a fresh one every re-deal
	for (var _i = 0; _i < array_length(_e.board); _i++) if (!is_struct(_e.board[_i][$ "quest"])) _e.board[_i].quest = exped_quest_gen(_e.board[_i]);
}
