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
			if (_p[0] == "H") {
				array_push(_e.hauls, { id : _id, dest : _d, sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
				                       finds : _finds, routed : (_tt[4] == "1"), cleared : real(_tt[3]), wins : real(_tt[5]), log : [ "home" ] });
				continue;
			}
			var _hh = string_split(_p[4], "~");
			var _hp = [], _hm = [];
			if (array_length(_hh) >= 2) {
				var _h1 = string_split(_hh[0], ","), _h2 = string_split(_hh[1], ",");
				for (var _k = 0; _k < array_length(_sids); _k++) {
					array_push(_hm, (_k < array_length(_h2) && _h2[_k] != "") ? max(1, real(_h2[_k])) : 10);
					array_push(_hp, (_k < array_length(_h1) && _h1[_k] != "") ? real(_h1[_k]) : _hm[_k]);
				}
			} else for (var _k = 0; _k < array_length(_sids); _k++) { array_push(_hp, 10); array_push(_hm, 10); }
			var _rooms = (_p[5] != "") ? string_split(_p[5], ",") : [];
			if (array_length(_rooms) < EXPED_ROOMS) {
				var _bi = exped_biomes()[clamp(_d.biome, 0, 3)];
				while (array_length(_rooms) < EXPED_ROOMS) array_push(_rooms, exped_pick(_bi.rooms));
			}
			array_push(_e.trips, {
				id : _id, dest : _d, sids : _sids, names : _names, cols : _cols, sid : _sids[0], sname : _names[0],
				t : real(_tt[0]), dur : _d.dist, stage : real(_tt[1]),
				rooms : _rooms, room_i : real(_tt[2]), cleared : real(_tt[3]),
				hp : _hp, hpmax : _hm,
				fight : undefined, routed : (_tt[4] == "1"), rout_t : real(_tt[0]),
				finds : _finds, log : [ "on the way to " + _d.name + " (the diary's earlier pages did not survive the save)" ],
				threads : (_p[7] != "") ? string_split(_p[7], ",") : [], said_travel : (_tt[6] == "1"), wins : real(_tt[5]),
			});
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
