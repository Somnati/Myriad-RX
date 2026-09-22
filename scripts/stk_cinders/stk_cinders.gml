/// @description stk_cinders(s) -> the cinders a TURN would give now: the square root of the levels held across the stack, over four, whole - every level counts, the higher layers' three and five times; x the crucible
function stk_cinders(_s) {
	var _sum = 0;
	for (var _l = 0; _l < array_length(_s.layers); _l++) {
		var _n = stk_sink_n(_s, _l);
		for (var _i = 0; _i < _n; _i++) _sum += _s.layers[_l].sinks[_i].level * ((_l == 0) ? 1 : ((_l == 1) ? 3 : 5));
	}
	var _c = sqrt(_sum) / 4;
	if (stk_sink_n(_s, 2) >= 7) _c *= stk_bonus(_s, 2, 6);
	return floor(_c);
}
