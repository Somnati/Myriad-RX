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
	var _pk = (_n > 1) ? ((_k + 1 + irandom(_n - 2)) mod _n) : -1;
	var _sp = undefined;
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _sids[_k]) _sp = g.sprites[_i];
	var _pl = sprite_personalities();
	var _pers = (_sp != undefined) ? _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name : "";
	var _mem = { trips : 0, wins : 0, routs : 0, last : "", streak : 0 };
	if (_sp != undefined && is_struct(_sp[$ "mem"])) _mem = _sp.mem;
	var _hpf = is_array(_tr.hp) ? (_tr.hp[_k] / max(1, _tr.hpmax[_k])) : (_tr.hp / max(1, _tr.hpmax));
	var _bi = exped_biomes()[_tr.dest.biome];
	var _c = {
		beat : _beat, pers : _pers, biome : _bi.name,
		party : _n, bond : (_pk >= 0) ? exped_bond_tier(exped_bond(_sids[_k], _sids[_pk])) : 0,
		hp : _hpf, routed : _tr.routed, mem : _mem,
		name : _names[_k], planet : _tr.dest.name,
		foe : _ctx[$ "foe"] ?? "something", item : _ctx[$ "item"] ?? "something",
		partner : (_pk >= 0) ? _names[_pk] : "the other one",
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
		}
		return false;
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
		if (!is_undefined(_l[$ "hp"])     && _l.hp == "low" && _c.hp > .4) continue;
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
	array_push(_tr.log, "~ " + _txt);
	return _txt;
}
