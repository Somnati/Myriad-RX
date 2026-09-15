/// @description exped_say(trip, beat, [ctx], [chance]) -> the diary's
/// flavour line for this beat, pushed onto the trip's log as "~ ..."
/// under the truth line (the panel draws the tilde lines as the diary's
/// voice), or "" when the dice or the gates say nothing this time.
/// @param trip     the trip struct (its threads live here)
/// @param beat     see exped_lines
/// @param [ctx]    { foe, item, partner } - the slots this beat can fill
/// @param [chance] 0..1, the odds a line is said at all (default 1)
///
/// THE PICK: every template of the beat whose gates pass is a candidate;
/// a template that CLOSES an open thread wins 85% of the time it can
/// (payoffs are the point); the rest weigh by w; a line said earlier
/// this session (g.exped.recent, the last 40) is skipped unless nothing
/// else is left. The sprite's MEMORY (s.mem: trips / wins / routs / last
/// planet / streak, exped_tick keeps it) feeds the `need` gates so the
/// diary can say "third time out" and mean it.
function exped_say(_tr, _beat, _ctx = undefined, _chance = 1) {
	exped_init();
	if (_chance < 1 && random(1) >= _chance) return "";
	if (is_undefined(_ctx)) _ctx = {};
	var _e = g.exped;
	if (!variable_struct_exists(_e, "recent")) _e.recent = [];
	if (!variable_struct_exists(_tr, "threads")) _tr.threads = [];
	// THE SPEAKER: one of the crew, at random, so every voice gets a
	// turn - its personality, its memory, its hp; {partner} is another
	// of them, and the bond between the two gates the party lines
	var _sids = _tr[$ "sids"] ?? [_tr.sid];
	var _names = _tr[$ "names"] ?? [_tr.sname];
	var _n = array_length(_sids);
	var _k = irandom(_n - 1);
	if (!is_undefined(_ctx[$ "sid"])) { var _fk = array_get_index(_sids, _ctx.sid); if (_fk >= 0) _k = _fk; }   // (a forced speaker: the one who levelled, who bought - 2026-09-15)
	var _pk = (_n > 1) ? ((_k + 1 + irandom(_n - 2)) mod _n) : -1;
	var _sp = undefined;
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _sids[_k]) _sp = g.sprites[_i];
	var _pl = sprite_personalities();
	var _pers = (_sp != undefined) ? _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name : "";
	var _mem = { trips : 0, wins : 0, routs : 0, last : "", streak : 0 };
	if (_sp != undefined && is_struct(_sp[$ "mem"])) _mem = _sp.mem;
	var _hpf = is_array(_tr.hp) ? (_tr.hp[_k] / max(1, _tr.hpmax[_k])) : (_tr.hp / max(1, _tr.hpmax));
	var _bi = exped_biomes()[_tr.dest.biome];
	// THE SITUATION (the voice pass, 2026-09-15): the partner's temperament,
	// the speaker's class, where the crew stands (its kind, its hazard), the
	// sky, the quest's kind and its {who}, the pocket
	var _psp = undefined;
	if (_pk >= 0) for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _sids[_pk]) _psp = g.sprites[_i];
	var _ppers = (_psp != undefined) ? _pl[clamp(_psp.pers, 0, array_length(_pl) - 1)].name : "";
	var _cls = (_sp != undefined) ? sprite_classes()[sprite_sheet(_sp).cls].key : "";
	var _lv = (_sp != undefined) ? sprite_sheet(_sp).lv : 1;
	var _rgn = exped_region(_tr);
	var _nn = array_length(_rgn.nodes);
	var _pi = clamp(is_struct(_tr[$ "road"]) ? _tr.road.b : (_tr[$ "pos"] ?? 0), 0, _nn - 1);
	var _pnd = _rgn.nodes[_pi];
	var _hzr = ((_tr[$ "stage"] ?? 0) == 1) ? exped_hazard(_tr) : undefined;
	var _q = _tr[$ "quest"];
	var _goal = is_struct(_q) ? _rgn.nodes[clamp(_q.node, 0, _nn - 1)].name : _rgn.name;
	var _pp = planet_props(_tr.dest);   // (the world's properties: its oddity, gravity, air, moons - 2026-09-15)
	var _c = {
		odd : _pp.odd, grav : _pp.gravw, air : _pp.airw, moonless : (_pp.moons == 0),
		night : _tr[$ "night"] ?? false, wx : _tr[$ "weather"] ?? "clear",
		haz : (is_struct(_hzr) && is_struct(_hzr.hz)) ? _hzr.hz.key : "",
		place : _pnd.name, kind : _pnd.kind, region : _rgn.name, goal : _goal,
		qk : is_struct(_q) ? _q.kind : "explore", who : is_struct(_q) ? (_q[$ "who"] ?? "someone") : "someone",
		cls : _cls, lv : _lv, ppers : _ppers, poor : ((_tr[$ "credits"] ?? 0) <= 0),
		beat : _beat, pers : _pers, biome : _bi.name,
		party : _n, bond : (_pk >= 0) ? exped_bond_tier(exped_bond(_sids[_k], _sids[_pk])) : 0,
		hp : _hpf, routed : _tr.routed, mem : _mem,
		name : _names[_k], planet : _tr.dest.name,
		foe : _ctx[$ "foe"] ?? "something", item : _ctx[$ "item"] ?? "something",
		partner : (_pk >= 0) ? _names[_pk] : "the other one",
		retired : (array_length(_e.retired) > 0) ? _e.retired[irandom(array_length(_e.retired) - 1)] : "someone",
	};
	// the memory gates
	var _need_ok = function(_k, _c) {
		var _m = _c.mem;
		switch (_k) {
			case "first":         return _m.trips == 0;
			case "third":         return _m.trips >= 2;
			case "revisit":       return _m.last == _c.planet && _m.trips > 0;
			case "routed_before": return _m.routs >= 1;
			case "streak3":       return _m.streak >= 3;
			case "wins3":         return _m.wins >= 3;
			case "retired":       return array_length(g.exped.retired) > 0;
		}
		return false;
	};
	// the situation's gates (2026-09-15): a line asks for a night, a sky, a
	// hazard, a class, a partner's temperament, a place's kind, a quest's
	// kind, an empty pocket, a level band ("low" 1-2 / "high" 6+)
	var _sit_ok = function(_l, _c) {
		if (!is_undefined(_l[$ "night"]) && _l.night != _c.night) return false;
		if (!is_undefined(_l[$ "wx"])    && _l.wx != _c.wx) return false;
		if (!is_undefined(_l[$ "haz"])   && _l.haz != _c.haz) return false;
		if (!is_undefined(_l[$ "cls"])   && _l.cls != _c.cls) return false;
		if (!is_undefined(_l[$ "ppers"]) && _l.ppers != _c.ppers) return false;
		if (!is_undefined(_l[$ "kind"])  && _l.kind != _c.kind) return false;
		if (!is_undefined(_l[$ "qk"])    && _l.qk != _c.qk) return false;
		if (!is_undefined(_l[$ "poor"])  && _l.poor != _c.poor) return false;
		if (!is_undefined(_l[$ "lv"])    && ((_l.lv == "low" && _c.lv > 2) || (_l.lv == "high" && _c.lv < 6))) return false;
		if (!is_undefined(_l[$ "odd"])   && _l.odd != _c.odd) return false;
		if (!is_undefined(_l[$ "grav"])  && _l.grav != _c.grav) return false;
		if (!is_undefined(_l[$ "air"])   && _l.air != _c.air) return false;
		if (!is_undefined(_l[$ "moonless"]) && _l.moonless != _c.moonless) return false;
		return true;
	};
	var _all = exped_lines();
	var _cand = [], _cw = [], _close = [];
	var _fresh = 0;
	for (var _i = 0; _i < array_length(_all); _i++) {
		var _l = _all[_i];
		if (_l.b != _beat) continue;
		if (!is_undefined(_l[$ "pers"])   && _l.pers != _c.pers) continue;
		if (!is_undefined(_l[$ "biome"])  && _l.biome != _c.biome) continue;
		if (!is_undefined(_l[$ "party"])  && ((_l.party == 1 && _c.party != 1) || (_l.party == 2 && _c.party < 2))) continue;
		if (!is_undefined(_l[$ "bond"])   && _l.bond != _c.bond) continue;
		if (!is_undefined(_l[$ "hp"])     && ((_l.hp == "low" && _c.hp > .4) || (_l.hp == "full" && _c.hp < .95))) continue;
		if (!_sit_ok(_l, _c)) continue;
		if (!is_undefined(_l[$ "routed"]) && _l.routed != _c.routed) continue;
		if (!is_undefined(_l[$ "need"])   && !_need_ok(_l.need, _c)) continue;
		if (!is_undefined(_l[$ "opens"])  && array_contains(_tr.threads, _l.opens)) continue;
		if (!is_undefined(_l[$ "closes"])) {
			if (!array_contains(_tr.threads, _l.closes)) continue;
			array_push(_close, _i);
			continue;
		}
		var _said = array_contains(_e.recent, _i);
		if (!_said) _fresh++;
		array_push(_cand, _i);
		array_push(_cw, (_l[$ "w"] ?? 1) * (_said ? .05 : 1));   // said this session: nearly never again
	}
	var _pick = -1;
	if (array_length(_close) > 0 && random(1) < .85) _pick = _close[irandom(array_length(_close) - 1)];
	else if (array_length(_cand) > 0) {
		var _tot = 0;
		for (var _i = 0; _i < array_length(_cw); _i++) _tot += _cw[_i];
		var _r = random(_tot);
		_pick = _cand[array_length(_cand) - 1];
		for (var _i = 0; _i < array_length(_cand); _i++) { if (_r < _cw[_i]) { _pick = _cand[_i]; break; } _r -= _cw[_i]; }
	}
	if (_pick < 0) return "";
	var _t = _all[_pick];
	// the threads: a setup opens one, a payoff closes it
	if (!is_undefined(_t[$ "opens"])) array_push(_tr.threads, _t.opens);
	if (!is_undefined(_t[$ "closes"])) {
		var _at = array_get_index(_tr.threads, _t.closes);
		if (_at >= 0) array_delete(_tr.threads, _at, 1);
	}
	array_push(_e.recent, _pick);
	if (array_length(_e.recent) > 40) array_delete(_e.recent, 0, 1);
	// the slots
	var _txt = _t.t;
	_txt = string_replace_all(_txt, "{name}", _c.name);
	_txt = string_replace_all(_txt, "{planet}", _c.planet);
	_txt = string_replace_all(_txt, "{biome}", _c.biome);
	_txt = string_replace_all(_txt, "{foe}", _c.foe);
	_txt = string_replace_all(_txt, "{item}", _c.item);
	_txt = string_replace_all(_txt, "{partner}", _c.partner);
	_txt = string_replace_all(_txt, "{retired}", _c.retired);
	_txt = string_replace_all(_txt, "{place}", _c.place);
	_txt = string_replace_all(_txt, "{goal}", _c.goal);
	_txt = string_replace_all(_txt, "{region}", _c.region);
	_txt = string_replace_all(_txt, "{who}", _c.who);
	_txt = string_replace_all(_txt, "{wx}", _c.wx);
	_txt = string_replace_all(_txt, "{cls}", _c.cls);
	array_push(_tr.log, "~ " + _txt);
	return _txt;
}
