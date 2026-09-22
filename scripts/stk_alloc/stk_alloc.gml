/// @description stk_alloc(s, l, i, delta) -> the new allocation: THE allocation lawyer - moves sink (l, i)'s energy by delta, clamped 0..alloc + the layer's free; INSTANT AND FREE by law
function stk_alloc(_s, _l, _i, _delta) {
	var _sk = _s.layers[_l].sinks, _tot = 0;
	for (var _k = 0; _k < array_length(_sk); _k++) _tot += _sk[_k].alloc;
	var _free = max(0, stk_cap(_s, _l) - _tot);
	var _new = floor(clamp(_sk[_i].alloc + _delta, 0, _sk[_i].alloc + _free));
	if (_new != _sk[_i].alloc) { _sk[_i].alloc = _new; save_mark_dirty(); }
	return _sk[_i].alloc;
}
