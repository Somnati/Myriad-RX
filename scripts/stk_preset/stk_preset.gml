/// @description stk_preset(s, l, which) - a layer's allocation at a stroke: "even" (the cap spread over the sinks, the remainder to the first), "chase" (all of it to the sink nearest its next level, in time), "clear" (all of it back)
function stk_preset(_s, _l, _which) {
	var _sk = _s.layers[_l].sinks, _n = array_length(_sk), _cap = stk_cap(_s, _l);
	for (var _i = 0; _i < _n; _i++) _sk[_i].alloc = 0;
	if (_which == "even") { var _each = floor(_cap / _n); for (var _i = 0; _i < _n; _i++) _sk[_i].alloc = _each; _sk[0].alloc += _cap - _each * _n; }
	else if (_which == "chase") {
		var _best = 0, _bt = infinity;
		for (var _i = 0; _i < _n; _i++) { var _left = stk_thr(_s, _l, _i, _sk[_i].level) - _sk[_i].prog; if (_left < _bt) { _bt = _left; _best = _i; } }
		_sk[_best].alloc = _cap;
	}
	save_mark_dirty();
}
