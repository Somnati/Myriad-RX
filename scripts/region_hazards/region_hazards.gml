/// @description region_hazards(region) -> the hazards its places carry, each once, in the roster's order (cbt_hazards)
function region_hazards(_rg) {
	var _out = [], _hz = cbt_hazards();
	for (var _i = 0; _i < array_length(_hz); _i++) {
		var _h = _hz[_i], _has = false;
		for (var _j = 0; _j < array_length(_rg.nodes) && !_has; _j++) if (array_contains(_h.kinds, _rg.nodes[_j].kind)) _has = true;
		if (_has) array_push(_out, _h);
	}
	return _out;
}
