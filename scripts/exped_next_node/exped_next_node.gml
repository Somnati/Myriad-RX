/// @description exped_next_node(trip, region) -> where to go next (-1 = leave the world)
/// QUEST: hurt and with coin for a bed, the nearest place to rest first;
/// else the quest's node; done, the landing zone; there, leave.
/// EXPLORE: recalled, the landing zone (there, leave); a bounty taken,
/// its node; hurt, the nearest bed; else exped_explore_pick.
function exped_next_node(_tr, _rg) {
	var _q = _tr[$ "quest"];
	var _mean = 0, _up = 0;
	for (var _i = 0; _i < array_length(_tr.hp); _i++) if (_tr.hp[_i] > 0) { _mean += _tr.hp[_i] / max(1, _tr.hpmax[_i]); _up++; }
	_mean = (_up > 0) ? _mean / _up : 1;
	var _hurt = (_mean < .4);
	if (_tr.mode == "quest") {
		if (is_struct(_q) && _q.done < _q.n && !(_tr[$ "aborted"] ?? false) && !(_tr[$ "recall"] ?? false)) {
			if (_hurt && _tr.credits >= EXPED_INN) {
				var _c = region_nearest_civ(_rg, _tr.pos);
				if (_c >= 0 && _c != _tr.pos) return _c;
			}
			return _q.node;
		}
		// done: the nearest landing zone (the ship picks them up at any); there, leave
		var _lz = region_nearest_landing(_rg, _tr.pos);
		return (_tr.pos == _lz) ? -1 : _lz;
	}
	// explore: the card's clock or count come due = the recall (2026-09-15)
	var _ex = _tr[$ "ex"];
	if (is_struct(_ex) && !(_tr[$ "recall"] ?? false)) {
		if (_ex.kind == "ramble" && (_tr[$ "planet_t"] ?? 0) >= _ex.n * EXPED_HOUR) { _tr.recall = true; array_push(_tr.log, choose("that was the walk. they turn for the landing zone", "the hours are up. home, by the roads they know")); save_mark_dirty(); }
		else if (_ex.kind == "survey" && array_length(_tr[$ "visited"] ?? []) - 1 >= _ex.n) { _tr.recall = true; array_push(_tr.log, string(_ex.n) + " places seen. they turn for the landing zone"); save_mark_dirty(); }
	}
	if (_tr[$ "recall"] ?? false) { var _lz2 = region_nearest_landing(_rg, _tr.pos); return (_tr.pos == _lz2) ? -1 : _lz2; }
	var _bo = _tr[$ "bounty"];
	if (is_struct(_bo) && _bo.done < _bo.n) return _bo.node;
	if (_hurt && _tr.credits >= EXPED_INN) { var _c2 = region_nearest_civ(_rg, _tr.pos); if (_c2 >= 0 && _c2 != _tr.pos) return _c2; }
	return exped_explore_pick(_tr, _rg);
}
