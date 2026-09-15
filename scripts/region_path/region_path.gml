/// @description region_path(region, a, b) -> the nodes to walk from a to b, a excluded, b last ([] = there already or unreachable)
/// Dijkstra by hours over the region's roads (a dozen nodes: plain arrays).
function region_path(_rg, _a, _b) {
	var _n = array_length(_rg.nodes);
	if (_a == _b || _a < 0 || _b < 0 || _a >= _n || _b >= _n) return [];
	var _dist = array_create(_n, 999999), _prev = array_create(_n, -1), _done = array_create(_n, false);
	_dist[_a] = 0;
	repeat (_n) {
		var _u = -1, _best = 999999;
		for (var _i = 0; _i < _n; _i++) if (!_done[_i] && _dist[_i] < _best) { _best = _dist[_i]; _u = _i; }
		if (_u < 0) break;
		_done[_u] = true;
		if (_u == _b) break;
		var _nb = region_neighbors(_rg, _u);
		for (var _k = 0; _k < array_length(_nb); _k++) {
			var _v = _nb[_k].j, _nd = _dist[_u] + _nb[_k].d;
			if (_nd < _dist[_v]) { _dist[_v] = _nd; _prev[_v] = _u; }
		}
	}
	if (_dist[_b] >= 999999) return [];
	var _path = [];
	var _c = _b;
	while (_c != _a && _c >= 0) { array_insert(_path, 0, _c); _c = _prev[_c]; }
	return _path;
}
