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
		if (is_struct(_q) && _q.done < _q.n) {
			if (_hurt && _tr.credits >= EXPED_INN) {
				var _c = region_nearest_civ(_rg, _tr.pos);
				if (_c >= 0 && _c != _tr.pos) return _c;
			}
			return _q.node;
		}
		return (_tr.pos == _rg.landing) ? -1 : _rg.landing;
	}
	// explore
	if (_tr[$ "recall"] ?? false) return (_tr.pos == _rg.landing) ? -1 : _rg.landing;
	var _bo = _tr[$ "bounty"];
	if (is_struct(_bo) && _bo.done < _bo.n) return _bo.node;
	if (_hurt && _tr.credits >= EXPED_INN) { var _c2 = region_nearest_civ(_rg, _tr.pos); if (_c2 >= 0 && _c2 != _tr.pos) return _c2; }
	return exped_explore_pick(_tr, _rg);
}
