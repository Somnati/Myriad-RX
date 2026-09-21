/// @description region_islets(pn, terr, ri) -> { off : [bool a texel: the region's land NOT on the seed's piece], isles : [{ at, n }] } - the territory's ISLETS (q306): the land the walk joined whole (q297) but no road reaches - each one's size and the texel nearest its middle, largest first
/// A flood from the seed over the region's own land (four-connected); what
/// it never reaches is an islet. Nothing rolled
function region_islets(_pn, _terr, _ri) {
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _el = _pn.elev, _sea = _pn.sea, _ids = _terr.ids, _id = _ri + 1;
	var _off = array_create(_n, false), _seen = array_create(_n, false), _out = { off : _off, isles : [] };
	if (_ri >= array_length(_terr.seeds)) return _out;
	var _s = _terr.seeds[_ri][0] + _terr.seeds[_ri][1] * _tw;
	if (_ids[_s] != _id || _el[_s] < _sea) return _out;
	var _flood = function(_from, _seen0, _ids0, _id0, _el0, _sea0, _tw0, _th0) {   // -> the texels reached
		var _stk = [_from], _got = [];
		_seen0[_from] = true;
		while (array_length(_stk) > 0) {
			var _i = array_pop(_stk); array_push(_got, _i);
			var _x = _i mod _tw0, _y = _i div _tw0;
			var _nb = [((_x + _tw0 - 1) mod _tw0) + _y * _tw0, ((_x + 1) mod _tw0) + _y * _tw0, (_y > 0) ? _i - _tw0 : -1, (_y < _th0 - 1) ? _i + _tw0 : -1];
			for (var _q = 0; _q < 4; _q++) { var _j = _nb[_q]; if (_j < 0 || _seen0[_j] || _ids0[_j] != _id0 || _el0[_j] < _sea0) continue; _seen0[_j] = true; array_push(_stk, _j); }
		}
		return _got;
	};
	_flood(_s, _seen, _ids, _id, _el, _sea, _tw, _th);
	for (var _i = 0; _i < _n; _i++) {
		if (_seen[_i] || _ids[_i] != _id || _el[_i] < _sea) continue;
		var _cells = _flood(_i, _seen, _ids, _id, _el, _sea, _tw, _th), _cn = array_length(_cells);
		var _sx = 0, _sy = 0, _x0 = _cells[0] mod _tw;
		for (var _c = 0; _c < _cn; _c++) { var _cx = _cells[_c] mod _tw; _sx += ((_cx - _x0 + _tw + (_tw div 2)) mod _tw) - (_tw div 2); _sy += _cells[_c] div _tw; _off[_cells[_c]] = true; }
		var _mx = (((_x0 + _sx / _cn) mod _tw) + _tw) mod _tw, _my = _sy / _cn, _best = _cells[0], _bd = 1000000;
		for (var _c = 0; _c < _cn; _c++) { var _cx2 = _cells[_c] mod _tw, _dx = abs(_cx2 - _mx); _dx = min(_dx, _tw - _dx); var _dd = sqr(_dx) + sqr((_cells[_c] div _tw) - _my); if (_dd < _bd) { _bd = _dd; _best = _cells[_c]; } }
		array_push(_out.isles, { at : _best, n : _cn });
	}
	array_sort(_out.isles, function(_a, _b) { return _b.n - _a.n; });
	return _out;
}
