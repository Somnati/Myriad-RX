/// @description stk_unpack(str) - the stack back from its string (v2; a v1 line from q316 still reads - no perks, veins re-rolled); an empty or foreign one leaves the fresh stack; a roster that grew keeps the sinks it knows
function stk_unpack(_str) {
	if (!is_string(_str) || _str == "") return;
	var _f = string_split(_str, "|"), _v = real(_f[0]);
	if (!(_v == 1 && array_length(_f) >= 9) && !(_v == 2 && array_length(_f) >= 11)) return;
	var _s = stk_init(true);
	_s.spark = real(_f[1]); _s.life = real(_f[2]); _s.cap_lv = real(_f[3]); _s.cinders = real(_f[4]); _s.turns = real(_f[5]); _s.last = real(_f[6]); _s.tab = clamp(real(_f[7]), 0, 3);
	var _lys;
	if (_v == 2) {
		_s.spent = real(_f[8]);
		if (_f[9] != "-") {
			var _pk = string_split(_f[9], ",");
			for (var _p = 0; _p < array_length(_pk); _p++) { var _kv = string_split(_pk[_p], "="); if (array_length(_kv) == 2) _s.perks[$ _kv[0]] = real(_kv[1]); }
		}
		_lys = string_split(_f[10], ";");
	} else _lys = string_split(_f[8], ";");
	for (var _l = 0; _l < min(array_length(_lys), array_length(_s.layers)); _l++) {
		var _fr = string_split(_lys[_l], "/");
		if (array_length(_fr) < 2) continue;
		var _y = _s.layers[_l], _hd = string_split(_fr[0], ":");
		_y.focus = real(_hd[0]);
		if (array_length(_hd) >= 5) { _y.vein = clamp(real(_hd[1]), -1, 5); _y.vein2 = clamp(real(_hd[2]), -1, 5); _y.burn_t = max(0, real(_hd[3])); _y.burn_add = max(0, real(_hd[4])); if (_y.burn_t <= 0) _y.burn_add = 0; }
		var _sks = string_split(_fr[1], ",");
		for (var _i = 0; _i < min(array_length(_sks), array_length(_y.sinks)); _i++) {
			var _q = string_split(_sks[_i], ":");
			if (array_length(_q) < 4) continue;
			var _k = _y.sinks[_i];
			_k.alloc = max(0, real(_q[0])); _k.prog = max(0, real(_q[1])); _k.level = max(0, real(_q[2])); _k.ups = max(0, real(_q[3]));
		}
	}
	if (_v == 1) stk_veins_roll(_s);
	for (var _l = 0; _l < array_length(_s.layers); _l++) if (_s.layers[_l].focus >= stk_sink_n(_s, _l)) _s.layers[_l].focus = -1;
	stk_clamp(_s);
}
