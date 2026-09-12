/// @description exped_unpack(str) - the save's trip / haul back into g.exped
/// @param str
function exped_unpack(_s) {
	exped_init();
	var _e = g.exped;
	_e.trip = undefined; _e.haul = undefined;
	if (!is_string(_s) || _s == "") return;
	var _p = string_split(_s, "|");
	if (array_length(_p) < 6) return;
	var _dd = string_split(_p[1], ":", false, 5);
	if (array_length(_dd) < 6) return;
	var _d = { seed : real(_dd[0]), biome : real(_dd[1]), tier : real(_dd[2]), dist : real(_dd[3]), rate : real(_dd[4]), name : _dd[5] };
	var _cc = string_split(_p[2], ":", false, 1);
	var _sid = real(_cc[0]), _sname = (array_length(_cc) > 1) ? _cc[1] : "?";
	var _tt = string_split(_p[3], ":");
	var _finds = [];
	if (_p[5] != "") {
		var _fl = string_split(_p[5], ",");
		for (var _i = 0; _i < array_length(_fl); _i++) {
			var _q = string_split(_fl[_i], ":");
			if (array_length(_q) < 5) continue;
			var _l = { kind : _q[0], rar : real(_q[1]), n : real(_q[2]), fam : _q[3], tier : real(_q[4]), txt : "", col : c_white };
			// the words come back from the kind
			var _ri = upgrade_rarity_info(_l.rar);
			switch (_l.kind) {
				case "mats":    _l.txt = string(_l.n) + " " + _l.fam + " (t" + string(_l.tier) + ")"; _l.col = _ri.col; break;
				case "sprite":  _l.txt = "a sprite, asleep"; _l.col = _ri.col; break;
				case "offer":   _l.txt = "an upgrade offer (" + _ri.name + ")"; _l.col = _ri.col; break;
				case "charm":   _l.txt = "a charm (+1 luck)"; _l.col = c_seagreen; break;
				case "chart":   _l.txt = "a chart fragment"; _l.col = c_sblue; break;
				default:        _l.txt = string(_l.n) + " credits"; _l.col = c_lavender; break;
			}
			array_push(_finds, _l);
		}
	}
	if (_p[0] == "H") {
		_e.haul = { dest : _d, sname : _sname, sid : _sid, finds : _finds,
		            routed : (array_length(_tt) > 6 && _tt[6] == "1"),
		            cleared : (array_length(_tt) > 5) ? real(_tt[5]) : 0, log : [ "home" ] };
		return;
	}
	var _rooms = (_p[4] != "") ? string_split(_p[4], ",") : [];
	if (array_length(_rooms) < EXPED_ROOMS) {
		var _bi = exped_biomes()[clamp(_d.biome, 0, 3)];
		while (array_length(_rooms) < EXPED_ROOMS) array_push(_rooms, exped_pick(_bi.rooms));
	}
	_e.trip = {
		dest : _d, sid : _sid, sname : _sname,
		t : real(_tt[0]), dur : _d.dist, stage : real(_tt[1]),
		rooms : _rooms, room_i : real(_tt[2]), cleared : real(_tt[5]),
		hp : real(_tt[3]), hpmax : max(1, real(_tt[4])),
		fight : undefined, routed : (_tt[6] == "1"), rout_t : real(_tt[0]),
		finds : _finds, log : [ "on the way to " + _d.name ],
	};
	_e.log = _e.trip.log;
	// the crew is still away
	for (var _i = 0; _i < array_length(g.sprites); _i++)
		if (g.sprites[_i].id == _sid) g.sprites[_i].trip = true;
}
