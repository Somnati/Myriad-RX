/// @description region_place(nodes, pn, terr, ri) -> the region's frame { sx, sy, cl, span, cxm, cym, x0, y0, w, h } - EVERY PLACE ON A TEXEL OF ITS TERRITORY (q288): each node's texel chosen for its kind among the territory's own land, two to six texels of ground from its parent (the tree the layout grew), clear of the others; its unit x / y (the map's frame) from the territory's bounding box. Rolls on the region's stream (region_gen's seed is set)
function region_place(_nodes, _pn, _terr, _ri) {
	var _tw = _pn.tw, _th = _pn.th, _ids = _terr.ids, _el = _pn.elev, _bm = _pn.biome, _sea = _pn.sea, _rl = _pn[$ "rlift"], _id = _ri + 1;
	var _sx = _terr.seeds[_ri][0], _sy = _terr.seeds[_ri][1], _cl = max(.2, sin(pi * (_sy + .5) / _th));
	// the territory's land, with what each texel is: coastal (a sea texel beside it), by water (a river or a lake or the coast), on a range
	var _T = [], _minx = 9999, _maxx = -9999, _miny = 9999, _maxy = -9999;
	for (var _i = 0; _i < array_length(_ids); _i++) {
		if (_ids[_i] != _id || _el[_i] < _sea) continue;
		var _b = _bm[_i];
		if (_b == 0 || _b == 1 || _b == 11 || _b == 25) continue;
		var _x = _i mod _tw, _y = _i div _tw;
		var _dx = ((_x - _sx + _tw + (_tw div 2)) mod _tw) - (_tw div 2), _dy = _y - _sy;
		var _l = ((_x + _tw - 1) mod _tw) + _y * _tw, _r = ((_x + 1) mod _tw) + _y * _tw, _u = (_y > 0) ? _i - _tw : _i, _dn = (_y < _th - 1) ? _i + _tw : _i;
		var _coast = (_el[_l] < _sea || _el[_r] < _sea || _el[_u] < _sea || _el[_dn] < _sea);
		var _wat = _coast || (_bm[_l] == 1 || _bm[_l] == 11 || _bm[_r] == 1 || _bm[_r] == 11 || _bm[_u] == 1 || _bm[_u] == 11 || _bm[_dn] == 1 || _bm[_dn] == 11);
		var _rng = is_array(_rl) && _rl[_i] > .06;
		array_push(_T, { i : _i, dx : _dx, dy : _dy, b : _b, coast : _coast, wat : _wat, rng : _rng, gx : _dx * _cl, gy : _dy });
		_minx = min(_minx, _dx); _maxx = max(_maxx, _dx); _miny = min(_miny, _dy); _maxy = max(_maxy, _dy);
	}
	if (array_length(_T) == 0) return undefined;
	var _w = _maxx - _minx + 1, _h = _maxy - _miny + 1;
	var _span = max(_w * _cl, _h, 4), _cxm = (_minx + _maxx + 1) * .5 * _cl, _cym = (_miny + _maxy + 1) * .5;
	var _unit = function(_gx, _gy, _cxm2, _cym2, _span2) { return { x : .5 + (_gx - _cxm2) / _span2 * .84, y : .5 + (_gy - _cym2) / _span2 * .84 }; };
	// how a kind likes a texel
	var _pref = function(_k, _t) {
		var _b = _t.b;
		switch (_k) {
			case "settlement": case "village": case "town": case "city": case "landing":
				return ((_b == 4 || _b == 21 || _b == 2 || _b == 5 || _b == 22 || _b == 3) ? 1 : .2) * (_t.wat ? 1.6 : 1) * (_t.rng ? .3 : 1);
			case "coast":     return _t.coast ? 1 : .05;
			case "forest":    return (_b == 5 || _b == 6 || _b == 22) ? 1 : .15;
			case "marsh":     return (_b == 12) ? 1 : .1;
			case "desert":    return (_b == 3 || _b == 13 || _b == 23 || _b == 24) ? 1 : .1;
			case "hills":     return (_b == 23 || _b == 15 || _b == 16 || _b == 17 || (_t.rng && !(_b == 9 || _b == 10))) ? 1 : .25;
			case "mountains": return (_b == 9 || _b == 10 || _b == 18 || _t.rng) ? 1 : .1;
			case "tundra":    return (_b == 7 || _b == 8 || _b == 14) ? 1 : .1;
			case "field":     return (_b == 4 || _b == 21) ? 1 : .2;
			case "mine":      return _t.rng ? 1 : ((_b == 23 || _b == 17) ? .8 : .15);
			case "camp":      return (_b == 5 || _b == 6 || _b == 22 || _b == 23 || _t.rng) ? 1 : .4;
			case "dungeon": case "crypt": case "ruin": case "shrine": return (_b == 23 || _b == 5 || _b == 22 || _b == 7 || _t.rng) ? 1 : .5;
		}
		return .5;
	};
	var _n = array_length(_nodes), _sep = clamp(sqrt(array_length(_T) / max(1, _n)) * .55, 1.5, 4), _placed = [], _pciv = [], _kk = region_kinds();
	for (var _k = 0; _k < _n; _k++) {
		var _nd = _nodes[_k], _par = (_nd.par >= 0 && _nd.par < _k) ? _nodes[_nd.par] : undefined;
		var _best = undefined, _bs = -1, _far = undefined, _fd = -1;
		repeat (48) {
			var _t = _T[irandom(array_length(_T) - 1)];
			var _s = _pref(_nd.kind, _t);
			// the landing near the middle; every other place two to six texels of ground from its parent
			if (_k == 0) _s *= 1 / (1 + point_distance(_t.gx, _t.gy, _cxm, _cym) / max(1, _span * .25));
			else if (is_struct(_par)) { var _gd = point_distance(_t.gx, _t.gy, _par.gx, _par.gy); _s *= (_gd < 1.5) ? 0 : ((_gd <= 6) ? 1 : max(.08, 6 / _gd)); }
			var _dmin = 99;
			for (var _p = 0; _p < array_length(_placed); _p++) _dmin = min(_dmin, point_distance(_t.gx, _t.gy, _placed[_p].gx, _placed[_p].gy));
			// CAMPS AWAY FROM TOWNS (his ask, 2026-09-15 - kept on the ground): a camp within four texels of a settled place is a poor spot
			if (_nd.kind == "camp") { var _dc = 99; for (var _p2 = 0; _p2 < array_length(_placed); _p2++) if (_pciv[_p2]) _dc = min(_dc, point_distance(_t.gx, _t.gy, _placed[_p2].gx, _placed[_p2].gy)); if (_dc < 4) _s *= .15; }
			if (_dmin < _sep) _s = 0;
			if (_dmin > _fd) { _fd = _dmin; _far = _t; }
			_s *= .7 + random(.6);
			if (_s > _bs) { _bs = _s; _best = _t; }
		}
		if (_bs <= 0) _best = _far;   // (nowhere clear: the emptiest corner)
		var _uxy = _unit(_best.gx, _best.gy, _cxm, _cym, _span);
		_nd.x = _uxy.x; _nd.y = _uxy.y; _nd.tx = _best.i mod _tw; _nd.ty = _best.i div _tw; _nd.gx = _best.gx; _nd.gy = _best.gy;
		array_push(_placed, _best); array_push(_pciv, is_struct(_kk[$ _nd.kind]) && _kk[$ _nd.kind].civ);
	}
	return { sx : _sx, sy : _sy, cl : _cl, span : _span, cxm : _cxm, cym : _cym, x0 : _minx, y0 : _miny, w : _w, h : _h };
}
