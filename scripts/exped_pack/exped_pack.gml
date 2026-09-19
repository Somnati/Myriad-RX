/// @description exped_pack() -> the trips and the hauls as one string (the save's "ex_trip")
/// KEYED (his pick, 2026-09-16: "the save is positional... one wrong colon
/// loses a trip"): a record is `key=value` fields joined by `|`, records
/// joined by `#`, the first field `v=2`. A field missing reads as its
/// default (exped_unpack), a field unknown is skipped, so a field can be
/// ADDED in any round without a migration and the order never matters.
/// The lists inside a value keep their old separators (`,` `~` `:` `;`) -
/// those are append-only, and the reader checks their counts. A save from
/// before (the positional form) reads through exped_unpack_v1.
///   k       T (a trip) / H (a haul)              id      the record's id
///   dest    seed:biome:tier:dist:rate:name       crew    sids~names~cols
///   t st ri cl rt w sd   the clock, the stage, room_i, cleared, routed, wins, said_travel
///   hp      hp~hpmax~mp (the crew's lines)       rooms   the old delve's rooms (a trip)
///   finds   kind:rar:n:fam:tier,...              thr     the voice's threads (a trip)
///   mode pos cr rc lt pt rgi home   the agent: mode, node, credits, recall, leave_t, planet_t, region, landing
///   ex      the explore card kind:n              vis     the nodes visited, ;-joined
///   qk qn qf qc qd qm qr qfr qat qw qns   the quest: kind, node, foe, n, done, mult, reward, from, at, who, nodes(;)
///   bn bf bc bd bp   the bounty: node, foe, n, done, pay
///   tl      slain:mist:items:xp:earned           pk      the pocket (a trip: its credits now; a haul: what came home)
///   stn     the stance (cautious / steady / greedy - exped_stance; a haul keeps it for [send again])
///   qps qpn qaf   a personal card's quest (1), its note, and whether the quest's after-moment (gratitude, the follow-up) already ran
///   qvl     the villain thread's stage on the quest     bt bm   a haul's best moment: its title, its line     lg   a haul's diary, its last hundred and twenty lines (^)
/// A fight in progress replays its room on load (room_i steps back one).
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
		var _f = [];   // the fields, "key=value"
		array_push(_f, "v=2");
		array_push(_f, "k=" + (_is ? "T" : "H"));
		array_push(_f, "id=" + string(_r.id));
		array_push(_f, "dest=" + string(_d.seed) + ":" + string(_d.biome) + ":" + string(_d.tier) + ":" + string(_d.dist) + ":" + string(_d.rate) + ":" + _d.name);
		array_push(_f, "dst=" + string(_d[$ "star"] ?? -1) + ":" + string(_d[$ "pl"] ?? -1));   // (the world's star on the map, 2026-09-16)
		var _si = "", _sn = "", _sc = "";
		for (var _k = 0; _k < array_length(_r.sids); _k++) {
			_si += ((_k > 0) ? "," : "") + string(_r.sids[_k]);
			_sn += ((_k > 0) ? "," : "") + _r.names[_k];
			_sc += ((_k > 0) ? "," : "") + string(_r.cols[_k]);
		}
		array_push(_f, "crew=" + _si + "~" + _sn + "~" + _sc);
		array_push(_f, "t=" + string(_is ? _r.t : 0));
		array_push(_f, "st=" + string(_is ? _r.stage : 2));
		array_push(_f, "ri=" + string(_is ? (_r.room_i - (is_undefined(_r.fight) ? 0 : 1)) : 0));
		array_push(_f, "cl=" + string(_r.cleared));
		array_push(_f, "rt=" + (_r.routed ? "1" : "0"));
		array_push(_f, "w=" + string(_r[$ "wins"] ?? 0));
		array_push(_f, "sd=" + ((_is ? (_r[$ "said_travel"] ?? false) : true) ? "1" : "0"));
		var _hp = "", _hm = "", _mpp = "";
		var _rhp = _r[$ "hp"] ?? [], _rhm = _r[$ "hpmax"] ?? [], _rmp = _r[$ "mp"] ?? [];
		for (var _k = 0; _k < array_length(_rhp); _k++) {
			_hp  += ((_k > 0) ? "," : "") + string(_rhp[_k]);
			_hm  += ((_k > 0) ? "," : "") + string((_k < array_length(_rhm)) ? _rhm[_k] : 10);
			_mpp += ((_k > 0) ? "," : "") + string_format((_k < array_length(_rmp)) ? _rmp[_k] : 1, 1, 3);
		}
		array_push(_f, "hp=" + _hp + "~" + _hm + "~" + _mpp);
		if (_is) array_push(_f, "rooms=" + string_join_ext(",", _r.rooms));
		var _fs = "";
		for (var _i = 0; _i < array_length(_r.finds); _i++) {
			var _l = _r.finds[_i];
			_fs += ((_i > 0) ? "," : "") + _l.kind + ":" + string(_l.rar) + ":" + string(_l[$ "n"] ?? 0) + ":" + (_l[$ "fam"] ?? "") + ":" + string(_l[$ "tier"] ?? 0);
		}
		array_push(_f, "finds=" + _fs);
		if (_is) array_push(_f, "thr=" + string_join_ext(",", _r[$ "threads"] ?? []));
		if (is_array(_r[$ "young"]) && array_length(_r.young) > 0) { var _ys = ""; for (var _yi = 0; _yi < array_length(_r.young); _yi++) _ys += ((_yi > 0) ? "," : "") + string(_r.young[_yi]); array_push(_f, "yg=" + _ys); }   // (the young tagging along, 2026-09-16)
		array_push(_f, "rgi=" + string(_r[$ "rgi"] ?? 0));
		if (_is) {
			// THE AGENT: a trip reloads standing at its node (the road and the activity start over; the quest's text is rebuilt)
			array_push(_f, "mode=" + string(_r[$ "mode"] ?? "quest"));
			array_push(_f, "pos=" + string(_r[$ "pos"] ?? 0));
			array_push(_f, "cr=" + string(_r[$ "credits"] ?? 0));
			array_push(_f, "rc=" + ((_r[$ "recall"] ?? false) ? "1" : "0"));
			array_push(_f, "lt=" + string(_r[$ "leave_t"] ?? 0));
			array_push(_f, "pt=" + string(_r[$ "planet_t"] ?? 0));
			array_push(_f, "home=" + string(_r[$ "home"] ?? 0));
			var _rex = _r[$ "ex"]; if (!is_struct(_rex)) _rex = { kind : "wander", n : 0 };
			array_push(_f, "ex=" + _rex.kind + ":" + string(_rex.n));
			var _vv = _r[$ "visited"] ?? [], _vis = "";
			for (var _vi = 0; _vi < array_length(_vv); _vi++) _vis += ((_vi > 0) ? ";" : "") + string(_vv[_vi]);
			array_push(_f, "vis=" + _vis);
			var _q = _r[$ "quest"];
			if (is_struct(_q)) {
				array_push(_f, "qk=" + _q.kind);
				array_push(_f, "qn=" + string(_q.node));
				array_push(_f, "qf=" + _q.foe);
				array_push(_f, "qc=" + string(_q.n));
				array_push(_f, "qd=" + string(_q.done));
				array_push(_f, "qm=" + string(_q.mult));
				array_push(_f, "qr=" + string(_q.reward));
				array_push(_f, "qfr=" + string(_q[$ "from"] ?? -1));
				array_push(_f, "qat=" + string(_q[$ "at"] ?? 0));
				array_push(_f, "qw=" + string(_q[$ "who"] ?? ""));
				array_push(_f, "qns=" + (is_array(_q[$ "nodes"]) ? string_join_ext(";", _q.nodes) : ""));
				array_push(_f, "qps=" + string(_q[$ "pers"] ?? 0));   // (a personal card's quest, 2026-09-16)
				array_push(_f, "qvl=" + string(_q[$ "vil"] ?? 0));   // (the villain thread's stage, 2026-09-16)
				array_push(_f, "qpn=" + string_replace_all(string(_q[$ "pnote"] ?? ""), "|", " "));
				array_push(_f, "qaf=" + ((_r[$ "after_done"] ?? false) ? "1" : "0"));
			}
			var _bo = _r[$ "bounty"];
			if (is_struct(_bo)) {
				array_push(_f, "bn=" + string(_bo.node));
				array_push(_f, "bf=" + _bo.foe);
				array_push(_f, "bc=" + string(_bo.n));
				array_push(_f, "bd=" + string(_bo.done));
				array_push(_f, "bp=" + string(_bo.pay));
			}
		}
		// THE TALLY (2026-09-16): slain:mist:items:xp:earned, and the pocket
		var _tl = _r[$ "tl"]; if (!is_struct(_tl)) _tl = { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 };
		array_push(_f, "tl=" + string(_tl.slain) + ":" + string(_tl.mist) + ":" + string(_tl.items) + ":" + string_format(_tl.xp, 1, 2) + ":" + string(_tl.earned));
		array_push(_f, "pk=" + string(_is ? (_r[$ "credits"] ?? 0) : (_r[$ "pocket"] ?? 0)));
		array_push(_f, "stn=" + string(_r[$ "stance"] ?? "steady"));   // (the stance, 2026-09-16)
		array_push(_f, "fk=" + string(_r[$ "fork_n"] ?? 0) + ":" + string_format(_r[$ "fork_t"] ?? -1000000, 1, 1));   // (the forks' cadence - count and the world time of the last; q258)
		if (!_is && is_array(_r[$ "log"])) {   // THE DIARY of a haul (2026-09-16: [read the diary] on the home page): its last hundred and twenty lines, ^-joined
			var _lg = "", _l0 = max(0, array_length(_r.log) - 120);
			for (var _li = _l0; _li < array_length(_r.log); _li++) _lg += ((_li > _l0) ? "^" : "") + string_replace_all(string_replace_all(string_replace_all(string_replace_all(_r.log[_li], "|", " "), "#", " "), "^", " "), "\"", "'");
			array_push(_f, "lg=" + _lg);
		}
		if (!_is && is_struct(_r[$ "best"])) {   // THE BEST MOMENT (a haul, 2026-09-16): its title and its line
			array_push(_f, "bt=" + string_replace_all(string_replace_all(string_replace_all(_r.best.title, "|", " "), "#", " "), "\"", "'"));
			array_push(_f, "bm=" + string_replace_all(string_replace_all(string_replace_all(_r.best.line, "|", " "), "#", " "), "\"", "'"));   // (a diary line may quote: the save is an ini - bug hunt 2026-09-16)
		}
		_out += ((_a > 0) ? "#" : "") + string_join_ext("|", _f);
	}
	return _out;
}
