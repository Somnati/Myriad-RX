/// @description delta_unpack(str) - the delta back from its string (delta_pack); an empty or foreign string leaves the fresh one standing
function delta_unpack(_s) {
	if (!is_string(_s) || _s == "") return;
	var _f = string_split(_s, "|");
	if (array_length(_f) < 24 || _f[0] != "1") return;
	var _w = real(_f[1]), _h = real(_f[2]);
	if (_w != DELTA_W || _h != DELTA_H) return;   // (a grid of another size: the fresh one stands)
	var _d = delta_init(true), _n = _w * _h;
	_d.grain = real(_f[3]); _d.life = real(_f[4]); _d.rain = real(_f[5]); _d.springs = real(_f[6]); _d.rich = real(_f[7]); _d.seed = real(_f[8]);
	_d.nlev = real(_f[9]); _d.nchan = real(_f[10]); _d.floods = real(_f[11]); _d.flood_t = real(_f[12]); _d.flood = real(_f[13]); _d.harvests = real(_f[14]); _d.silted = real(_f[15]); _d.last = real(_f[16]); _d.seedid = real(_f[17]);
	delta_unhex(_f[18], _d.hgt, -.1, 1, 2); delta_unhex(_f[19], _d.silt, 0, 1, 1); delta_unhex(_f[20], _d.wet, 0, 1, 1); delta_unhex(_f[21], _d.crop, 0, 1, 1);
	if (string_length(_f[22]) >= _n) for (var _i = 0; _i < _n; _i++) _d.lev[_i] = real(string_char_at(_f[22], _i + 1));
	if (string_length(_f[23]) >= _n) for (var _i = 0; _i < _n; _i++) _d.sea0[_i] = (string_char_at(_f[23], _i + 1) == "1");
	if (array_length(_f) > 24) _d.valley = max(1, real(_f[24]));
}
