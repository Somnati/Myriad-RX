/// @description exped_explore_pick(trip, region) -> the next node an exploring crew wanders to
/// Lazy and dumb (his words): a neighbour, unvisited ones three times as
/// tempting, a place with an inn more so when there is coin and less
/// when there is none, the landing zone hardly at all; one time in ten
/// they wander off toward some far node for no reason.
function exped_explore_pick(_tr, _rg) {
	var _nb = region_neighbors(_rg, _tr.pos);
	if (array_length(_nb) == 0) return _rg.landing;
	if (roll_perc(10)) {
		var _far = irandom(array_length(_rg.nodes) - 1);
		if (_far != _tr.pos) { array_push(_tr.log, exped_crew_txt(_tr.names) + " wandered off toward " + _rg.nodes[_far].name + ". no reason was given"); return _far; }
	}
	var _kk = region_kinds();
	var _w = [], _sum = 0;
	for (var _i = 0; _i < array_length(_nb); _i++) {
		var _j = _nb[_i].j;
		var _nd = _rg.nodes[_j];
		var _kd = _kk[$ _nd.kind] ?? { civ : false, wild : true };
		var _wt = 1;
		if (!array_contains(_tr.visited, _j)) _wt *= 3;
		if (_kd.civ) _wt *= (_tr.credits > 0) ? 1.5 : .6;
		if (_nd.kind == "dungeon" || _nd.kind == "crypt" || _nd.kind == "camp") _wt *= 1.3;
		if (is_struct(exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _j, "quiet")) || is_struct(exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _j, "routed"))) _wt *= .3;   // (cleared lately: little there - the world remembers, 2026-09-16)
		if (_nd.kind == "landing") _wt *= .2;
		if (_nd.kind == "pass") _wt *= ((_tr[$ "recall"] ?? false) || _tr.credits <= 0) ? .05 : 1.2;   // (the border draws a little - nothing when recalled or broke; q291)
		array_push(_w, _wt); _sum += _wt;
	}
	var _r = random(_sum);
	for (var _i = 0; _i < array_length(_w); _i++) { _r -= _w[_i]; if (_r <= 0) return _nb[_i].j; }
	return _nb[array_length(_nb) - 1].j;
}
