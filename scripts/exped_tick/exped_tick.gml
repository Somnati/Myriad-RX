/// @description exped_tick(secs) - walk every trip under way by secs
/// (x the debug clock), online and offline alike (offline_replay hands
/// the absence to this same call). A trip that gets home leaves the
/// trips list for the hauls list, where exped_collect finds it.
function exped_tick(_secs) {
	exped_init();
	var _e = g.exped;
	var _dt = _secs * max(1, _e.spd);
	for (var _i = array_length(_e.trips) - 1; _i >= 0; _i--) {
		var _tr = _e.trips[_i];
		if (!exped_tick_one(_tr, _dt)) continue;
		array_delete(_e.trips, _i, 1);
		array_push(_e.hauls, { id : _tr.id, dest : _tr.dest, sids : _tr.sids, names : _tr.names, cols : _tr.cols,
		                       sid : _tr.sid, sname : _tr.sname, finds : _tr.finds, routed : _tr.routed,
		                       cleared : _tr.cleared, wins : _tr.wins, log : _tr.log });
		save_mark_dirty();
	}
}
