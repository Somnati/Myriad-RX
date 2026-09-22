/// @description stk_unpack(str) - the stack back from its string; an empty or foreign one leaves the fresh stack; a roster that grew keeps the sinks it knows
function stk_unpack(_str) {
	if (!is_string(_str) || _str == "") return;
	var _f = string_split(_str, "|");
	if (array_length(_f) < 9 || _f[0] != "1") return;
	var _s = stk_init(true);
	_s.spark = real(_f[1]); _s.life = real(_f[2]); _s.cap_lv = real(_f[3]); _s.cinders = real(_f[4]); _s.turns = real(_f[5]); _s.last = real(_f[6]); _s.tab = clamp(real(_f[7]), 0, 2);
	var _lys = string_split(_f[8], ";");
	for (var _l = 0; _l < min(array_length(_lys), array_length(_s.layers)); _l++) {
		var _fr = string_split(_lys[_l], "/");
		if (array_length(_fr) < 2) continue;
		_s.layers[_l].focus = real(_fr[0]);
		var _sks = string_split(_fr[1], ",");
		for (var _i = 0; _i < min(array_length(_sks), array_length(_s.layers[_l].sinks)); _i++) {
			var _v = string_split(_sks[_i], ":");
			if (array_length(_v) < 4) continue;
			var _k = _s.layers[_l].sinks[_i];
			_k.alloc = max(0, real(_v[0])); _k.prog = max(0, real(_v[1])); _k.level = max(0, real(_v[2])); _k.ups = max(0, real(_v[3]));
		}
	}
	stk_clamp(_s);
}
