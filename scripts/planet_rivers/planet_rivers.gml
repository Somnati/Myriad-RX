/// @description planet_rivers(pn) - RIVERS AND LAKES (2026-09-16; the drainage way 2026-09-17): channels one texel wide set into the biome map as shallows, the lakes they pass through as water
/// THE DRAINAGE (his ask, 2026-09-17: "branch out from large bodies of
/// water and fit snug in lower elevation areas ... passing between two
/// mountain passes and connecting to an ocean"): the first rivers ran
/// down from high ground and half of them died in pits nobody drew. Now
/// the land DRAINS. A flood climbs from the water over every land texel
/// in order of height (a priority flood on a bucket queue - no heap): a
/// pit fills to the level of its spill, and every texel remembers a
/// neighbour it can flow down to - so from anywhere, downhill reaches the
/// sea, by construction. Then the catchment: each texel counts the texels
/// that drain through it, children before parents. A river is every
/// texel whose catchment is big enough (a slice of the land), on a system
/// whose mouth's is bigger still - so the channels lie in the valleys
/// where the water gathers, thread a range at its pass (the spill is the
/// pass), branch as tributaries where two valleys meet, and end in the
/// sea, every one. A basin the flood had to fill under a drawn river
/// becomes a LAKE. A grain of hashed noise on the heights keeps the
/// channels from running dead straight along the grid. Once a world,
/// before its bake (planet_bake); everything hashed off the seed, so a
/// world keeps its rivers between loads. Gas worlds and dry worlds have none.
function planet_rivers(_pn) {
	if (_pn[$ "rivers"] ?? false) return;
	_pn.rivers = true;
	if (_pn.kind == "gas" || _pn.sea <= 0) return;
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _bm = _pn.biome, _el = _pn.elev, _seed = _pn.seed, _sea = _pn.sea;
	// ---- the water, and the heights with a grain of noise (never the map's own array) ----
	var _wat = array_create(_n, false), _ej = array_create(_n, 0), _nz = array_create(_n, 0), _nw = 0;
	for (var _i = 0; _i < _n; _i++) {
		var _b0 = _bm[_i];
		if (_b0 == 0 || _b0 == 1 || _b0 == 11) { _wat[_i] = true; _nw++; }
		// a grain of noise a texel (a small exact hash inline - fifty thousand of them; every product stays under 2^53)
		var _hx = (_i * 2654435761 + _seed) mod 2147483647;
		_hx = ((_hx ^ (_hx >> 13)) * 48271) mod 2147483647;
		_nz[_i] = (_hx mod 1000) / 1000;
		_ej[_i] = _el[_i] + .004 * (_nz[_i] - .5);
	}
	if (_nw == 0 || _nw == _n) return;
	// ---- the flood: buckets of height, the water first ----
	var _nb = 1024, _bw = (1 - _sea) / (_nb - 1);
	var _fill = array_create(_n, 0), _par = array_create(_n, -1), _done = array_create(_n, false);
	var _bhead = array_create(_nb, -1), _bnext = array_create(_n, -1);
	var _order = array_create(_n, 0), _no = 0;
	for (var _i = 0; _i < _n; _i++) if (_wat[_i]) { _fill[_i] = _sea; _done[_i] = true; }
	for (var _i = 0; _i < _n; _i++) {
		if (!_wat[_i]) continue;
		var _cx = _i mod _tw, _cy = _i div _tw;
		for (var _dy = -1; _dy <= 1; _dy++) {
			var _ny = _cy + _dy;
			if (_ny < 0 || _ny >= _th) continue;
			for (var _dx = -1; _dx <= 1; _dx++) {
				if (_dx == 0 && _dy == 0) continue;
				var _ni = ((_cx + _dx + _tw) mod _tw) + _ny * _tw;
				if (_done[_ni] || _par[_ni] >= 0) continue;
				_fill[_ni] = max(_ej[_ni], _sea + _bw * (1 + .8 * _nz[_ni]));
				_par[_ni] = _i;
				var _bk = clamp(floor((_fill[_ni] - _sea) / _bw), 0, _nb - 1);
				_bnext[_ni] = _bhead[_bk]; _bhead[_bk] = _ni;
			}
		}
	}
	for (var _bk = 0; _bk < _nb; _bk++) {
		while (_bhead[_bk] >= 0) {
			var _i = _bhead[_bk]; _bhead[_bk] = _bnext[_i]; _bnext[_i] = -1;
			if (_done[_i]) continue;
			_done[_i] = true; _order[_no++] = _i;
			var _cx = _i mod _tw, _cy = _i div _tw, _fi = _fill[_i];
			for (var _dy = -1; _dy <= 1; _dy++) {
				var _ny = _cy + _dy;
				if (_ny < 0 || _ny >= _th) continue;
				for (var _dx = -1; _dx <= 1; _dx++) {
					if (_dx == 0 && _dy == 0) continue;
					var _ni = ((_cx + _dx + _tw) mod _tw) + _ny * _tw;
					if (_done[_ni] || _par[_ni] >= 0) continue;
					// the fill: its own height, or a hair above the texel it was reached from (so nothing is ever level, and a
					// basin drains toward the way the flood came in - its spill)
					_fill[_ni] = max(_ej[_ni], _fi + _bw * (1 + .8 * _nz[_ni]));
					_par[_ni] = _i;
					var _bk2 = clamp(floor((_fill[_ni] - _sea) / _bw), 0, _nb - 1);
					_bnext[_ni] = _bhead[_bk2]; _bhead[_bk2] = _ni;
				}
			}
		}
	}
	// ---- the outflow: the lowest neighbour on the filled surface (the flood's own parent guarantees one lower) ----
	for (var _k = 0; _k < _no; _k++) {
		var _i = _order[_k], _cx = _i mod _tw, _cy = _i div _tw, _bv = _fill[_i], _bp = _par[_i];
		for (var _dy = -1; _dy <= 1; _dy++) {
			var _ny = _cy + _dy;
			if (_ny < 0 || _ny >= _th) continue;
			for (var _dx = -1; _dx <= 1; _dx++) {
				if (_dx == 0 && _dy == 0) continue;
				var _ni = ((_cx + _dx + _tw) mod _tw) + _ny * _tw;
				var _fv = _fill[_ni];
				if (_fv < _bv) { _bv = _fv; _bp = _ni; }
			}
		}
		_par[_i] = _bp;
	}
	// ---- the catchment: children before parents (the flood's order, backwards) ----
	var _acc = array_create(_n, 0);
	for (var _k = 0; _k < _no; _k++) _acc[_order[_k]] = 1;
	for (var _k = _no - 1; _k >= 0; _k--) {
		var _i = _order[_k], _p = _par[_i];
		if (_p >= 0 && !_wat[_p]) _acc[_p] += _acc[_i];
	}
	// ...and the catchment at each system's MOUTH, handed down the tree (parents first)
	var _mouth = array_create(_n, 0);
	for (var _k = 0; _k < _no; _k++) {
		var _i = _order[_k], _p = _par[_i];
		_mouth[_i] = (_p < 0 || _wat[_p]) ? _acc[_i] : _mouth[_p];
	}
	// ---- into the map: a river where the catchment is a slice of the land, on a system whose mouth's is three; ----
	// ---- a lake where the flood filled a basin under one. Never on snow, glacier or a peak, never at the poles ----
	var _land = _no, _t = max(6, round(_land * .0015)), _tm = _t * 3, _laked = .008;
	var _pole = max(2, round(_th * .04));
	for (var _k = 0; _k < _no; _k++) {
		var _i = _order[_k];
		if (_mouth[_i] < _tm) continue;
		var _yy = _i div _tw;
		if (_yy < _pole || _yy >= _th - _pole) continue;
		var _b = _bm[_i];
		if (_b == 8 || _b == 9 || _b == 10 || _b == 14) continue;
		if (_fill[_i] - _ej[_i] > _laked) _bm[_i] = 1;          // a lake
		else if (_acc[_i] >= _t) _bm[_i] = 11;                  // a river
	}
}
