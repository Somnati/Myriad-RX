/// @description region_news(dest, ri) -> [{ txt, left }] this region's news, newest first (q285) - the crews' deeds beside the procedural event in the header
function region_news(_d, _ri) {
	var _out = [], _nw = g.exped[$ "news"];
	if (!is_array(_nw) || !is_struct(_d)) return _out;
	for (var _i = array_length(_nw) - 1; _i >= 0; _i--) {
		var _n = _nw[_i];
		if (!is_struct(_n) || _n.seed != _d.seed || (_n.ri != _ri && _n.ri >= 0)) continue;
		array_push(_out, { txt : _n.txt, left : _n.left });
	}
	return _out;
}
