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
	if (_night != _was) array_push(_tr.log, "* " + (_night ? choose("night falls. the road goes on, darker", "dusk. the light goes and the noises start", "night. someone lights the lamp") : choose("dawn, grey then gold", "morning. everything is wet", "the sun is up. so is the crew, more or less")));   // ("* ": the sky's lines, dim in the diary - 2026-09-16)
	if (_night != _was) exped_say(_tr, _night ? "night" : "dawn", undefined, .55);   // (the voice pass, 2026-09-15)
	_tr.night = _night;
	// THE ECLIPSE (his pick, 2026-09-16): a moon's shadow over the crew's region by day - once per pass (the moon and the hour key it)
	if (!_night) {
		var _ec = planet_eclipse(_tr.dest);
		if (is_struct(_ec)) {
			var _erg = exped_region(_tr), _epn = planet_get(_tr.dest.seed, exped_planet_hint(_tr.dest));
			var _et = [dcos(_erg.spot.lat) * dcos(_erg.spot.lon), dsin(_erg.spot.lat), dcos(_erg.spot.lat) * dsin(_erg.spot.lon)];
			var _ew = mat3_apply(mat3_mul(mat3_rot(0, 0, 1, _epn.tilt), mat3_rot(0, 1, 0, planet_spin_now(_epn))), _et[0], _et[1], _et[2]);
			var _ecos = _ew[0] * _ec.dir[0] + _ew[1] * _ec.dir[1] + _ew[2] * _ec.dir[2];
			var _ekey = string(_ec.moon) + ":" + string(floor(universal_now() / 7200));   // (one line a pass: a shadow crosses in well under two hours)
			if (_ecos > cos(_ec.ang * 1.6) && (_tr[$ "ecl"] ?? "") != _ekey) {
				_tr.ecl = _ekey;
				var _emn = ["the first", "the second", "the third", "the fourth"][clamp(_ec.moon, 0, 3)];
				array_push(_tr.log, "* " + choose("the day goes dim. " + _emn + " moon slides over the sun and the birds stop", "an eclipse - " + _emn + " moon takes the sun for a while. nobody says much", "the light turns strange: " + _emn + " moon crosses the sun. the crew stands and watches"));
				exped_say(_tr, "night", undefined, .4);
			}
		}
	}
	// THE WEATHER (his ask): the sky over the region, its changes in the diary
	var _wx = exped_weather(_tr);
	var _wwas = _tr[$ "weather"] ?? _wx;
	if (_wx != _wwas) {
		switch (_wx) {
			case "rain":  array_push(_tr.log, "* " + choose("rain sets in", "it starts to rain. everyone pretends it is fine", "rain, the thin kind that gets everywhere")); break;
			case "snow":  array_push(_tr.log, "* " + choose("snow. the road goes white", "it snows. " + _tr.names[0] + " catches one on the tongue")); break;
			case "fog":   array_push(_tr.log, "* " + choose("fog comes down. the road ends ten paces ahead", "a fog, thick as bread")); break;
			case "wind":  array_push(_tr.log, "* " + choose("the wind gets up", "a wind, in their faces, of course")); break;
			case "storm": array_push(_tr.log, "* " + choose("a storm breaks over the road", "thunder. then the rest of it")); break;
			default:      array_push(_tr.log, "* " + choose("the sky clears", "the weather lifts", "sun again, eventually")); break;
		}
	}
	if (_wx != _wwas) exped_say(_tr, "weather", undefined, .5);
	_tr.weather = _wx;
	// THE SEASON (2026-09-16): named on landing (exped_tick_one); its turn, when a trip is long enough to see one, in the diary
	var _ss = region_season(_tr.dest, _rg);
	if (_ss.on) {
		var _swas = _tr[$ "season"] ?? _ss.name;
		if (_ss.name != _swas) array_push(_tr.log, "* the season turns. " + choose("it is " + _ss.name + " now", _ss.name + ", by the look of the trees", _ss.name + ". " + _tr.names[0] + " says so, and the sky agrees"));
		_tr.season = _ss.name;
	}
	// THE REGION'S EVENT (2026-09-16): its start and its end, on the road
	var _ev = region_event(_tr.dest, _tr[$ "rgi"] ?? 0), _evk = is_struct(_ev) ? _ev.kind : "";
	var _evwas = _tr[$ "event"] ?? _evk;
	if (_evk != _evwas) {
		var _over = "";
		switch (_evwas) { case "fair": _over = "the fair is over. the geese are gone"; break; case "rats": _over = "the rats are thinning, they say"; break; case "lord": _over = "word is the lord has gone to ground"; break; case "frost": _over = "the frost breaks"; break; }
		if (_evk != "") array_push(_tr.log, "* word on the road: " + _ev.txt); else if (_over != "") array_push(_tr.log, "* " + _over);
	}
	_tr.event = _evk;
	// on a road
	if (is_struct(_tr.road)) {
		var _rd = _tr.road;
		var _before = floor(_rd.t / EXPED_HOUR);
		var _pp = planet_props(_tr.dest);
		var _pace = _pp.grav * (_night ? .8 : 1) * ((_wx == "storm") ? .7 : ((_wx == "snow") ? .75 : ((_wx == "wind") ? .92 : 1)));   // (the world's gravity, the dark and the weather set the road's pace)
		// THE NOTES (2026-09-16): a note on the land at either end of the road quickens the pace; a note on the weather, the night, keeps them out of trouble below
		var _n_road = false, _n_wx = false, _n_night = false;
		for (var _nk = 0; _nk < array_length(_tr.sids); _nk++) { if (_tr.hp[_nk] <= 0) continue; var _nsp = exped_sprite(_tr.sids[_nk]); if (is_undefined(_nsp)) continue;
			if (sprite_note_has(_nsp, "road:" + _rg.nodes[_rd.a].kind) || sprite_note_has(_nsp, "road:" + _rg.nodes[_rd.b].kind)) _n_road = true;
			if (sprite_note_has(_nsp, "wx:" + _wx)) _n_wx = true;
			if (sprite_note_has(_nsp, "night")) _n_night = true; }
		// THE ABILITIES' ROAD LANES (2026-09-17): long legs quicken the pace,
		// owl-eyed and all-weather read like the notes, pathfinder thins the wrong turns
		var _pab = exped_party_ab(_tr);
		if (_pab.pace > 0) _pace *= 1 + _pab.pace / 100;
		if (_pab.night > 0) _n_night = true;
		if (_pab.weather > 0) _n_wx = true;
		var _sure = 1 - min(80, _pab.sure) / 100;
		if (_n_road) _pace *= 1.1;
		var _dark = (_pp.moons == 0) ? 2 : ((_pp.moons >= 2) ? .5 : 1);   // (a moonless night: twice the wrong turns; two moons: half)
		_rd.t += _dt * _pace;
		var _after = floor(_rd.t / EXPED_HOUR);
		if (_after > _before && _rd.t < _rd.d * EXPED_HOUR) {
			var _nl = array_length(_tr.log);
			var _high = (_rg.nodes[_rd.a].kind == "mountains" || _rg.nodes[_rd.a].kind == "hills" || _rg.nodes[_rd.b].kind == "mountains" || _rg.nodes[_rd.b].kind == "hills");
			// the weather's own: a slip on a wet high road, a wait under a tree in a storm
			if ((_wx == "rain" || _wx == "snow") && _high && !_n_wx && roll_perc(8)) {
				var _sk = irandom(array_length(_tr.sids) - 1);
				if (_tr.hp[_sk] > 0) { _tr.hp[_sk] = max(1, _tr.hp[_sk] - _tr.hpmax[_sk] * .08); exped_tally(_tr, "mist"); array_push(_tr.log, _tr.names[_sk] + " slipped on the wet " + ((_rg.nodes[_rd.b].kind == "mountains") ? "scree" : "slope") + " and went down a way. bruises"); }
			}
			if (_wx == "storm" && roll_perc(25)) { _rd.t = max(0, _rd.t - EXPED_HOUR * .5); array_push(_tr.log, choose("waited out the worst of it under a tree", "sheltered under a rock while the sky did its thing", "the storm sat on them for half an hour")); return false; }
			// the dark: a wrong turn (another road out of the node they left -
			// the path is thrown away, they decide afresh where they end up),
			// or an hour lost, before anything else; fog doubles the wrong turns
			if ((_night && roll_perc(6 * _dark * (_n_night ? .5 : 1) * _sure)) || (_wx == "fog" && !_n_wx && roll_perc((_night ? 10 : 8) * _sure))) {
				var _nb = region_neighbors(_rg, _rd.a);
				if (array_length(_nb) > 1) {
					var _pick = _nb[irandom(array_length(_nb) - 1)].j;
					if (_pick != _rd.b) { _tr.road = { a : _rd.a, b : _pick, d : region_hours(_rg, _rd.a, _pick), t : _rd.t }; _tr.path = []; exped_tally(_tr, "mist"); array_push(_tr.log, "took the wrong road in the " + ((_wx == "fog") ? "fog" : "dark") + ". it goes to " + _rg.nodes[_pick].name); exped_say(_tr, "lost", undefined, .7); return false; }
				}
			}
			if (_night && roll_perc(10 * _dark * (_n_night ? .5 : 1) * _sure)) { _rd.t = max(0, _rd.t - EXPED_HOUR); exped_tally(_tr, "mist"); array_push(_tr.log, choose("lost the road in the dark. an hour to find it again", "went round in a circle. the same tree, twice", "waited out a black hour under a hedge")); exped_say(_tr, "lost", undefined, .6); return false; }
			var _emult = (_night ? 1.5 : 1) * ((_wx == "storm") ? .5 : ((_wx == "rain" || _wx == "snow") ? .85 : 1));
			exped_encounter(_tr, _emult, _wx);
			if (!is_undefined(_tr.fight)) return false;
			// nothing met: a little thing, maybe (exped_road_beat); with a parcel in tow, the parcel does things (2026-09-16)
			var _pq = _tr[$ "quest"];
			if (is_struct(_pq) && _pq.kind == "parcel" && (_pq[$ "at"] ?? 0) == 1 && _pq.done < _pq.n && roll_perc(22)) array_push(_tr.log, exped_compose("parcel", _tr));
			else if (array_length(_tr.log) == _nl) exped_road_beat(_tr);
		}
		exped_stat("road_h", _dt / EXPED_HOUR);
		exped_stat("road_km", (_dt / EXPED_HOUR) * EXPED_WALK_KMH);   // the distance ledger (his ask, 2026-09-17), kept in km
		for (var _wk = 0; _wk < array_length(_tr.sids); _wk++) sprite_led(exped_sprite(_tr.sids[_wk]), "km", (_dt / EXPED_HOUR) * EXPED_WALK_KMH);   // ...and each walker's own
		// THE WANDERER (2026-09-17, Kingdom Hearts' EXP Walker): xp for the distance, its number per 10 km
		for (var _wk2 = 0; _wk2 < array_length(_tr.sids); _wk2++) {
			if (_tr.hp[_wk2] <= 0) continue;
			var _wsp = exped_sprite(_tr.sids[_wk2]);
			if (is_undefined(_wsp)) continue;
			var _wab = sprite_ab(_wsp).wander;
			if (_wab <= 0) continue;
			if (sprite_xp_add(_wsp, (_dt / EXPED_HOUR) * EXPED_WALK_KMH * _wab / 10) > 0) { _tr.hpmax[_wk2] = sprite_pawn(_wsp).maxhp; exped_stat("levels"); array_push(_tr.log, "+ " + _wsp.name + " reached level " + string(sprite_sheet(_wsp).lv) + " - the road taught it"); }
		}
		if (_rd.t >= _rd.d * EXPED_HOUR) {
			_tr.pos = _rd.b;
			_tr.road = undefined;
			if (array_length(_tr.path) > 0 && _tr.path[0] == _tr.pos) array_delete(_tr.path, 0, 1);
			if (!array_contains(_tr.visited, _tr.pos)) array_push(_tr.visited, _tr.pos);
			array_push(_tr.log, "# reached " + _rg.nodes[_tr.pos].name);   // ("# ": a place header in the diary - 2026-09-16)
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
