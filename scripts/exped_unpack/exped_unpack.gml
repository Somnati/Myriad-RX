/// @description exped_unpack(s) - rebuild the trips and hauls from
/// exped_pack's string. A record that will not parse is dropped; then
/// every sprite's `trip` flag is set from what loaded, so a crew can
/// never be stranded "out" by a record that was lost (the mock's
/// single-trip saves land here too - as nothing, and their sprites
/// come home).
function exped_unpack(_s) {
	exped_init();
	var _e = g.exped;
	_e.trips = []; _e.hauls = [];
	if (is_string(_s) && _s != "") {
		var _recs = string_split(_s, "#");
		for (var _ri = 0; _ri < array_length(_recs); _ri++) {
			var _p = string_split(_recs[_ri], "|");
			if (array_length(_p) < 8) continue;
			var _dd = string_split(_p[1], ":", false, 5);
			if (array_length(_dd) < 6) continue;
			var _d = { seed : real(_dd[0]), biome : real(_dd[1]), tier : real(_dd[2]), dist : real(_dd[3]), rate : real(_dd[4]), name : _dd[5] };
			var _cc = string_split(_p[2], "~");
			if (array_length(_cc) < 3) continue;
			var _sids = [], _names = string_split(_cc[1], ","), _cols = [];
			var _sl = string_split(_cc[0], ","), _cl = string_split(_cc[2], ",");
			for (var _k = 0; _k < array_length(_sl); _k++) { array_push(_sids, real(_sl[_k])); array_push(_cols, (_k < array_length(_cl)) ? real(_cl[_k]) : c_white); }
			if (array_length(_sids) == 0 || array_length(_names) != array_length(_sids)) continue;
			var _tt = string_split(_p[3], ":");
			if (array_length(_tt) < 8) continue;
			var _finds = [];
			if (_p[6] != "") {
				var _fl = string_split(_p[6], ",");
				for (var _i = 0; _i < array_length(_fl); _i++) {
					var _q = string_split(_fl[_i], ":");
					if (array_length(_q) < 5) continue;
					var _l = { kind : _q[0], rar : real(_q[1]), n : real(_q[2]), fam : _q[3], tier : real(_q[4]), txt : "", col : c_white };
					var _rinfo = upgrade_rarity_info(_l.rar);
					switch (_l.kind) {
						case "mats":    _l.txt = string(_l.n) + " " + _l.fam + " (t" + string(_l.tier) + ")"; _l.col = _rinfo.col; break;
						case "sprite":  _l.txt = "a sprite, asleep"; _l.col = _rinfo.col; break;
						case "offer":   _l.txt = "an upgrade offer (" + _rinfo.name + ")"; _l.col = _rinfo.col; break;
						case "charm":   _l.txt = "a charm (+1 luck)"; _l.col = c_seagreen; break;
						case "chart":   _l.txt = "a chart fragment"; _l.col = c_sblue; break;
						case "gear":    _l.txt = "an item - its finder dealt with it"; _l.col = _rinfo.col; break;   // (taken on the spot, exped_room; nothing to collect)
						default:        _l.txt = string(_l.n) + " credits"; _l.col = c_lavender; break;
					}
					array_push(_finds, _l);
				}
			}
			var _id = real(_tt[7]);
			var _hh = string_split(_p[4], "~");
			var _hp = [], _hm = [], _mp = [];
			if (array_length(_hh) >= 2) {
				var _h1 = string_split(_hh[0], ","), _h2 = string_split(_hh[1], ",");
				var _h3 = (array_length(_hh) >= 3) ? string_split(_hh[2], ",") : [];
				for (var _k = 0; _k < array_length(_sids); _k++) {
					array_push(_hm, (_k < array_length(_h2) && _h2[_k] != "") ? max(1, real(_h2[_k])) : 10);
					array_push(_hp, (_k < array_length(_h1) && _h1[_k] != "") ? real(_h1[_k]) : _hm[_k]);
					array_push(_mp, (_k < array_length(_h3) && _h3[_k] != "") ? clamp(real(_h3[_k]), 0, 1) : 1);
				}
			} else for (var _k = 0; _k < array_length(_sids); _k++) { array_push(_hp, 10); array_push(_hm, 10); array_push(_mp, 1); }
			if (_p[0] == "H") {
				// a haul: the hp read above is the crew's at the end (a save from
				// before carried none - they show whole)
				if (array_length(_hh) < 2 || _hh[0] == "") for (var _k = 0; _k < array_length(_sids); _k++) _hp[_k] = _hm[_k];
				array_push(_e.hauls, { id : _id, dest : _d, sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
				                       finds : _finds, routed : (_tt[4] == "1"), cleared : real(_tt[3]), wins : real(_tt[5]), log : [ "home" ], hp : _hp, hpmax : _hm, mp : _mp,
				                       rgi : (array_length(_p) > 8 && _p[8] != "") ? clamp(real(_p[8]), 0, EXPED_REGIONS - 1) : 0 });
				continue;
			}
			var _rooms = (_p[5] != "") ? string_split(_p[5], ",") : [];
			if (array_length(_rooms) < EXPED_ROOMS) {
				var _bi = exped_biomes()[clamp(_d.biome, 0, 3)];
				while (array_length(_rooms) < EXPED_ROOMS) array_push(_rooms, exped_pick(_bi.rooms));
			}
			array_push(_e.trips, {
				id : _id, dest : _d, sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
				t : real(_tt[0]), dur : _d.dist, stage : real(_tt[1]),
				rooms : _rooms, room_i : real(_tt[2]), cleared : real(_tt[3]),
				hp : _hp, hpmax : _hm, mp : _mp,
				fight : undefined, routed : (_tt[4] == "1"), rout_t : real(_tt[0]),
				finds : _finds, log : [ "on the way to " + _d.name + " (the diary's earlier pages did not survive the save)" ],
				threads : (_p[7] != "") ? string_split(_p[7], ",") : [], said_travel : (_tt[6] == "1"), wins : real(_tt[5]),
				// THE AGENT (field 8; a save from before: a quest-less walk home)
				mode : "quest", quest : undefined, pos : 0, path : [], road : undefined, act : undefined,
				credits : 0, recall : false, visited : [ 0 ], planet_t : 0, bounty : undefined, leave_t : real(_tt[0]), fights : 0, rgi : 0, home : 0,
			});
			var _trn = _e.trips[array_length(_e.trips) - 1];
			if (array_length(_p) > 8 && _p[8] != "") {
				var _ag = string_split(_p[8], ":");
				if (array_length(_ag) >= 18) {
					if (array_length(_ag) > 20) { _trn.rgi = clamp(real(_ag[19]), 0, EXPED_REGIONS - 1); _trn.home = real(_ag[20]); }
					_trn.ex = { kind : "wander", n : 0 };
					if (array_length(_ag) > 22 && _ag[21] != "") _trn.ex = { kind : _ag[21], n : real(_ag[22]) };
					_trn.mode = (_ag[0] == "explore") ? "explore" : "quest";
					var _rgn = array_length(region_get(_d, _trn.rgi).nodes);
					_trn.pos = clamp(real(_ag[1]), 0, _rgn - 1); _trn.home = clamp(_trn.home, 0, _rgn - 1);
					_trn.credits = real(_ag[2]); _trn.recall = (_ag[3] == "1");
					// a quest crew recalled is an ABORTED one (exped_abort is the only recall a quest gets; the flag itself is not saved - bug hunt 2026-09-15)
					if (_trn.mode == "quest" && _trn.recall) _trn.aborted = true;
					_trn.leave_t = real(_ag[4]); _trn.planet_t = real(_ag[5]);
					if (_ag[6] != "") {
						var _rgq = region_get(_d, _trn.rgi);
						var _qn = clamp(real(_ag[7]), 0, array_length(_rgq.nodes) - 1);
						_trn.quest = { kind : _ag[6], node : _qn, foe : _ag[8], n : real(_ag[9]), done : real(_ag[10]), mult : real(_ag[11]), reward : real(_ag[12]), hours : 0,
						               from : -1, at : 0, who : "", nodes : undefined, txt : "" };
						// the mission-type pass (2026-09-15): the two-stop kinds' first stop and whether it is done, the name, the survey's nodes
						if (array_length(_ag) > 26) {
							_trn.quest.from = (_ag[23] == "" || _ag[23] == "-1") ? -1 : clamp(real(_ag[23]), 0, array_length(_rgq.nodes) - 1);
							_trn.quest.at = (_ag[24] == "1") ? 1 : 0;
							_trn.quest.who = _ag[25];
							if (_ag[26] != "") { var _qns = string_split(_ag[26], ";"), _qnl = []; for (var _qi = 0; _qi < array_length(_qns); _qi++) if (_qns[_qi] != "") array_push(_qnl, clamp(real(_qns[_qi]), 0, array_length(_rgq.nodes) - 1)); if (array_length(_qnl) > 0) _trn.quest.nodes = _qnl; }
						}
						_trn.quest.pi = (_trn.quest.from >= 0) ? _trn.quest.from : (is_array(_trn.quest.nodes) ? _trn.quest.nodes[0] : _qn);
						_trn.quest.txt = exped_quest_txt(_trn.quest, _rgq);   // (the one builder - the line reads as it did)
					}
					if (_ag[13] != "") _trn.bounty = { node : real(_ag[13]), foe : _ag[14], n : real(_ag[15]), done : real(_ag[16]), pay : real(_ag[17]) };
					_trn.visited = [];
					if (array_length(_ag) > 18 && _ag[18] != "") { var _vs = string_split(_ag[18], ";"); for (var _vi = 0; _vi < array_length(_vs); _vi++) if (_vs[_vi] != "") array_push(_trn.visited, real(_vs[_vi])); }
				}
			} else if (_trn.stage == 1) _trn.stage = 2;   // (a mock-era delve mid-way: it just comes home)
		}
	}
	// the crew flags follow what loaded - nobody stays out on a lost record
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _sp = g.sprites[_i];
		var _out = false;
		for (var _t = 0; _t < array_length(_e.trips) && !_out; _t++) if (array_contains(_e.trips[_t].sids, _sp.id)) _out = true;
		for (var _t = 0; _t < array_length(_e.hauls) && !_out; _t++) if (array_contains(_e.hauls[_t].sids, _sp.id)) _out = true;
		_sp.trip = _out;
	}
	// seq must stay above every id that loaded
	for (var _t = 0; _t < array_length(_e.trips); _t++) _e.seq = max(_e.seq, _e.trips[_t].id);
	for (var _t = 0; _t < array_length(_e.hauls); _t++) _e.seq = max(_e.seq, _e.hauls[_t].id);
}
