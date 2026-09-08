/// @description timebank_add(away_seconds);
/// Convert an absence into banked time. THE ONE SITE - offline_replay
/// calls it as it measures the absence, so a suspend and a closed app
/// arrive through the same door and neither can be counted twice.
///
/// THE HYBRID (his design): the absence ALREADY ran as production, and
/// this banks a slice of it on top. That double-counts by intent - the
/// sim pays what the dials earned, the bank pays for having been away -
/// and it is safe because the slice is under an hour per hour (see
/// timebank_rate's invariant).
///
/// Past the cap, time is LOST rather than queued. last_add / last_full
/// carry the result to the welcome-back report.
function timebank_add(_secs) {
	timebank_init();
	if (_secs <= 0) return 0;
	var _tb  = g.timebank;
	var _cap = timebank_cap();
	var _add = _secs * timebank_rate();
	var _room = max(0, _cap - _tb.bank);
	_tb.last_full = (_add > _room);
	_add = min(_add, _room);
	_tb.bank += _add;
	_tb.last_add = _add;
	if (_add > 0) save_mark_dirty();
	return _add;
}
