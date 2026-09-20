/// @description region_ledger(dest, ri, [tab]) -> [{ k, v, col, [bar -1..1], [sub] }] THE REGION'S LEDGER for the [influence] view, one TAB at a time (q270 / q286): "lanes" / "factions" / "people" / "events" / "memory" (region_ledger_tabs) - every row says what the thing is, what moves it and what reads it
function region_ledger(_d, _ri, _tab = "lanes") {
	var _rg = region_get(_d, _ri), _out = [], _dayh = 24 * EXPED_HOUR;
	// (the tables, static - a function's, whatever block reads them)
	static _wd = {
		order   : [ "the roads worse",             "the roads quieter" ],
		wild    : [ "the beasts thin",             "the beasts back" ],
		trade   : [ "trade down",                  "trade up" ],
		faith   : [ "the dead restless",           "the dead quiet" ],
		welcome : [ "unwelcome here",              "welcomed here" ],
		dread   : [ "the villain's grip loosened", "the villain's grip tightened" ],
	};
	static _bad = { order : 0, wild : 1, trade : 0, faith : 0, welcome : 0, dread : 1 };
	static _push = {
		order   : "bandits beaten +.06 (beaten by them -.15), a bounty +.25, a camp burned +.35, a dungeon cleared, the villain ended +.5; a raid -.2",
		wild    : "beasts beaten -.04 a head",
		trade   : "an escort, a parcel or a shop minded +, coin spent in a shop +.06; low order drains it",
		faith   : "a shrine kept +.12, a crypt cleared +",
		welcome : "a town helped +.35; barred from an inn -.3, a raid -.1",
		dread   : "a new chief +.45, a raid +.3; a camp burned -.3, a thread pulled -.25, the villain ended -.8",
	};
	static _reads = {
		order   : "the road - bandits turn into passers-by (or back)",
		wild    : "wild fights on the road thin to nothing",
		trade   : "the shop's shelf and its rung; a fair vs a plague of rats",
		faith   : "the shrine's charm; the crypt's dead",
		welcome : "the inn's bed, the haggle, who asks to come along",
		dread   : "every encounter x (1 + .3 dread); the lord riding out",
	};
	static _mwhat = { routed : "ashes: nobody home at the camp, the road past it quiet", quiet : "cleared: half the rooms next time", grateful : "a bed on the house", barred : "no welcome at the inn", peace : "half the encounters in the region", event : "" };
	var _days = function(_sec) { return string(max(1, ceil(_sec / (24 * EXPED_HOUR)))) + "d"; };
	switch (_tab) {
	case "lanes": {
		array_push(_out, { k : "", v : "six lanes: how far the region stands from its rest (0) in each. a deed pushes one - divided by the weight - and it fades back on the expedition clock. the region remembers the sum, not the list.", col : sett_ink });
		var _w = region_weight(_rg), _hl = ln(2) * LANE_TAU / _w / 3600;
		array_push(_out, { k : "weight", v : string_format(_w, 1, 2) + "  -  a push here is divided by it; a lane's half-life " + string_format(_hl, 1, 1) + "h of the expedition clock", col : sett_ink });
		var _r = lane_get(_d, _ri, false), _nm = lane_names();
		for (var _j = 0; _j < array_length(_nm); _j++) {
			var _v = is_struct(_r) ? (_r[$ _nm[_j]] ?? 0) : 0;
			var _word = (abs(_v) < .05) ? "at rest" : _wd[$ _nm[_j]][(_v > 0) ? 1 : 0];
			var _isbad = (abs(_v) >= .05) && ((_bad[$ _nm[_j]] == 1) ? (_v > 0) : (_v < 0));
			array_push(_out, { k : _nm[_j], v : ((_v >= 0) ? "+" : "") + string_format(_v, 1, 2) + "  " + _word, col : (abs(_v) < .05) ? sett_ink : (_isbad ? c_horange : c_seagreen), bar : _v,
			                   sub : "pushed by: " + _push[$ _nm[_j]] + ".  reads it: " + _reads[$ _nm[_j]] + "." });
		}
		var _scs = scar_get(_d, _ri), _srow = "";
		for (var _i = 0; _i < array_length(_scs); _i++) if (_scs[_i].n >= 0 && _scs[_i].n < array_length(_rg.nodes)) _srow += ((_srow != "") ? "; " : "") + _rg.nodes[_scs[_i].n].name + ": " + (_scs[_i][$ "was"] ?? "") + " -> " + _scs[_i].k;
		array_push(_out, { k : "scars", v : (_srow != "") ? _srow : "none yet", col : (_srow != "") ? c_gold : sett_ink,
		                   sub : "a lane held past .7 (order, trade) or under -.7 (faith) for " + string(round(SCAR_HOLD / 3600)) + "h lands one: a camp becomes a settlement, a settlement a village, a village a town, the dead spread. it does not fade. three a region at most." });
	} break;
	case "factions": {
		array_push(_out, { k : "", v : "every kind of foe here is a pool of heads - the region's weight sets it. a kill takes one, a boss or a named one " + string(FAC_KILL_BOSS) + ", a camp burned " + string(round(FAC_ROUT * 100)) + "% of the pool, the villain's end " + string(round(FAC_VILLAIN * 100)) + "%. they recruit back " + string(round(FAC_REGEN * 100)) + "% of the pool a day - half without a chief, double with the lord abroad - and never fall under " + string(round(FAC_FLOOR * 100)) + "%.", col : sett_ink });
		var _seat = seat_get(_d, _ri), _vil = region_villain(_d, _rg), _vfoe = is_struct(_vil) ? _vil.foe : ((is_struct(_seat) ? (_seat[$ "foe"] ?? "") : ""));
		if (is_struct(_seat) && _seat.left > 0) array_push(_out, { k : "seat", v : "empty - a successor in " + _days(_seat.left) + " (the " + string(_seat.n + 1) + ((_seat.n + 1 == 2) ? "nd" : ((_seat.n + 1 == 3) ? "rd" : "th")) + " to hold it)", col : c_seagreen, sub : "no raids and no lord abroad while it is empty; his kind recruits at half" });
		else if (is_struct(_vil)) array_push(_out, { k : "seat", v : _vil.name + ", " + (_vil[$ "rank"] ?? "chief") + " of " + _vil.fac + (((_vil[$ "n"] ?? 0) > 0) ? " (the " + string(_vil.n + 1) + ((_vil.n + 1 == 2) ? "nd" : ((_vil.n + 1 == 3) ? "rd" : "th")) + " to hold it)" : ""), col : c_hred, sub : "his people are the " + foe_plural(_vil.foe) + " - their strength is his: the raid wants " + string(round(FAC_RAID_STR * 100)) + "%, the lord abroad 50%, his guards go under 50%" });
		else array_push(_out, { k : "seat", v : "no villain here", col : sett_ink });
		// every kind that can stand here: the bandits, and the lands' own
		var _kinds = ["bandit"], _kk = region_kinds();
		for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
			var _nk = _rg.nodes[_i].kind, _nkd = _kk[$ _nk];
			if (is_struct(_nkd) && _nkd.civ) continue;
			if (_nk == "landing" || _nk == "shrine" || _nk == "mine") continue;
			var _fk = foe_kinds_at(_nk);
			for (var _q = 0; _q < array_length(_fk); _q++) if (!array_contains(_kinds, _fk[_q])) array_push(_kinds, _fk[_q]);
		}
		if (_vfoe != "" && !array_contains(_kinds, _vfoe)) array_push(_kinds, _vfoe);
		var _ss = g.exped[$ "seat"], _lk0 = lane_key(_d, _ri);
		for (var _i = 0; _i < array_length(_kinds); _i++) {
			var _kd = _kinds[_i], _ff = faction_get(_d, _ri, _kd, _rg), _fw = faction_word(_ff.str);
			var _ldl = false;
			if (is_struct(_ss)) { var _s1 = _ss[$ _lk0 + ":" + _kd]; if (is_struct(_s1) && _s1.left > 0) _ldl = true; if (is_struct(_seat) && _seat.left > 0 && (_seat[$ "foe"] ?? "") == _kd) _ldl = true; }
			var _rate = _ff.base * FAC_REGEN * (_ldl ? .5 : 1), _sub = "";
			if (_ff.hp < _ff.base) _sub = "recruiting " + string_format(_rate, 1, 1) + " a day" + (_ldl ? " (leaderless: half)" : "") + " - full in " + string(max(1, ceil((_ff.base - _ff.hp) / max(.01, _rate)))) + "d";
			else _sub = "untouched - nothing hunted them here yet";
			if (_kd == _vfoe && _vfoe != "") _sub += ".  the villain's people";
			if (_ldl) _sub += ".  leaderless: x" + string(FOE_LEADERLESS) + " on every one of them";
			array_push(_out, { k : foe_plural(_kd), v : string(round(_ff.hp)) + " of " + string(_ff.base) + "  -  " + _fw.txt, col : _fw.col, bar : _ff.str * 2 - 1, sub : _sub });
		}
		array_push(_out, { k : "reads it", v : "which kinds turn up in a fight (a thin kind less, the others more); a camp's count; the leader's guards (none under 50%) and his stats (" + string_format(1 - FAC_BOSS_CUT, 1, 1) + " + " + string_format(FAC_BOSS_CUT, 1, 1) + " x strength); the road - thin bandits become passers-by, thin beasts a sprite met.", col : sett_ink });
	} break;
	case "people": {
		array_push(_out, { k : "", v : "a place's number is its baseline x a slow wobble (" + string(round(POP_WOBBLE * 100)) + "% either way on the wall clock, never stored) x what happened lately: a raid -" + string(round(RAID_POP * 100)) + "%, rats -8%, a fair +5%, a wave held +5%, the villain ended +4%. the lately part fades by the place's size - a city in 3 days, a town 5, a village 7, a settlement 10. a settlement stays a settlement: only a scar changes what a place is.", col : sett_ink });
		var _pany = false;
		for (var _pi = 1; _pi < array_length(_rg.nodes); _pi++) {
			var _lpp = region_pop(_d, _rg, _pi);
			if (is_undefined(_lpp)) continue;
			_pany = true;
			var _pw = pop_word(_lpp), _psub = "baseline " + string(_lpp.base) + ", wobble " + ((_lpp.wob >= 1) ? "+" : "") + string(round((_lpp.wob - 1) * 100)) + "%";
			if (abs(_lpp.dev) >= .01) _psub += ", lately " + ((_lpp.dev > 0) ? "+" : "") + string(round(_lpp.dev * 100)) + "% - back to rest in " + string(max(1, ceil(_lpp.tau * ln(abs(_lpp.dev) / .01)))) + "d";
			else _psub += ", nothing lately";
			_psub += ".  the shop's shelf: one fewer under -12%, one more over +10%";
			array_push(_out, { k : _rg.nodes[_pi].name, v : _rg.nodes[_pi].kind + " - " + _pw.txt, col : _pw.col, bar : clamp(_lpp.dev / POP_DEV_MAX, -1, 1), sub : _psub });
		}
		if (!_pany) array_push(_out, { k : "people", v : "nobody settled here", col : sett_ink });
		var _scs2 = scar_get(_d, _ri);
		for (var _i = 0; _i < array_length(_scs2); _i++) if (_scs2[_i].n >= 0 && _scs2[_i].n < array_length(_rg.nodes)) array_push(_out, { k : (_i == 0) ? "scars" : "", v : _rg.nodes[_scs2[_i].n].name + ": " + (_scs2[_i][$ "was"] ?? "") + " -> " + _scs2[_i].k + "  (for good)", col : c_gold });
	} break;
	case "events": {
		array_push(_out, { k : "", v : "one procedural event at a time in a region, two to four days, then a lull of one to three. the crews' deeds are news beside it, each for a few days.", col : sett_ink });
		var _ev = region_event(_d, _ri), _em = exped_mem_get(_d, _ri, -1, "event");
		if (is_struct(_ev)) array_push(_out, { k : "now", v : _ev.txt + "  -  " + _days(_ev.left) + " left", col : c_gold, sub : _ev[$ "why"] ?? "" });
		else array_push(_out, { k : "now", v : "a lull" + (is_struct(_em) ? ("  -  " + _days(_em.left) + " until the next roll") : ""), col : sett_ink, sub : "at the roll: a lull again 55 times in a hundred, else one of the kinds below that can" });
		// what can roll here now - exped_event_tick's conditions, checked live
		var _kke = region_kinds(), _civ = 0, _open = false, _camps = false;
		for (var _i = 1; _i < array_length(_rg.nodes); _i++) {
			var _ke = _rg.nodes[_i].kind, _kde = _kke[$ _ke];
			if (is_struct(_kde) && _kde.civ) _civ++;
			if (_ke == "field" || _ke == "forest" || _ke == "hills" || _ke == "marsh") _open = true;
			if (_ke == "camp") _camps = true;
		}
		var _ltr = lane_val(_d, _ri, "trade"), _vile = region_villain(_d, _rg), _vm = g.exped[$ "vil"], _vst = 0;
		if (is_struct(_vm)) _vst = _vm[$ string(_d.seed) + ":" + string(_ri)] ?? 0;
		var _vstr = is_struct(_vile) ? faction_get(_d, _ri, _vile.foe, _rg).str : 0;
		var _ok = function(_b) { return _b ? "can" : "cannot"; };
		array_push(_out, { k : "fair",  v : _ok(_civ > 0) + "  -  wants a settled place" + ((_ltr > .3) ? "; trade up: likelier" : ""), col : (_civ > 0) ? c_seagreen : sett_ink, sub : "stalls on the green: the shelf twice itself and a rung up; +5% people" });
		array_push(_out, { k : "rats",  v : _ok(_civ > 0) + "  -  wants a settled place" + ((_ltr < -.3) ? "; trade down: likelier" : ""), col : (_civ > 0) ? c_horange : sett_ink, sub : "rats in every fight, the shelf thin; -8% people" });
		array_push(_out, { k : "lord",  v : _ok(_camps && is_struct(_vile) && _vst < 3 && _vstr >= .5) + "  -  wants a camp, a villain and his people at 50% (" + string(round(_vstr * 100)) + "%)", col : (_camps && is_struct(_vile) && _vst < 3 && _vstr >= .5) ? c_horange : sett_ink, sub : "his people on every road, one more at every camp, recruiting double" });
		array_push(_out, { k : "raid",  v : _ok(_camps && is_struct(_vile) && _vst < 3 && _civ > 0 && _vstr >= FAC_RAID_STR) + "  -  wants a camp, a villain, a settled place and his people at " + string(round(FAC_RAID_STR * 100)) + "% (" + string(round(_vstr * 100)) + "%); twice on the roll", col : (_camps && is_struct(_vile) && _vst < 3 && _civ > 0 && _vstr >= FAC_RAID_STR) ? c_hred : sett_ink, sub : "a settled place loses " + string(round(RAID_POP * 100)) + "% of its people and its shelf thins; dread +.3, order -.2, welcome -.1; his people on the roads" });
		array_push(_out, { k : "frost", v : _ok(_open) + "  -  wants open land", col : _open ? c_steelblue : sett_ink, sub : "the roads slow, the wild kinds hungry" });
		var _nws = region_news(_d, _ri);
		if (array_length(_nws) == 0) array_push(_out, { k : "news", v : "nothing the crews did here is talked about yet", col : sett_ink });
		for (var _ni = 0; _ni < array_length(_nws); _ni++) array_push(_out, { k : (_ni == 0) ? "news" : "", v : _nws[_ni].txt + "  (" + _days(_nws[_ni].left) + ")", col : c_seagreen });
	} break;
	case "memory": {
		array_push(_out, { k : "", v : "the world's short memories, each on a clock of the expedition's hours. they are about ONE place; the lanes are about the region.", col : sett_ink });
		var _mm = g.exped[$ "mem"], _many = false;
		if (is_struct(_mm)) {
			var _mk0 = string(_d.seed) + ":" + string(_ri) + ":", _mks = variable_struct_get_names(_mm);
			for (var _i = 0; _i < array_length(_mks); _i++) {
				if (string_pos(_mk0, _mks[_i]) != 1) continue;
				var _me = _mm[$ _mks[_i]], _kv = string_split(_mks[_i], ":");
				if (array_length(_kv) < 4 || _kv[3] == "event") continue;
				var _nn = real(_kv[2]);
				array_push(_out, { k : _kv[3], v : ((_nn >= 0 && _nn < array_length(_rg.nodes)) ? _rg.nodes[_nn].name : "the region") + "  -  " + string(max(1, ceil(_me.left / EXPED_HOUR))) + "h left", col : c_lavender, sub : _mwhat[$ _kv[3]] ?? "" });
				_many = true;
			}
		}
		if (!_many) array_push(_out, { k : "memories", v : "none - nothing here is remembered right now", col : sett_ink });
		array_push(_out, { k : "kinds", v : "routed (a camp burned, 4d) - quiet (a dungeon cleared) - grateful (a town helped, a week or two) - barred (thrown out of an inn, 3d) - peace (the villain ended, a week)", col : sett_ink });
	} break;
	}
	return _out;
}
