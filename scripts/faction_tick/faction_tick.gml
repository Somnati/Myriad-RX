/// @description faction_tick(dt) - RECRUITMENT (q283): every hit faction grows back toward its baseline, FAC_REGEN of the base a world day - halved while the kind is leaderless (its seat, or the villain's when the kind is his), doubled while the lord is abroad; a whole one drops its record. A world nobody can reach keeps its wounds
function faction_tick(_dt) {
	var _fs = g.exped[$ "fac"];
	if (!is_struct(_fs) || _dt <= 0) return;
	var _ks = variable_struct_get_names(_fs);
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _kv = string_split(_ks[_i], ":");
		if (array_length(_kv) < 3) { variable_struct_remove(_fs, _ks[_i]); continue; }
		var _d = lane_dest(real(_kv[0]));
		if (!is_struct(_d)) continue;
		var _ri = real(_kv[1]), _kind = _kv[2], _rg = region_get(_d, _ri), _base = faction_base(_rg, _kind);
		var _rate = _base * FAC_REGEN / 86400;
		var _ss = g.exped[$ "seat"], _ldl = false;
		if (is_struct(_ss)) {
			var _s1 = _ss[$ _ks[_i]]; if (is_struct(_s1) && _s1.left > 0) _ldl = true;
			var _s2 = _ss[$ _kv[0] + ":" + _kv[1]]; if (is_struct(_s2) && _s2.left > 0 && (_s2[$ "foe"] ?? "") == _kind) _ldl = true;
		}
		if (_ldl) _rate *= .5;
		var _ev = region_event(_d, _ri);
		if (is_struct(_ev) && _ev.kind == "lord") _rate *= 2;
		var _r = _fs[$ _ks[_i]];
		_r.hp += _rate * _dt;
		if (_r.hp >= _base) variable_struct_remove(_fs, _ks[_i]);
	}
}
