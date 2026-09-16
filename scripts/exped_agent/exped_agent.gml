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
	if (_night != _was) exped_say(_tr, _night ? "night" : "dawn", undefined, .55);   // (the voice pass, 2026-09-15)
	_tr.night = _night;
	// THE WEATHER (his ask): the sky over the region, its changes in the diary
	var _wx = exped_weather(_tr);
	var _wwas = _tr[$ "weather"] ?? _wx;
	if (_wx != _wwas) {
		switch (_wx) {
			case "rain":  array_push(_tr.log, choose("rain sets in", "it starts to rain. everyone pretends it is fine", "rain, the thin kind that gets everywhere")); break;
			case "snow":  array_push(_tr.log, choose("snow. the road goes white", "it snows. " + _tr.names[0] + " catches one on the tongue")); break;
			case "fog":   array_push(_tr.log, choose("fog comes down. the road ends ten paces ahead", "a fog, thick as bread")); break;
			case "wind":  array_push(_tr.log, choose("the wind gets up", "a wind, in their faces, of course")); break;
			case "storm": array_push(_tr.log, choose("a storm breaks over the road", "thunder. then the rest of it")); break;
			default:      array_push(_tr.log, choose("the sky clears", "the weather lifts", "sun again, eventually")); break;
		}
	}
	if (_wx != _wwas) exped_say(_tr, "weather", undefined, .5);
	_tr.weather = _wx;
	// on a road
	if (is_struct(_tr.road)) {
		var _rd = _tr.road;
		var _before = floor(_rd.t / EXPED_HOUR);
		var _pp = planet_props(_tr.dest);
		var _pace = _pp.grav * (_night ? .8 : 1) * ((_wx == "storm") ? .7 : ((_wx == "snow") ? .75 : ((_wx == "wind") ? .92 : 1)));   // (the world's gravity, the dark and the weather set the road's pace)
		var _dark = (_pp.moons == 0) ? 2 : ((_pp.moons >= 2) ? .5 : 1);   // (a moonless night: twice the wrong turns; two moons: half)
		_rd.t += _dt * _pace;
		var _after = floor(_rd.t / EXPED_HOUR);
		if (_after > _before && _rd.t < _rd.d * EXPED_HOUR) {
			var _nl = array_length(_tr.log);
			var _high = (_rg.nodes[_rd.a].kind == "mountains" || _rg.nodes[_rd.a].kind == "hills" || _rg.nodes[_rd.b].kind == "mountains" || _rg.nodes[_rd.b].kind == "hills");
			// the weather's own: a slip on a wet high road, a wait under a tree in a storm
			if ((_wx == "rain" || _wx == "snow") && _high && roll_perc(8)) {
				var _sk = irandom(array_length(_tr.sids) - 1);
				if (_tr.hp[_sk] > 0) { _tr.hp[_sk] = max(1, _tr.hp[_sk] - _tr.hpmax[_sk] * .08); exped_tally(_tr, "mist"); array_push(_tr.log, _tr.names[_sk] + " slipped on the wet " + ((_rg.nodes[_rd.b].kind == "mountains") ? "scree" : "slope") + " and went down a way. bruises"); }
			}
			if (_wx == "storm" && roll_perc(25)) { _rd.t = max(0, _rd.t - EXPED_HOUR * .5); array_push(_tr.log, choose("waited out the worst of it under a tree", "sheltered under a rock while the sky did its thing", "the storm sat on them for half an hour")); return false; }
			// the dark: a wrong turn (another road out of the node they left -
			// the path is thrown away, they decide afresh where they end up),
			// or an hour lost, before anything else; fog doubles the wrong turns
			if ((_night && roll_perc(6 * _dark)) || (_wx == "fog" && roll_perc(_night ? 10 : 8))) {
				var _nb = region_neighbors(_rg, _rd.a);
				if (array_length(_nb) > 1) {
					var _pick = _nb[irandom(array_length(_nb) - 1)].j;
					if (_pick != _rd.b) { _tr.road = { a : _rd.a, b : _pick, d : region_hours(_rg, _rd.a, _pick), t : _rd.t }; _tr.path = []; exped_tally(_tr, "mist"); array_push(_tr.log, "took the wrong road in the " + ((_wx == "fog") ? "fog" : "dark") + ". it goes to " + _rg.nodes[_pick].name); exped_say(_tr, "lost", undefined, .7); return false; }
				}
			}
			if (_night && roll_perc(10 * _dark)) { _rd.t = max(0, _rd.t - EXPED_HOUR); exped_tally(_tr, "mist"); array_push(_tr.log, choose("lost the road in the dark. an hour to find it again", "went round in a circle. the same tree, twice", "waited out a black hour under a hedge")); exped_say(_tr, "lost", undefined, .6); return false; }
			var _emult = (_night ? 1.5 : 1) * ((_wx == "storm") ? .5 : ((_wx == "rain" || _wx == "snow") ? .85 : 1));
			exped_encounter(_tr, _emult, _wx);
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
