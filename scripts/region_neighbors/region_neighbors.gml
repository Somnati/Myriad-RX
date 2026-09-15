/// @description region_neighbors(region, i) -> [{ j, d }] the roads out of node i
function region_neighbors(_rg, _i) {
	var _out = [];
	for (var _e = 0; _e < array_length(_rg.edges); _e++) {
		var _ed = _rg.edges[_e];
		if (_ed.a == _i) array_push(_out, { j : _ed.b, d : _ed.d });
		else if (_ed.b == _i) array_push(_out, { j : _ed.a, d : _ed.d });
	}
	return _out;
}
