/// @description exped_start(dest index, crew, [mode]) -> true when a trip left.
/// crew = an array of sprite structs (one to EXPED_PARTY), or one struct.
/// mode = "quest" (the world's quest, exped_quest_gen) or "explore"
/// (until recalled). Every member must be awake and home. THE COST
/// (his pitch): fuel x tier + a pocket each (exped_cost), paid in credits
/// here - refused when the purse cannot. The crew lands at the region's
/// landing zone with the pocket and walks from there (exped_agent).
/// Any number of trips may run at once (exped_tick walks them all).
function exped_start(_di, _crew, _mode = "quest", _pick = undefined, _ri = 0) {
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
	// the bill
	var _cost = exped_cost(_d, array_length(_crew));
	credits_init();
	if (!(g.credits >= arb(_cost.total))) return false;
	g.credits = do_subtract(g.credits, arb(_cost.total));
	if (!(g.credits >= arb(1))) g.credits = 0;
	_ri = clamp(_ri, 0, EXPED_REGIONS - 1);
	var _rg = region_get(_d, _ri);
	_e.seq += 1;
	var _sids = [], _names = [], _cols = [], _hp = [], _hpmax = [];
	for (var _i = 0; _i < array_length(_crew); _i++) {
		var _sp = _crew[_i];
		_sp.trip = true;
		array_push(_sids, _sp.id);
		array_push(_names, _sp.name);
		array_push(_cols, _sp.col);
		var _h = sprite_pawn(_sp).maxhp;         // hp: the sheet's (class x level x gear, sprite_pawn)
		array_push(_hp, _h);
		array_push(_hpmax, _h);
	}
	var _q = undefined;
	if (_mode == "quest") {
		_q = is_struct(_pick) ? _pick : (is_struct(_d[$ "quest"]) ? _d.quest : exped_quest_gen(_d));   // (the departure window's pick, 2026-09-15)
		// the quest is THIS crew's now: the copy walks, the board keeps its own until the re-deal
		_q = { kind : _q.kind, node : _q.node, foe : _q.foe, n : _q.n, done : 0, txt : _q.txt, mult : _q.mult, reward : _q.reward, hours : _q[$ "hours"] ?? 0, diff_txt : _q[$ "diff_txt"] ?? "fair" };
	}
	// THE LANDING: a quest's crew lands at the landing zone nearest its
	// objective (his ask); an explore at the first
	var _home = is_struct(_q) ? region_nearest_landing(_rg, _q.node) : _rg.landing;
	var _tr = {
		id : _e.seq, dest : _d,
		sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
		t : 0, dur : _d.dist, stage : 0,             // 0 flying there, 1 on the world, 2 flying home
		leave_t : 0,                                 // when stage 2 began (the flight home is dur x EXPED_RETURN)
		rooms : [], room_i : -1, cleared : 0,        // (the old delve's - kept for the save's shape)
		hp : _hp, hpmax : _hpmax,                    // per member
		fight : undefined, routed : false, rout_t : 0, fights : 0,
		finds : [],                                  // the haul, as it is gathered
		log : [ exped_crew_txt(_names) + " left for " + _d.name + ((_mode == "explore") ? " to explore" : "") + "  (fuel " + string(_cost.fuel) + ", pocket " + string(_cost.pocket) + ")" ],
		threads : [], said_travel : false, wins : 0,
		// THE AGENT (slice three)
		mode : _mode, quest : _q,
		pos : _home, home : _home, rgi : _ri, path : [], road : undefined, act : undefined,
		credits : _cost.pocket, recall : false, visited : [ _home ], planet_t : 0, bounty : undefined,
	};
	if (is_struct(_q)) array_push(_tr.log, "the quest: " + _q.txt + "  (" + _rg.name + ")");
	else array_push(_tr.log, "to explore " + _rg.name);
	array_push(_e.trips, _tr);
	exped_say(_tr, "depart");
	save_mark_dirty();
	return true;
}
