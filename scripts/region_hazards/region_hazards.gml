/// @description region_hazards(region, [dest]) -> the hazards its places carry, each once, in the roster's order (cbt_hazards); with the world given, the season's too (region_hazard_at)
function region_hazards(_rg, _d = undefined) {
	var _out = [], _hz = cbt_hazards();
	// the region's KINDS once, and the hazard at each once (region_hazard_at reads the season and the event: not one call a node a hazard a frame - bug hunt 2026-09-16)
	var _kinds = [], _ats = [];
	for (var _j = 0; _j < array_length(_rg.nodes); _j++) { var _kd = _rg.nodes[_j].kind; if (!array_contains(_kinds, _kd)) array_push(_kinds, _kd); }
	for (var _j = 0; _j < array_length(_kinds); _j++) array_push(_ats, is_struct(_d) ? region_hazard_at(_d, _rg, _kinds[_j]) : cbt_hazard_at(_kinds[_j]));
	for (var _i = 0; _i < array_length(_hz); _i++) {
		var _h = _hz[_i], _has = false;
		for (var _j = 0; _j < array_length(_ats) && !_has; _j++) if (is_struct(_ats[_j]) && _ats[_j].key == _h.key) _has = true;
		if (_has) array_push(_out, _h);
	}
	return _out;
}
