/// @description region_hours(region, a, b) -> the road's hours between neighbours a and b (1 when there is no road)
function region_hours(_rg, _a, _b) {
	for (var _e = 0; _e < array_length(_rg.edges); _e++) {
		var _ed = _rg.edges[_e];
		if ((_ed.a == _a && _ed.b == _b) || (_ed.a == _b && _ed.b == _a)) return _ed.d;
	}
	return 1;
}
