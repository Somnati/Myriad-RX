/// @description exped_start(dest_i, sprite) -> true if the crew left
/// Sends one sprite to the board's destination: the trip is seeded by
/// the destination and the crew, so its rooms are the same on a
/// restart. The sprite is flagged away (sprites_tick skips it, its
/// blob hides) until it is home.
/// @param dest_i   index into g.exped.board
/// @param sprite   the sprite struct (g.sprites[i])
function exped_start(_di, _sp) {
	exped_init();
	var _e = g.exped;
	if (!is_undefined(_e.trip) || !is_undefined(_e.haul)) return false;
	if (_di < 0 || _di >= array_length(_e.board)) return false;
	if (_sp.asleep || (_sp[$ "trip"] ?? false)) return false;
	var _d = _e.board[_di];
	var _bi = exped_biomes()[_d.biome];
	// the rooms, rolled now and kept
	var _rs = random_get_seed();
	random_set_seed(_d.seed ^ (_sp.id * 2654435761) & $7fffffff);
	var _rooms = [];
	repeat (EXPED_ROOMS) array_push(_rooms, exped_pick(_bi.rooms));
	rng_release(_rs);
	_sp.trip = true;
	_e.seq += 1;
	_e.trip = {
		dest : _d, sid : _sp.id, sname : _sp.name,
		t : 0, dur : _d.dist, stage : 0,             // 0 travel, 1 delve, 2 return
		rooms : _rooms, room_i : -1, cleared : 0,
		hp : 8 + (_sp[$ "rar"] ?? 0) * 2, hpmax : 8 + (_sp[$ "rar"] ?? 0) * 2,
		fight : undefined, routed : false, rout_t : 0,
		finds : [],                                  // the haul, as it is gathered
		log : [ "left for " + _d.name ],
		threads : [], said_travel : false, wins : 0,  // the diary's setups, its one travel line, fights won
	};
	_e.log = _e.trip.log;
	exped_say(_e.trip, "depart");
	save_mark_dirty();
	return true;
}
