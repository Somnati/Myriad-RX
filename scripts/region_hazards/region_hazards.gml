/// @description region_hazards(region, [dest]) -> the hazards its places carry, each once, in the roster's order (cbt_hazards); with the world given, the season's too (region_hazard_at)
function region_hazards(_rg, _d = undefined) {
	var _out = [], _hz = cbt_hazards();
	for (var _i = 0; _i < array_length(_hz); _i++) {
		var _h = _hz[_i], _has = false;
		for (var _j = 0; _j < array_length(_rg.nodes) && !_has; _j++) {
			var _at = is_struct(_d) ? region_hazard_at(_d, _rg, _rg.nodes[_j].kind) : (array_contains(_h.kinds, _rg.nodes[_j].kind) ? _h : undefined);
			if (is_struct(_at) && _at.key == _h.key) _has = true;
		}
		if (_has) array_push(_out, _h);
	}
	return _out;
}
