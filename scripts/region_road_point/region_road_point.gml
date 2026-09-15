/// @description region_road_point(region, a, b, q) -> { x, y } - q (0..1) of the way along the road from node a to node b, on its bent line
/// The road's polyline (edge.pts, region_gen) walked by arc length; a
/// road stored the other way round is walked backwards. No road = the
/// straight line.
function region_road_point(_rg, _a, _b, _q) {
	_q = clamp(_q, 0, 1);
	var _pts = undefined, _rev = false;
	for (var _e = 0; _e < array_length(_rg.edges); _e++) {
		var _ed = _rg.edges[_e];
		if (_ed.a == _a && _ed.b == _b) { _pts = _ed[$ "pts"]; break; }
		if (_ed.a == _b && _ed.b == _a) { _pts = _ed[$ "pts"]; _rev = true; break; }
	}
	var _na = _rg.nodes[clamp(_a, 0, array_length(_rg.nodes) - 1)], _nb = _rg.nodes[clamp(_b, 0, array_length(_rg.nodes) - 1)];
	if (!is_array(_pts) || array_length(_pts) < 2) return { x : lerp(_na.x, _nb.x, _q), y : lerp(_na.y, _nb.y, _q) };
	var _len = 0;
	for (var _k = 1; _k < array_length(_pts); _k++) _len += point_distance(_pts[_k - 1].x, _pts[_k - 1].y, _pts[_k].x, _pts[_k].y);
	var _want = (_rev ? (1 - _q) : _q) * _len, _acc = 0;
	for (var _k = 1; _k < array_length(_pts); _k++) {
		var _sl = point_distance(_pts[_k - 1].x, _pts[_k - 1].y, _pts[_k].x, _pts[_k].y);
		if (_acc + _sl >= _want || _k == array_length(_pts) - 1) {
			var _f = (_sl > 0) ? clamp((_want - _acc) / _sl, 0, 1) : 0;
			return { x : lerp(_pts[_k - 1].x, _pts[_k].x, _f), y : lerp(_pts[_k - 1].y, _pts[_k].y, _f) };
		}
		_acc += _sl;
	}
	return { x : _nb.x, y : _nb.y };
}
