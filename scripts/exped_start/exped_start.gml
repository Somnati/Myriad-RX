/// @description exped_start(dest index, crew) -> true when a trip left.
/// crew = an array of sprite structs (one to EXPED_PARTY), or one struct.
/// Every member must be awake and home. The rooms roll from the world's
/// seed, the lead's id and the trip number, so two crews to the same
/// world walk different rooms. A world stays on the board while a crew
/// is out to it; any number of trips may run at once (exped_tick walks
/// them all).
function exped_start(_di, _crew) {
	exped_init();
	var _e = g.exped;
	if (_di < 0 || _di >= array_length(_e.board)) return false;
	if (!is_array(_crew)) _crew = [_crew];
	if (array_length(_crew) < 1 || array_length(_crew) > EXPED_PARTY) return false;
	for (var _i = 0; _i < array_length(_crew); _i++) {
		var _sp = _crew[_i];
		if (_sp.asleep || (_sp[$ "trip"] ?? false)) return false;
		for (var _j = 0; _j < _i; _j++) if (_crew[_j].id == _sp.id) return false;
	}
	var _d = _e.board[_di];
	var _bi = exped_biomes()[_d.biome];
	var _rs = random_get_seed();
	random_set_seed((_d.seed ^ ((_crew[0].id * 2654435761) & $7fffffff) ^ (_e.seq * 7919)) & $7fffffff);
	var _rooms = [];
	repeat (EXPED_ROOMS) array_push(_rooms, exped_pick(_bi.rooms));
	rng_release(_rs);
	_e.seq += 1;
	var _sids = [], _names = [], _cols = [], _hp = [], _hpmax = [];
	for (var _i = 0; _i < array_length(_crew); _i++) {
		var _sp = _crew[_i];
		_sp.trip = true;
		array_push(_sids, _sp.id);
		array_push(_names, _sp.name);
		array_push(_cols, _sp.col);
		var _h = 10 + (_sp[$ "rar"] ?? 0) * 2;   // hp: ten, plus two a rarity rung (exped_twin)
		array_push(_hp, _h);
		array_push(_hpmax, _h);
	}
	var _tr = {
		id : _e.seq, dest : _d,
		sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
		t : 0, dur : _d.dist, stage : 0,             // 0 travel, 1 delve, 2 return
		rooms : _rooms, room_i : -1, cleared : 0,
		hp : _hp, hpmax : _hpmax,                    // per member
		fight : undefined, routed : false, rout_t : 0,
		finds : [],                                  // the haul, as it is gathered
		log : [ exped_crew_txt(_names) + " left for " + _d.name ],
		threads : [], said_travel : false, wins : 0,  // the diary's setups, its one travel line, fights won
	};
	array_push(_e.trips, _tr);
	exped_say(_tr, "depart");
	save_mark_dirty();
	return true;
}
