/// @description coll_unpack(str) - the collider back from its string; an empty or foreign one leaves the fresh state; NaN / infinity in a poisoned save fall back to sane values (the framework's sanitiser)
function coll_unpack(_str) {
	if (!is_string(_str) || _str == "") return;
	var _f = string_split(_str, "|");
	if (array_length(_f) < 17 || _f[0] != "1") return;
	var _c = coll_init(true);
	var _r = function(_v, _d) { var _x = real(_v); return (is_nan(_x) || is_infinity(_x)) ? _d : _x; };
	_c.energy = _r(_f[1], COLL_LZ); _c.field = max(0, _r(_f[2], 0)); _c.auto_lv = clamp(_r(_f[3], 0), 0, 3); _c.magnet_lv = clamp(_r(_f[4], 0), 0, 4); _c.pct = clamp(_r(_f[5], 50), 10, 100); _c.auto_t = max(0, _r(_f[6], 0));
	_c.last = _r(_f[7], universal_now()); _c.start = _r(_f[8], universal_now()); _c.inf = (_f[9] == "1"); _c.run = _r(_f[10], -1); _c.best = _r(_f[11], -1); _c.crunches = max(0, _r(_f[12], 0)); _c.pairs_lg = _r(_f[13], COLL_LZ); _c.collisions = max(0, _r(_f[14], 0));
	var _sides = [_c.m, _c.a];
	for (var _k = 0; _k < 2; _k++) {
		var _p = string_split(_f[15 + _k], "/");
		if (array_length(_p) < 3) continue;
		var _cs = _sides[_k];
		_cs.stock = _r(_p[0], 1);
		var _b = string_split(_p[1], ","), _n = string_split(_p[2], ",");
		for (var _i = 0; _i < min(COLL_N, array_length(_b)); _i++) _cs.bought[_i] = max(0, _r(_b[_i], 0));
		for (var _i = 0; _i < min(COLL_N, array_length(_n)); _i++) _cs.count[_i] = _r(_n[_i], COLL_LZ);
	}
	if (_c.energy >= COLL_WALL) _c.energy = COLL_WALL;
}
