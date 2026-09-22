/// @description stk_cinders(s) -> the cinders a TURN would give now: the square root of the levels held across the stack, over four, whole - every level counts, the higher layers' three and five times
function stk_cinders(_s) {
	var _sum = 0;
	for (var _l = 0; _l < array_length(_s.layers); _l++) for (var _i = 0; _i < array_length(_s.layers[_l].sinks); _i++) _sum += _s.layers[_l].sinks[_i].level * ((_l == 0) ? 1 : ((_l == 1) ? 3 : 5));
	return floor(sqrt(_sum) / 4);
}
