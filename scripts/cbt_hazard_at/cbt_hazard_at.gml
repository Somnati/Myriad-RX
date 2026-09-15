/// @description cbt_hazard_at(node kind, [road]) -> the hazard a place of that kind carries (cbt_hazards), or undefined
/// road = true: the crew is on a road touching the place - the indoor
/// hazards (the dark) do not reach it.
function cbt_hazard_at(_kind, _road = false) {
	var _hz = cbt_hazards();
	for (var _i = 0; _i < array_length(_hz); _i++) {
		if (_road && _hz[_i].inside) continue;
		if (array_contains(_hz[_i].kinds, _kind)) return _hz[_i];
	}
	return undefined;
}
