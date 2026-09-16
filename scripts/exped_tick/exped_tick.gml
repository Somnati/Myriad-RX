/// @description exped_tick(secs) - walk every trip under way by secs
/// (x the debug clock), online and offline alike (offline_replay hands
/// the absence to this same call). A trip that gets home leaves the
/// trips list for the hauls list, where exped_collect finds it.
/// IN SLICES (2026-09-14, the inspection): exped_tick_one walks ONE room
/// a call and a fight swallows the call, so one call with an eight-hour
/// absence moved a trip a single room and the delve then ran live, a
/// room a frame, after you came back. The clock is cut into slices of
/// EXPED_TICK_MAX seconds - a room a slice, a fight's actions inside it
/// - so the absence walks the whole trip, fights and all, offline ==
/// online by construction. (an hour is 720 slices a trip: cheap)
function exped_tick(_secs) {
	exped_init();
	var _e = g.exped;
	var _spd = max(1, _e.spd);
	var _dt = _secs * _spd;
	exped_offer_tick(_dt);   // the quest boards turn over (2026-09-15)
	exped_mem_tick(_dt);     // the world's memories fade (2026-09-16)
	exped_event_tick();      // ...and the regions' events roll (2026-09-16)
	for (var _i = array_length(_e.trips) - 1; _i >= 0; _i--) {
		var _tr = _e.trips[_i];
		// A FIGHT PLAYS AT ITS OWN PACE (his ask, 2026-09-15): the debug clock
		// hurries the walk, not the fight - unless it is at x100
		if (!is_undefined(_tr.fight) && _spd < 100) { exped_tick_one(_tr, _secs); continue; }
		var _left = _dt, _home = false;
		while (_left > 0 && !_home) {
			var _step = min(_left, EXPED_TICK_MAX);
			_left -= _step;
			_home = exped_tick_one(_tr, _step);
		}
		if (!_home) continue;
		array_delete(_e.trips, _i, 1);
		array_push(_e.hauls, { id : _tr.id, dest : _tr.dest, sids : _tr.sids, names : _tr.names, cols : _tr.cols,
		                       sid : _tr.sid, sname : _tr.sname, finds : _tr.finds, routed : _tr.routed,
		                       cleared : _tr.cleared, wins : _tr.wins, log : _tr.log, hp : _tr.hp, hpmax : _tr.hpmax, mp : _tr[$ "mp"] ?? [], rgi : _tr[$ "rgi"] ?? 0,
		                       tl : _tr[$ "tl"] ?? { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 }, pocket : _tr[$ "credits"] ?? 0, stance : _tr[$ "stance"] ?? "steady", best : exped_haul_moment(_tr) });   // (the best moment, 2026-09-16)   // (the tally home, 2026-09-16)   // (rgi: the card's world faces the region - 2026-09-15)
		save_mark_dirty();
	}
}
