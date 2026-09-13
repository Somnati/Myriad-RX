/// @description tiles_sort() - pack the board highest-tier-first.
/// selection sort straight on the tier array; boards are small, and
/// unlike Myriad's swap_slots there are no parallel arrays to drag
/// along - tier is the only state.
function tiles_sort() {
	var _t = g.tiles;
	for (var _i = 0; _i < _t.slots - 1; _i++) {
		var _best = _i;
		for (var _j = _i + 1; _j < _t.slots; _j++)
			if (_t.tier[_j] > _t.tier[_best]) _best = _j;
		if (_best != _i) {
			var _tmp = _t.tier[_i];
			_t.tier[_i] = _t.tier[_best];
			_t.tier[_best] = _tmp;
			var _tms = _t.skin[_i];   // the surfaces ride along
			_t.skin[_i] = _t.skin[_best];
			_t.skin[_best] = _tms;
		}
	}
	_t.dirty = true;
	save_mark_dirty(); // save-on-mutation law (board layout persists)
}
