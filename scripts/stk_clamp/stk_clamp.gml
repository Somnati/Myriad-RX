/// @description stk_clamp(s) - every layer's allocation back under its cap (a cap that shrank: a turn, a load)
function stk_clamp(_s) {
	for (var _l = 0; _l < array_length(_s.layers); _l++) {
		var _sk = _s.layers[_l].sinks, _cap = stk_cap(_s, _l), _tot = 0;
		for (var _k = 0; _k < array_length(_sk); _k++) _tot += _sk[_k].alloc;
		for (var _k = array_length(_sk) - 1; _k >= 0 && _tot > _cap; _k--) { var _cut = min(_sk[_k].alloc, _tot - _cap); _sk[_k].alloc -= _cut; _tot -= _cut; }
	}
}
