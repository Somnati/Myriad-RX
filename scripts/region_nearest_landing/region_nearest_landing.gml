/// @description region_nearest_landing(region, from) -> the landing zone nearest by road (hours)
function region_nearest_landing(_rg, _from) {
	var _ls = _rg[$ "landings"] ?? [ _rg.landing ];
	var _best = _ls[0], _bd = 999999;
	for (var _i = 0; _i < array_length(_ls); _i++) {
		var _l = _ls[_i];
		if (_l == _from) return _l;
		var _p = region_path(_rg, _from, _l);
		if (array_length(_p) == 0) continue;
		var _h = 0, _c = _from;
		for (var _k = 0; _k < array_length(_p); _k++) { _h += region_hours(_rg, _c, _p[_k]); _c = _p[_k]; }
		if (_h < _bd) { _bd = _h; _best = _l; }
	}
	return _best;
}
