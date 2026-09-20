/// @description region_ledger(dest, ri) -> [{ k, v, col, bar }] THE REGION'S LEDGER for the [influence] view (q270): weight, the six lanes (bar = -1..1), the seat, the leaderless, the scars, the memories, the event
function region_ledger(_d, _ri) {
	var _rg = region_get(_d, _ri), _out = [];
	array_push(_out, { k : "weight", v : string_format(region_weight(_rg), 1, 2) + "  (a push is divided by it, a recovery multiplied)", col : sett_ink });
	var _r = lane_get(_d, _ri, false), _nm = lane_names();
	static _w = {
		order   : [ "the roads worse",             "the roads quieter" ],
		wild    : [ "the beasts thin",             "the beasts back" ],
		trade   : [ "trade down",                  "trade up" ],
		faith   : [ "the dead restless",           "the dead quiet" ],
		welcome : [ "unwelcome here",              "welcomed here" ],
		dread   : [ "the villain's grip loosened", "the villain's grip tightened" ],
	};
	static _bad = { order : 0, wild : 1, trade : 0, faith : 0, welcome : 0, dread : 1 };
	for (var _j = 0; _j < array_length(_nm); _j++) {
		var _v = is_struct(_r) ? (_r[$ _nm[_j]] ?? 0) : 0;
		var _word = (abs(_v) < .05) ? "at rest" : _w[$ _nm[_j]][(_v > 0) ? 1 : 0];
		var _isbad = (abs(_v) >= .05) && ((_bad[$ _nm[_j]] == 1) ? (_v > 0) : (_v < 0));
		array_push(_out, { k : _nm[_j], v : ((_v >= 0) ? "+" : "") + string_format(_v, 1, 2) + "  " + _word, col : (abs(_v) < .05) ? sett_ink : (_isbad ? c_horange : c_seagreen), bar : _v });
	}
	var _seat = seat_get(_d, _ri), _vil = region_villain(_d, _rg);
	if (is_struct(_seat) && _seat.left > 0) array_push(_out, { k : "seat", v : "empty - a successor in " + string(max(1, ceil(_seat.left / (24 * EXPED_HOUR)))) + " days (the " + string(_seat.n + 1) + ((_seat.n + 1 == 2) ? "nd" : ((_seat.n + 1 == 3) ? "rd" : "th")) + " to hold it)", col : c_seagreen });
	else if (is_struct(_vil)) array_push(_out, { k : "seat", v : _vil.name + ", " + (_vil[$ "rank"] ?? "chief") + " of " + _vil.fac + (((_vil[$ "n"] ?? 0) > 0) ? " (the " + string(_vil.n + 1) + ((_vil.n + 1 == 2) ? "nd" : ((_vil.n + 1 == 3) ? "rd" : "th")) + " to hold it)" : ""), col : c_hred });
	else array_push(_out, { k : "seat", v : "no villain here", col : sett_ink });
	if (is_struct(g.exped[$ "seat"])) {
		var _lk0 = lane_key(_d, _ri) + ":", _lks = variable_struct_get_names(g.exped.seat), _lrow = "";
		for (var _i = 0; _i < array_length(_lks); _i++) {
			if (string_pos(_lk0, _lks[_i]) != 1) continue;
			var _ls = g.exped.seat[$ _lks[_i]];
			if (_ls.left <= 0) continue;
			_lrow += ((_lrow != "") ? ", " : "") + string_delete(_lks[_i], 1, string_length(_lk0)) + " (" + string(max(1, ceil(_ls.left / (24 * EXPED_HOUR)))) + "d, x" + string(FOE_LEADERLESS) + ")";
		}
		array_push(_out, { k : "leaderless", v : (_lrow != "") ? _lrow : "nobody", col : (_lrow != "") ? c_seagreen : sett_ink });
	}
	// FACTION STRENGTH (q283): every kind hit here - heads over the base, and the word
	if (is_struct(g.exped[$ "fac"])) {
		var _fk0 = lane_key(_d, _ri) + ":", _fks = variable_struct_get_names(g.exped.fac), _fany = false;
		for (var _i = 0; _i < array_length(_fks); _i++) {
			if (string_pos(_fk0, _fks[_i]) != 1) continue;
			var _fkd = string_delete(_fks[_i], 1, string_length(_fk0)), _ff = faction_get(_d, _ri, _fkd, _rg), _fw = faction_word(_ff.str);
			array_push(_out, { k : foe_plural(_fkd), v : string(round(_ff.hp)) + " of " + string(_ff.base) + " - " + _fw.txt, col : _fw.col, bar : _ff.str * 2 - 1 });
			_fany = true;
		}
		if (!_fany) array_push(_out, { k : "factions", v : "none hunted here - all at strength", col : sett_ink });
	}
	// POPULATION (q284): every settled place, its number live, the pushed ones marked
	for (var _pi = 1; _pi < array_length(_rg.nodes); _pi++) {
		var _lpp = region_pop(_d, _rg, _pi);
		if (is_undefined(_lpp)) continue;
		var _pw = pop_word(_lpp);
		array_push(_out, { k : _rg.nodes[_pi].name, v : _pw.txt + ((abs(_lpp.dev) >= .01) ? " [" + ((_lpp.dev > 0) ? "+" : "") + string(round(_lpp.dev * 100)) + "%]" : ""), col : _pw.col, bar : clamp(_lpp.dev / POP_DEV_MAX, -1, 1) });
	}
	var _scs = scar_get(_d, _ri), _srow = "";
	for (var _i = 0; _i < array_length(_scs); _i++) if (_scs[_i].n >= 0 && _scs[_i].n < array_length(_rg.nodes)) _srow += ((_srow != "") ? "; " : "") + _rg.nodes[_scs[_i].n].name + ": " + (_scs[_i][$ "was"] ?? "") + " -> " + _scs[_i].k;
	array_push(_out, { k : "scars", v : (_srow != "") ? _srow : "none (a lane held past .7 for two world days lands one; three a region)", col : (_srow != "") ? c_gold : sett_ink });
	var _mm = g.exped[$ "mem"], _mrow = "";
	if (is_struct(_mm)) {
		var _mk0 = string(_d.seed) + ":" + string(_ri) + ":", _mks = variable_struct_get_names(_mm);
		for (var _i = 0; _i < array_length(_mks); _i++) {
			if (string_pos(_mk0, _mks[_i]) != 1) continue;
			var _me = _mm[$ _mks[_i]], _kv = string_split(_mks[_i], ":");
			if (array_length(_kv) < 4 || _kv[3] == "event") continue;
			var _nn = real(_kv[2]);
			_mrow += ((_mrow != "") ? ", " : "") + _kv[3] + ((_nn >= 0 && _nn < array_length(_rg.nodes)) ? " at " + _rg.nodes[_nn].name : "") + " (" + string(max(1, ceil(_me.left / EXPED_HOUR))) + "h)";
		}
	}
	array_push(_out, { k : "memories", v : (_mrow != "") ? _mrow : "none", col : (_mrow != "") ? c_lavender : sett_ink });
	var _ev = region_event(_d, _ri);
	array_push(_out, { k : "event", v : is_struct(_ev) ? _ev.txt : "a lull", col : is_struct(_ev) ? c_gold : sett_ink });
	return _out;
}
