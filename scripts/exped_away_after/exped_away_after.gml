/// @description exped_away_after(logn) -> { n, homes, routed, trips[] } - THE ABSENCE'S EXPEDITION SECTION for the offline log: every crew still out (where it got to, what its diary added since logn[id] lines) and every haul whose trip was out when the absence began. offline_replay's block, one function since q230 - it is written twice when the hours were owed (exped_owed_report)
/// While hours are owed (g.exped_owed > 0: the chart was not there for the
/// walk) a stage-1 row says so instead of naming the spot the crew stood at
/// when the game closed (bug hunt 5, 2026-09-18)
function exped_away_after(_logn) {
	var _ex1 = { n : array_length(g.exped.trips), homes : 0, routed : 0, trips : [] };
	var _owed = (g[$ "exped_owed"] ?? 0);
	// still out: where each got to and what its diary added
	for (var _ti = 0; _ti < array_length(g.exped.trips); _ti++) {
		var _tr1 = g.exped.trips[_ti];
		var _from = _logn[$ string(_tr1.id)] ?? array_length(_tr1.log);
		var _lines = [];
		for (var _li = _from; _li < array_length(_tr1.log); _li++) array_push(_lines, _tr1.log[_li]);
		array_push(_ex1.trips, { name : exped_crew_txt(_tr1.names), planet : _tr1.dest.name, stage : _tr1.stage, room : _tr1.room_i,
		                         where : (_owed > 0) ? ("still out - " + string(round(_owed / 360) / 10) + "h to walk as the chart lands") : exped_where(_tr1),   // (the agent, 2026-09-14: "on the road to Orbury - 1.4h")
		                         home : false, routed : _tr1.routed, lines : _lines });
	}
	// home during the absence: a haul whose trip was out when it began
	for (var _hi = 0; _hi < array_length(g.exped.hauls); _hi++) {
		var _h1 = g.exped.hauls[_hi];
		var _from = _logn[$ string(_h1.id)];
		if (is_undefined(_from)) continue;
		var _lines = [];
		for (var _li = _from; _li < array_length(_h1.log); _li++) array_push(_lines, _h1.log[_li]);
		_ex1.homes += 1;
		if (_h1.routed) _ex1.routed += 1;
		array_push(_ex1.trips, { name : exped_crew_txt(_h1.names), planet : _h1.dest.name, stage : 2, room : EXPED_ROOMS,
		                         home : true, routed : _h1.routed, lines : _lines });
	}
	return _ex1;
}
