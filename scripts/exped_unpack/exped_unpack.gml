/// @description exped_unpack(s) - rebuild the trips and hauls from exped_pack's string
/// KEYED (2026-09-16): every record is read into a map of its `key=value`
/// fields and each thing asked for by NAME with a default - a missing
/// field is its default, an unknown one is ignored, the order is nothing.
/// A record that will not parse is dropped; then every sprite's `trip`
/// flag is set from what loaded, so a crew can never be stranded "out" by
/// a record that was lost. A save from before the keyed form (no "v=" at
/// the head) reads through exped_unpack_v1, the old positional reader.
function exped_unpack(_s) {
	exped_init();
	var _e = g.exped;
	if (is_string(_s) && _s != "" && string_copy(_s, 1, 2) != "v=") { exped_unpack_v1(_s); return; }
	_e.trips = []; _e.hauls = [];
	if (is_string(_s) && _s != "") {
		var _recs = string_split(_s, "#");
		for (var _ri = 0; _ri < array_length(_recs); _ri++) {
			// the record into a map
			var _kv = {};
			var _fl = string_split(_recs[_ri], "|");
			for (var _fi = 0; _fi < array_length(_fl); _fi++) {
				var _eq = string_pos("=", _fl[_fi]);
				if (_eq < 2) continue;
				_kv[$ string_copy(_fl[_fi], 1, _eq - 1)] = string_delete(_fl[_fi], 1, _eq);
			}
			var _kind = _kv[$ "k"] ?? "";
			if (_kind != "T" && _kind != "H") continue;
			// the world
			var _dd = string_split(_kv[$ "dest"] ?? "", ":", false, 5);
			if (array_length(_dd) < 6) continue;
			var _d = { seed : real(_dd[0]), biome : real(_dd[1]), tier : real(_dd[2]), dist : real(_dd[3]), rate : real(_dd[4]), name : _dd[5], star : -1, pl : -1 };
			var _dsf = string_split(_kv[$ "dst"] ?? "", ":");
			if (array_length(_dsf) == 2) { _d.star = real(_dsf[0]); _d.pl = real(_dsf[1]); }   // (the world's star, 2026-09-16; -1 = find it on the board by seed, else home)
			// the crew
			var _cc = string_split(_kv[$ "crew"] ?? "", "~");
			if (array_length(_cc) < 3) continue;
			var _sids = [], _names = string_split(_cc[1], ","), _cols = [];
			var _sl = string_split(_cc[0], ","), _cl = string_split(_cc[2], ",");
			for (var _k = 0; _k < array_length(_sl); _k++) { if (_sl[_k] == "") continue; array_push(_sids, real(_sl[_k])); array_push(_cols, (_k < array_length(_cl) && _cl[_k] != "") ? real(_cl[_k]) : c_white); }
			if (array_length(_sids) == 0 || array_length(_names) != array_length(_sids)) continue;
			// the finds
			var _yng = [];   // the young tagging along (2026-09-16)
			if ((_kv[$ "yg"] ?? "") != "") { var _yl = string_split(_kv.yg, ","); for (var _yi = 0; _yi < array_length(_yl); _yi++) array_push(_yng, real(_yl[_yi])); }
			var _finds = [];
			var _fsv = _kv[$ "finds"] ?? "";
			if (_fsv != "") {
				var _fl2 = string_split(_fsv, ",");
				for (var _i = 0; _i < array_length(_fl2); _i++) {
					var _q = string_split(_fl2[_i], ":");
					if (array_length(_q) < 5) continue;
					var _l = { kind : _q[0], rar : real(_q[1]), n : real(_q[2]), fam : _q[3], tier : real(_q[4]), txt : "", col : c_white };
					if (variable_global_exists("rarity_old") && g.rarity_old) _l.rar = rarity_remap8(_l.rar);   // (DE's eight -> the fourteen)
					var _rinfo = upgrade_rarity_info(_l.rar);
					switch (_l.kind) {
						case "mats":    _l.txt = string(_l.n) + " " + _l.fam + " (t" + string(_l.tier) + ")"; _l.col = _rinfo.col; break;
						case "sprite":  _l.txt = "a sprite, asleep"; _l.col = _rinfo.col; break;
						case "egg":     _l.txt = "a " + _l.fam + " egg, warm"; _l.col = _l.n; break;   // (n = its colour, fam = the word, tier = its seed; 2026-09-16)
						case "offer":   _l.txt = "an upgrade offer (" + _rinfo.name + ")"; _l.col = _rinfo.col; break;
						case "charm":   _l.txt = "a charm (+1 luck)"; _l.col = c_seagreen; break;
						case "chart":   _l.txt = "a chart fragment"; _l.col = c_sblue; break;
						case "gear":    _l.txt = "an item - its finder dealt with it"; _l.col = _rinfo.col; break;   // (taken on the spot; nothing to collect)
						default:        _l.txt = string(_l.n) + " credits"; _l.col = c_lavender; break;
					}
					array_push(_finds, _l);
				}
			}
			// the crew's lines
			var _hh = string_split(_kv[$ "hp"] ?? "", "~");
			var _hp = [], _hm = [], _mp = [];
			var _h1 = (array_length(_hh) >= 1) ? string_split(_hh[0], ",") : [], _h2 = (array_length(_hh) >= 2) ? string_split(_hh[1], ",") : [], _h3 = (array_length(_hh) >= 3) ? string_split(_hh[2], ",") : [];
			for (var _k = 0; _k < array_length(_sids); _k++) {
				array_push(_hm, (_k < array_length(_h2) && _h2[_k] != "") ? max(1, real(_h2[_k])) : 10);
				array_push(_hp, (_k < array_length(_h1) && _h1[_k] != "") ? real(_h1[_k]) : _hm[_k]);
				array_push(_mp, (_k < array_length(_h3) && _h3[_k] != "") ? clamp(real(_h3[_k]), 0, 1) : 1);
			}
			// the tally
			var _tl = { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 };
			var _tf = string_split(_kv[$ "tl"] ?? "", ":");
			if (array_length(_tf) >= 5) _tl = { slain : real(_tf[0]), mist : real(_tf[1]), items : real(_tf[2]), xp : real(_tf[3]), earned : real(_tf[4]) };
			var _id = real(_kv[$ "id"] ?? "0");
			var _rgi = clamp(real(_kv[$ "rgi"] ?? "0"), 0, EXPED_REGIONS - 1);
			var _routed = ((_kv[$ "rt"] ?? "0") == "1");
			if (_kind == "H") {
				array_push(_e.hauls, { id : _id, dest : _d, sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0], young : _yng,
				                       finds : _finds, routed : _routed, cleared : real(_kv[$ "cl"] ?? "0"), wins : real(_kv[$ "w"] ?? "0"), log : (((_kv[$ "lg"] ?? "") != "") ? string_split(_kv.lg, "^") : [ "home" ]), hp : _hp, hpmax : _hm, mp : _mp,
				                       rgi : _rgi, tl : _tl, pocket : real(_kv[$ "pk"] ?? "0"), stance : exped_stance(_kv[$ "stn"] ?? "steady").key,
				                       best : ((_kv[$ "bt"] ?? "") != "") ? { title : _kv.bt, line : _kv[$ "bm"] ?? "" } : undefined });
				continue;
			}
			// a trip
			var _rooms = ((_kv[$ "rooms"] ?? "") != "") ? string_split(_kv.rooms, ",") : [];
			if (array_length(_rooms) < EXPED_ROOMS) {
				var _bi = exped_biomes()[clamp(_d.biome, 0, 3)];
				while (array_length(_rooms) < EXPED_ROOMS) array_push(_rooms, exped_pick(_bi.rooms));
			}
			var _t0 = real(_kv[$ "t"] ?? "0");
			var _rgn = array_length(region_get(_d, _rgi).nodes);
			var _trn = {
				id : _id, dest : _d, sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
				t : _t0, dur : _d.dist, stage : real(_kv[$ "st"] ?? "0"),
				rooms : _rooms, room_i : real(_kv[$ "ri"] ?? "-1"), cleared : real(_kv[$ "cl"] ?? "0"),
				hp : _hp, hpmax : _hm, mp : _mp,
				fight : undefined, routed : _routed, rout_t : _t0,
				finds : _finds, log : [ "on the way to " + _d.name + " (the diary's earlier pages did not survive the save)" ],
				threads : ((_kv[$ "thr"] ?? "") != "") ? string_split(_kv.thr, ",") : [], said_travel : ((_kv[$ "sd"] ?? "0") == "1"), wins : real(_kv[$ "w"] ?? "0"),
				young : _yng,
				mode : ((_kv[$ "mode"] ?? "quest") == "explore") ? "explore" : "quest", quest : undefined,
				pos : clamp(real(_kv[$ "pos"] ?? "0"), 0, _rgn - 1), path : [], road : undefined, act : undefined,
				credits : real(_kv[$ "cr"] ?? "0"), recall : ((_kv[$ "rc"] ?? "0") == "1"), visited : [], planet_t : real(_kv[$ "pt"] ?? "0"), bounty : undefined,
				leave_t : real(_kv[$ "lt"] ?? string(_t0)), fights : 0, rgi : _rgi, home : clamp(real(_kv[$ "home"] ?? "0"), 0, _rgn - 1),
				ex : { kind : "wander", n : 0 }, tl : _tl, stance : exped_stance(_kv[$ "stn"] ?? "steady").key,
			};
			if (_trn.mode == "quest" && _trn.recall) _trn.aborted = true;   // (a quest crew recalled is an aborted one - the flag itself is not saved)
			var _exs = string_split(_kv[$ "ex"] ?? "", ":");
			if (array_length(_exs) >= 2 && _exs[0] != "") _trn.ex = { kind : _exs[0], n : real(_exs[1]) };
			var _vsv = _kv[$ "vis"] ?? "";
			if (_vsv != "") { var _vs = string_split(_vsv, ";"); for (var _vi = 0; _vi < array_length(_vs); _vi++) if (_vs[_vi] != "") array_push(_trn.visited, clamp(real(_vs[_vi]), 0, _rgn - 1)); }
			if (array_length(_trn.visited) == 0) _trn.visited = [ _trn.home ];
			// the quest
			if ((_kv[$ "qk"] ?? "") != "") {
				var _rgq = region_get(_d, _rgi);
				var _qn = clamp(real(_kv[$ "qn"] ?? "0"), 0, array_length(_rgq.nodes) - 1);
				var _qfr = real(_kv[$ "qfr"] ?? "-1");
				_trn.quest = { kind : _kv.qk, node : _qn, foe : foe_legacy(_kv[$ "qf"] ?? ""), n : real(_kv[$ "qc"] ?? "1"), done : real(_kv[$ "qd"] ?? "0"), mult : real(_kv[$ "qm"] ?? "1"), reward : real(_kv[$ "qr"] ?? "0"), hours : 0,
				               from : (_qfr < 0) ? -1 : clamp(_qfr, 0, array_length(_rgq.nodes) - 1), at : real(_kv[$ "qat"] ?? "0"), who : _kv[$ "qw"] ?? "", nodes : undefined, txt : "",
				               pers : real(_kv[$ "qps"] ?? "0"), pnote : _kv[$ "qpn"] ?? "", vil : real(_kv[$ "qvl"] ?? "0") };
				if ((_kv[$ "qaf"] ?? "0") == "1") _trn.after_done = true;
				var _qnsv = _kv[$ "qns"] ?? "";
				if (_qnsv != "") { var _qns = string_split(_qnsv, ";"), _qnl = []; for (var _qi = 0; _qi < array_length(_qns); _qi++) if (_qns[_qi] != "") array_push(_qnl, clamp(real(_qns[_qi]), 0, array_length(_rgq.nodes) - 1)); if (array_length(_qnl) > 0) _trn.quest.nodes = _qnl; }
				_trn.quest.p0 = (_trn.quest.from >= 0) ? _trn.quest.from : (is_array(_trn.quest.nodes) ? _trn.quest.nodes[0] : _qn);
				_trn.quest.txt = exped_quest_txt(_trn.quest, _rgq);   // (the one builder - the line reads as it did)
			}
			// the bounty
			if ((_kv[$ "bf"] ?? "") != "") _trn.bounty = { node : clamp(real(_kv[$ "bn"] ?? "0"), 0, _rgn - 1), foe : foe_legacy(_kv.bf), n : real(_kv[$ "bc"] ?? "1"), done : real(_kv[$ "bd"] ?? "0"), pay : real(_kv[$ "bp"] ?? "0") };
			array_push(_e.trips, _trn);
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
