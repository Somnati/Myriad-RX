/// @description syz_unpack(str) - the clockwork back from its string; an empty or foreign string leaves the fresh one
function syz_unpack(_str) {
	if (!is_string(_str) || _str == "") return;
	var _f = string_split(_str, "|");
	if (array_length(_f) < 15 || _f[0] != "1") return;
	var _s = syz_init(true);
	_s.flux = real(_f[1]); _s.life = real(_f[2]); _s.tokens = real(_f[3]); _s.harm = real(_f[4]); _s.cap = real(_f[5]); _s.drift_t = real(_f[6]); _s.sync_cd = real(_f[7]);
	_s.wobbles = real(_f[8]); _s.syncs = real(_f[9]); _s.grand = real(_f[10]); _s.best = real(_f[11]); _s.last = real(_f[12]);
	var _cs = string_split(_f[13], ";"), _cy = [];
	for (var _i = 0; _i < array_length(_cs); _i++) {
		var _v = string_split(_cs[_i], ":");
		if (array_length(_v) < 4) continue;
		var _p = clamp(round(real(_v[0])), SYZ_PER_MIN, SYZ_PER_MAX);
		array_push(_cy, { per : _p, t : clamp(real(_v[1]), 0, _p), lv : max(1, real(_v[2])), anchor : (_v[3] == "1"), fired : 0, k : 1 });
	}
	if (array_length(_cy) >= 1) _s.cycles = _cy;
	var _cj = string_split(_f[14], ",");
	for (var _i = 0; _i < min(array_length(_cj), array_length(_s.conj)); _i++) _s.conj[_i] = real(_cj[_i]);
}
