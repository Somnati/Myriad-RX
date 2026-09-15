/// @description region_nearest_civ(region, from) -> the nearest place people live (by hours), -1 if none
function region_nearest_civ(_rg, _from) {
	var _kk = region_kinds();
	var _best = -1, _bd = 999999;
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		if (_i == _from) continue;
		var _kd = _kk[$ _rg.nodes[_i].kind];
		if (is_undefined(_kd) || !_kd.civ) continue;
		var _p = region_path(_rg, _from, _i);
		if (array_length(_p) == 0) continue;
		var _h = 0, _c = _from;
		for (var _k = 0; _k < array_length(_p); _k++) { _h += region_hours(_rg, _c, _p[_k]); _c = _p[_k]; }
		if (_h < _bd) { _bd = _h; _best = _i; }
	}
	return _best;
}
