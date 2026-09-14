/// @description tiles_merge_charge(frac) - CHARGE THE AUTOMERGER by a
/// fraction of its interval (a merge sprite's tap - the fabricator's
/// charge, on the other bar). The merger's own tick fires the merge
/// when the timer reaches its top, so this only moves the clock; it
/// never merges by itself, and a click's push-back still applies.
/// @param frac  of the interval, e.g. .05
function tiles_merge_charge(_frac) {
	tiles_init();
	var _t = g.tiles;
	if (_frac <= 0 || !_t.automerge) return;
	_t.am_tic = min(_t.am_tic_, _t.am_tic + _t.am_tic_ * _frac * cheat_rate("merge"));   // the cheat shop's row (2026-09-13)
	if (array_length(_t.ev) < 12) array_push(_t.ev, { k : "mcharge", i : -1, b : false });
}
