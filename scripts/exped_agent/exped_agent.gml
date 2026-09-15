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
	exped_stat("world_h", _dt / EXPED_HOUR);
	if ((_tr[$ "mode"] ?? "quest") == "explore") exped_stat("explore_h", _dt / EXPED_HOUR);
	// an activity in progress
	if (is_struct(_tr.act)) {
		_tr.act.left -= _dt;
		if (_tr.act.left > 0) return false;
		exped_act_step(_tr);
		return false;
	}
	// DAY AND NIGHT (his ask, 2026-09-15): where the crew stands, the sun
	// is up or it is not (exped_daylight); the crossings go in the diary
	var _dl = exped_daylight(_tr);
	var _night = (_dl < -.12);
	var _was = _tr[$ "night"] ?? _night;
	if (_night != _was) array_push(_tr.log, _night ? choose("night falls. the road goes on, darker", "dusk. the light goes and the noises start", "night. someone lights the lamp") : choose("dawn, grey then gold", "morning. everything is wet", "the sun is up. so is the crew, more or less"));
	_tr.night = _night;
	// on a road
	if (is_struct(_tr.road)) {
		var _rd = _tr.road;
		var _before = floor(_rd.t / EXPED_HOUR);
		_rd.t += _dt * (_night ? .8 : 1);   // (slow going in the dark)
		var _after = floor(_rd.t / EXPED_HOUR);
		if (_after > _before && _rd.t < _rd.d * EXPED_HOUR) {
			var _nl = array_length(_tr.log);
			// the dark: a wrong turn (another road out of the node they left -
			// the path is thrown away, they decide afresh where they end up),
			// or an hour lost, before anything else
			if (_night && roll_perc(6)) {
				var _nb = region_neighbors(_rg, _rd.a);
				if (array_length(_nb) > 1) {
					var _pick = _nb[irandom(array_length(_nb) - 1)].j;
					if (_pick != _rd.b) { _tr.road = { a : _rd.a, b : _pick, d : region_hours(_rg, _rd.a, _pick), t : _rd.t }; _tr.path = []; array_push(_tr.log, "took the wrong road in the dark. it goes to " + _rg.nodes[_pick].name); return false; }
				}
			}
			if (_night && roll_perc(10)) { _rd.t = max(0, _rd.t - EXPED_HOUR); array_push(_tr.log, choose("lost the road in the dark. an hour to find it again", "went round in a circle. the same tree, twice", "waited out a black hour under a hedge")); return false; }
			exped_encounter(_tr, _night ? 1.5 : 1);
			if (!is_undefined(_tr.fight)) return false;
			// nothing met: a little thing, maybe (exped_road_beat)
			if (array_length(_tr.log) == _nl) exped_road_beat(_tr);
		}
		exped_stat("road_h", _dt / EXPED_HOUR);
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
