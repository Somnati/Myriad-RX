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
	var _dt = _secs * max(1, _e.spd);
	for (var _i = array_length(_e.trips) - 1; _i >= 0; _i--) {
		var _tr = _e.trips[_i];
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
		                       cleared : _tr.cleared, wins : _tr.wins, log : _tr.log });
		save_mark_dirty();
	}
}
