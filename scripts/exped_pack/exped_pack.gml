/// @description exped_pack() -> every trip and haul as one string for
/// the save: records joined by "#", fields by "|":
///   T/H | dest seed:biome:tier:dist:rate:name | sids~names~cols (","
///   inside each) | t:stage:room_i:cleared:routed:wins:said_travel:id |
///   hp,..~hpmax,.. | rooms | finds | threads
/// A fight in progress replays its room on load (room_i steps back one).
/// exped_unpack reads it; the logs are not kept (a line says so).
function exped_pack() {
	exped_init();
	var _e = g.exped;
	var _out = "";
	var _all = [];
	for (var _i = 0; _i < array_length(_e.trips); _i++) array_push(_all, { r : _e.trips[_i], t : true });
	for (var _i = 0; _i < array_length(_e.hauls); _i++) array_push(_all, { r : _e.hauls[_i], t : false });
	for (var _a = 0; _a < array_length(_all); _a++) {
		var _r = _all[_a].r, _is = _all[_a].t;
		var _d = _r.dest;
		var _o = _is ? "T" : "H";
		_o += "|" + string(_d.seed) + ":" + string(_d.biome) + ":" + string(_d.tier) + ":" + string(_d.dist) + ":" + string(_d.rate) + ":" + _d.name;
		var _si = "", _sn = "", _sc = "";
		for (var _k = 0; _k < array_length(_r.sids); _k++) {
			_si += ((_k > 0) ? "," : "") + string(_r.sids[_k]);
			_sn += ((_k > 0) ? "," : "") + _r.names[_k];
			_sc += ((_k > 0) ? "," : "") + string(_r.cols[_k]);
		}
		_o += "|" + _si + "~" + _sn + "~" + _sc;
		if (_is) {
			var _ri = _r.room_i - (is_undefined(_r.fight) ? 0 : 1);
			_o += "|" + string(_r.t) + ":" + string(_r.stage) + ":" + string(_ri) + ":" + string(_r.cleared) + ":" + (_r.routed ? "1" : "0")
			    + ":" + string(_r[$ "wins"] ?? 0) + ":" + ((_r[$ "said_travel"] ?? false) ? "1" : "0") + ":" + string(_r.id);
			var _hp = "", _hm = "", _mpp = "";
			var _rmp = _r[$ "mp"] ?? [];
			for (var _k = 0; _k < array_length(_r.hp); _k++) { _hp += ((_k > 0) ? "," : "") + string(_r.hp[_k]); _hm += ((_k > 0) ? "," : "") + string(_r.hpmax[_k]); _mpp += ((_k > 0) ? "," : "") + string_format((_k < array_length(_rmp)) ? _rmp[_k] : 1, 1, 3); }
			_o += "|" + _hp + "~" + _hm + "~" + _mpp;   // (mp fractions: a third part, 2026-09-15)
			_o += "|" + string_join_ext(",", _r.rooms);
		} else {
			_o += "|0:2:0:" + string(_r.cleared) + ":" + (_r.routed ? "1" : "0") + ":" + string(_r[$ "wins"] ?? 0) + ":1:" + string(_r.id);
			// the crew's hp at the end (the haul card's banners, 2026-09-15)
			var _hhp = "", _hhm = "", _hmp = "";
			var _rhp = _r[$ "hp"] ?? [], _rhm = _r[$ "hpmax"] ?? [], _rmp2 = _r[$ "mp"] ?? [];
			for (var _k = 0; _k < array_length(_rhp); _k++) { _hhp += ((_k > 0) ? "," : "") + string(_rhp[_k]); _hhm += ((_k > 0) ? "," : "") + string((_k < array_length(_rhm)) ? _rhm[_k] : 10); _hmp += ((_k > 0) ? "," : "") + string_format((_k < array_length(_rmp2)) ? _rmp2[_k] : 1, 1, 3); }
			_o += "|" + _hhp + "~" + _hhm + "~" + _hmp;
			_o += "|";
		}
		var _f = "";
		for (var _i = 0; _i < array_length(_r.finds); _i++) {
			var _l = _r.finds[_i];
			_f += ((_i > 0) ? "," : "") + _l.kind + ":" + string(_l.rar) + ":" + string(_l[$ "n"] ?? 0) + ":" + (_l[$ "fam"] ?? "") + ":" + string(_l[$ "tier"] ?? 0);
		}
		_o += "|" + _f;
		_o += "|" + (_is ? string_join_ext(",", _r[$ "threads"] ?? []) : "");
		// THE AGENT (slice three, field 8): mode:pos:credits:recall:leave_t:planet_t:qkind:qnode:qfoe:qn:qdone:qmult:qreward:bnode:bfoe:bn:bdone:bpay:visited(;)
		// a trip reloads standing at its node (the road and the activity start over; the quest's text is rebuilt)
		if (_is) {
			var _q = _r[$ "quest"], _bo = _r[$ "bounty"];
			var _rex = _r[$ "ex"]; if (!is_struct(_rex)) _rex = { kind : "wander", n : 0 };
			var _vv = _r[$ "visited"] ?? [], _vis = "";
			for (var _vi = 0; _vi < array_length(_vv); _vi++) _vis += ((_vi > 0) ? ";" : "") + string(_vv[_vi]);
			_o += "|" + string(_r[$ "mode"] ?? "quest") + ":" + string(_r[$ "pos"] ?? 0) + ":" + string(_r[$ "credits"] ?? 0) + ":" + ((_r[$ "recall"] ?? false) ? "1" : "0")
			    + ":" + string(_r[$ "leave_t"] ?? 0) + ":" + string(_r[$ "planet_t"] ?? 0)
			    + ":" + (is_struct(_q) ? (_q.kind + ":" + string(_q.node) + ":" + _q.foe + ":" + string(_q.n) + ":" + string(_q.done) + ":" + string(_q.mult) + ":" + string(_q.reward)) : "::::::")
			    + ":" + (is_struct(_bo) ? (string(_bo.node) + ":" + _bo.foe + ":" + string(_bo.n) + ":" + string(_bo.done) + ":" + string(_bo.pay)) : "::::")
			    + ":" + _vis
			    + ":" + string(_r[$ "rgi"] ?? 0) + ":" + string(_r[$ "home"] ?? 0)   // (the region, the landing zone - 2026-09-15)
			    + ":" + _rex.kind + ":" + string(_rex.n)   // (the explore card: kind, n - 2026-09-15)
			    + ":" + (is_struct(_q) ? (string(_q[$ "from"] ?? -1) + ":" + string(_q[$ "at"] ?? 0) + ":" + string(_q[$ "who"] ?? "") + ":" + (is_array(_q[$ "nodes"]) ? string_join_ext(";", _q.nodes) : "")) : ":::");   // (the mission-type pass: from, at, who, the survey's nodes - 2026-09-15)
		} else _o += "|" + string(_r[$ "rgi"] ?? 0);   // (a haul: its region - 2026-09-15)
		// THE TALLY (field 9, 2026-09-16): slain:mist:items:xp:earned:pocket
		var _tl = _r[$ "tl"]; if (!is_struct(_tl)) _tl = { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 };
		_o += "|" + string(_tl.slain) + ":" + string(_tl.mist) + ":" + string(_tl.items) + ":" + string_format(_tl.xp, 1, 2) + ":" + string(_tl.earned) + ":" + string(_is ? (_r[$ "credits"] ?? 0) : (_r[$ "pocket"] ?? 0));
		_out += ((_a > 0) ? "#" : "") + _o;
	}
	return _out;
}
