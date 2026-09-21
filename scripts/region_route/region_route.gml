/// @description region_route(pn, terr, ri, tmap, a, b) -> [{ x, y }] the road from node a to node b OVER THE TERRITORY'S LAND, in the map's unit frame (the ends the nodes' own x / y), or undefined when no land path joins them (q304, his report: "roads cutting through water")
/// Dijkstra on the base texels of the region's own land (terr.ids, above the
/// sea), eight-connected with the strait's corner rule (a diagonal only where
/// an orthogonal step would do): a step costs its ground - a river or a lake
/// eight times (a ford, if there is no way round), a range twice and a bit,
/// a peak three times, marsh and ice a half more, a crater or a flow never.
/// The texel path comes back through the frame (region_place's unit) and is
/// smoothed once (Chaikin, the ends held). Nothing rolled
function region_route(_pn, _terr, _ri, _tm, _a, _b, _used = undefined) {   // (used: the texels earlier roads took - a third the cost, so a road joins one rather than cutting across; marked on the way out; q305)
	if (!is_struct(_pn) || !is_struct(_terr) || !is_struct(_tm)) return undefined;
	if (is_undefined(_a[$ "tx"]) || is_undefined(_b[$ "tx"])) return undefined;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _el = _pn.elev, _bm = _pn.biome, _sea = _pn.sea, _rl = _pn[$ "rlift"], _vm = _pn[$ "vmask"], _ids = _terr.ids, _id = _ri + 1;
	var _s = _a.tx + _a.ty * _tw, _g = _b.tx + _b.ty * _tw;
	if (_s == _g) return [ { x : _a.x, y : _a.y }, { x : _b.x, y : _b.y } ];
	var _okf = function(_i, _ids0, _id0, _el0, _sea0, _vm0) { return _ids0[_i] == _id0 && _el0[_i] >= _sea0 && !(is_array(_vm0) && _vm0[_i] > 0); };
	if (!_okf(_s, _ids, _id, _el, _sea, _vm) || !_okf(_g, _ids, _id, _el, _sea, _vm)) return undefined;
	// A*: the ground distance to the goal under the cost (a step costs at least its ground), so the walk is a corridor,
	// not a flood - a region's twenty roads route in a few milliseconds (the regions all stand at the world's first draw)
	var _gx0 = _g mod _tw, _gy0 = _g div _tw, _clg = max(.2, sin(pi * (_gy0 + .5) / _th));
	var _dist = ds_map_create(), _prev = ds_map_create(), _done = ds_map_create(), _q = ds_priority_create();
	ds_map_set(_dist, _s, 0); ds_priority_add(_q, _s, 0);
	static _ox = [1, -1, 0, 0, 1, 1, -1, -1];
	static _oy = [0, 0, 1, -1, 1, -1, 1, -1];
	var _found = false, _steps = 0, _hasv = is_array(_vm), _hasr = is_array(_rl), _hasu = is_array(_used);
	while (!ds_priority_empty(_q) && _steps < 4000) {
		_steps++;
		var _i = ds_priority_delete_min(_q);
		if (_i == _g) { _found = true; break; }
		if (!is_undefined(ds_map_find_value(_done, _i))) continue;
		ds_map_set(_done, _i, true);
		var _di = ds_map_find_value(_dist, _i);
		var _x = _i mod _tw, _y = _i div _tw, _cl = max(.2, sin(pi * (_y + .5) / _th));
		for (var _k = 0; _k < 8; _k++) {
			var _ny = _y + _oy[_k]; if (_ny < 0 || _ny >= _th) continue;
			var _nx = (_x + _ox[_k] + _tw) mod _tw, _j = _nx + _ny * _tw;
			if (_ids[_j] != _id || _el[_j] < _sea || (_hasv && _vm[_j] > 0)) continue;
			if (_k >= 4) {   // (never across a strait's corner: one of the orthogonal steps must be the region's land)
				var _ja = _nx + _y * _tw, _jb = _x + _ny * _tw;
				if (!((_ids[_ja] == _id && _el[_ja] >= _sea) || (_ids[_jb] == _id && _el[_jb] >= _sea))) continue;
			}
			var _base = (_k < 4) ? ((_ox[_k] != 0) ? _cl : 1) : sqrt(_cl * _cl + 1);
			var _m = 1, _bb = _bm[_j];
			if (_bb == 1 || _bb == 11) _m = 8; else if (_bb == 9 || _bb == 10) _m = 3; else if (_bb == 12 || _bb == 14) _m = 1.5;
			if (_m == 1 && _hasr && _rl[_j] > .06) _m = 2.2;
			if (_hasu && _used[_j] > 0) _m *= .34;   // (an earlier road's texel: the road follows it - q305, his "roads crossing over each other")
			var _nd = _di + _base * _m;
			var _od = ds_map_find_value(_dist, _j);
			if (!is_undefined(_od) && _od <= _nd) continue;
			ds_map_set(_dist, _j, _nd); ds_map_set(_prev, _j, _i);
			var _hx = abs(_nx - _gx0); _hx = min(_hx, _tw - _hx);
			ds_priority_add(_q, _j, _nd + sqrt(sqr(_hx * _clg) + sqr(_ny - _gy0)));
		}
	}
	var _out = undefined;
	if (_found) {
		// the texels back from the goal, then through the frame; the ends are the nodes' own
		var _path = [], _c = _g;
		while (_c != _s && array_length(_path) < 4000) { array_push(_path, _c); _c = ds_map_find_value(_prev, _c); if (is_undefined(_c)) break; }
		array_push(_path, _s);
		if (_hasu) for (var _p = 0; _p < array_length(_path); _p++) _used[_path[_p]] = 1;
		var _u = [];
		for (var _p = array_length(_path) - 1; _p >= 0; _p--) {
			var _t = _path[_p], _tx = _t mod _tw, _ty = _t div _tw;
			var _gx = (((_tx - _tm.sx + _tw + (_tw div 2)) mod _tw) - (_tw div 2)) * _tm.cl, _gy = _ty - _tm.sy;
			array_push(_u, { x : .5 + (_gx - _tm.cxm) / _tm.span * _tm.k, y : .5 + (_gy - _tm.cym) / _tm.span * _tm.k });
		}
		// smoothed once (chaikin), the ends the nodes' own points
		_out = [ { x : _a.x, y : _a.y } ];
		for (var _p = 0; _p < array_length(_u) - 1; _p++) {
			var _p0 = _u[_p], _p1 = _u[_p + 1];
			if (_p > 0) array_push(_out, { x : _p0.x * .75 + _p1.x * .25, y : _p0.y * .75 + _p1.y * .25 });
			if (_p < array_length(_u) - 2) array_push(_out, { x : _p0.x * .25 + _p1.x * .75, y : _p0.y * .25 + _p1.y * .75 });
		}
		array_push(_out, { x : _b.x, y : _b.y });
	}
	ds_map_destroy(_dist); ds_map_destroy(_prev); ds_map_destroy(_done); ds_priority_destroy(_q);
	return _out;
}
