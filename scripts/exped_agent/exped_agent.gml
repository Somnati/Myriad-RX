/// @description exped_agent(trip, dt) -> true when the crew is back at the landing zone to leave
/// THE AGENT (his pitch): on the world, the crew is doing one of three
/// things - an ACTIVITY at a node (trip.act: its steps as the clock
/// pays, exped_act_step), a ROAD (trip.road: hours x EXPED_HOUR, an
/// encounter roll each hour crossed), or DECIDING (exped_next_node,
/// then a path by the roads, region_path). A fight opened anywhere
/// holds the clock (exped_tick_one). Same call online and offline.
function exped_agent(_tr, _dt) {
	var _rg = exped_region(_tr);
	_tr.planet_t = (_tr[$ "planet_t"] ?? 0) + _dt;
	// an activity in progress
	if (is_struct(_tr.act)) {
		_tr.act.left -= _dt;
		if (_tr.act.left > 0) return false;
		exped_act_step(_tr);
		return false;
	}
	// on a road
	if (is_struct(_tr.road)) {
		var _rd = _tr.road;
		var _before = floor(_rd.t / EXPED_HOUR);
		_rd.t += _dt;
		var _after = floor(_rd.t / EXPED_HOUR);
		if (_after > _before && _rd.t < _rd.d * EXPED_HOUR) {
			exped_encounter(_tr);
			if (!is_undefined(_tr.fight)) return false;
		}
		if (_rd.t >= _rd.d * EXPED_HOUR) {
			_tr.pos = _rd.b;
			_tr.road = undefined;
			if (array_length(_tr.path) > 0 && _tr.path[0] == _tr.pos) array_delete(_tr.path, 0, 1);
			if (!array_contains(_tr.visited, _tr.pos)) array_push(_tr.visited, _tr.pos);
			array_push(_tr.log, "reached " + _rg.nodes[_tr.pos].name);
			exped_note_beat(_tr, "land", .12);
			exped_node_event(_tr);
		}
		return false;
	}
	// deciding
	var _want = exped_next_node(_tr, _rg);
	if (_want == -1) return true;
	if (_want == _tr.pos) { exped_node_event(_tr, true); if (!is_struct(_tr.act)) { _tr.path = []; return array_contains(_rg[$ "landings"] ?? [ _rg.landing ], _tr.pos); } return false; }
	if (array_length(_tr.path) == 0 || _tr.path[array_length(_tr.path) - 1] != _want) _tr.path = region_path(_rg, _tr.pos, _want);
	if (array_length(_tr.path) == 0) { array_push(_tr.log, "no road to " + _rg.nodes[_want].name + ". heading back"); return array_contains(_rg[$ "landings"] ?? [ _rg.landing ], _tr.pos); }
	var _nb = _tr.path[0];
	var _h = region_hours(_rg, _tr.pos, _nb);
	_tr.road = { a : _tr.pos, b : _nb, d : _h, t : 0 };
	array_push(_tr.log, "set out for " + _rg.nodes[_nb].name + " (" + string(_h) + "h)");
	return false;
}
