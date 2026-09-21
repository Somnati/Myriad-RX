/// @description planet_territories(pn, [until]) -> true once the world's TERRITORIES stand (pn.terr; q287): the land cut into regions by a walk from every seed at once, sliced under the deadline; the id sheet (pn.rbuf) for sh_planet
/// A region wants REGION_AREA land texels: the count is the land over
/// that (3 .. REGION_MAX). The gate seed lands on green off the poles
/// (the old first region's law); the rest are Poisson-spread by ground
/// distance. Then Dial's walk: buckets on integer costs, a step the
/// ground it covers (east-west shrinks toward the poles) times the
/// terrain under the far texel - a range crest, a peak, a river, a lake
/// three times; marsh and ice twice; the sea eight, so an island with
/// no seed joins the nearest coast across the strait - and the borders
/// fall along ridges and rivers where two walks meet. The sea within
/// three texels of land keeps its owner (territorial waters), the deep
/// is nobody's. Neighbours from the shared edges; the level by ring
/// from the gate. Resumable (pn.terr_st holds the walk between calls);
/// from planet_bake before its rows, so a world that stands has them
function planet_territories(_pn, _until = infinity) {
	if (is_struct(_pn[$ "terr"])) return true;
	if (_pn.kind == "gas" || _pn.tw < 200) return true;   // (a giant has no land; a stamp hosts no regions)
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _el = _pn.elev, _bm = _pn.biome, _sea = _pn.sea, _rl = _pn[$ "rlift"];
	var _st = _pn[$ "terr_st"];
	if (!is_struct(_st)) {
		// ---- the seeds ----
		var _land = 0;
		for (var _i = 0; _i < _n; _i++) if (_el[_i] >= _sea) _land++;
		var _want = clamp(floor(_land / REGION_AREA), 3, REGION_MAX);
		var _seeds = [];
		var _h = function(_s, _k) { return (hash_mix(_s, 40000 + _k) mod 10000) / 10000; };
		var _okl = function(_b, _e, _s) { return _e >= _s && !(_b == 0 || _b == 1 || _b == 11 || _b == 25 || _b == 9 || _b == 10 || _b == 14); };
		var _rmin = sqrt(REGION_AREA) * .85;
		for (var _t = 0; _t < 240 && array_length(_seeds) == 0; _t++) {
			var _x = floor(_h(_pn.seed, _t * 2) * _tw), _y = floor((.18 + .64 * _h(_pn.seed, _t * 2 + 1)) * _th), _i = _x + _y * _tw, _b = _bm[_i];
			if (!_okl(_b, _el[_i], _sea)) continue;
			if (_t < 140 && !(_b == 4 || _b == 5 || _b == 6 || _b == 21 || _b == 22)) continue;   // (the gate is green while it can be)
			array_push(_seeds, [_x, _y]);
		}
		if (array_length(_seeds) == 0) for (var _i = 0; _i < _n && array_length(_seeds) == 0; _i++) if (_el[_i] >= _sea) array_push(_seeds, [_i mod _tw, _i div _tw]);
		if (array_length(_seeds) == 0) { _pn.terr = { n : 0, ids : [], seeds : [], area : [], adj : [], ring : [], lv : [] }; return true; }   // (a world with no land at all)
		for (var _t = 0; _t < _want * 40 && array_length(_seeds) < _want; _t++) {
			var _x = floor(_h(_pn.seed, 1000 + _t * 2) * _tw), _y = floor((.06 + .88 * _h(_pn.seed, 1001 + _t * 2)) * _th), _i = _x + _y * _tw;
			if (!_okl(_bm[_i], _el[_i], _sea)) continue;
			var _cl = max(.2, sin(pi * (_y + .5) / _th)), _ok = true;
			for (var _k = 0; _k < array_length(_seeds) && _ok; _k++) {
				var _dx = abs(_x - _seeds[_k][0]); _dx = min(_dx, _tw - _dx);
				if (sqrt(sqr(_dx * _cl) + sqr(_y - _seeds[_k][1])) < _rmin) _ok = false;
			}
			if (_ok) array_push(_seeds, [_x, _y]);
		}
		// ---- the walk's state: dial's buckets on integer costs ----
		var _dist = array_create(_n, 1000000), _own = array_create(_n, 0), _bk = array_create(TERR_CMAX + 1, -1);
		_bk[0] = [];
		for (var _k = 0; _k < array_length(_seeds); _k++) { var _i = _seeds[_k][0] + _seeds[_k][1] * _tw; _dist[_i] = 0; _own[_i] = _k + 1; array_push(_bk[0], _i); }
		_st = { seeds : _seeds, dist : _dist, own : _own, bk : _bk, c : 0, land : _land };
		_pn.terr_st = _st;
	}
	// ---- the walk, sliced ----
	var _ds = _st.dist, _ow = _st.own, _bq = _st.bk, _c = _st.c;
	static _ox = [1, -1, 0, 0, 1, 1, -1, -1];
	static _oy = [0, 0, 1, -1, 1, -1, 1, -1];
	while (_c <= TERR_CMAX) {
		var _q = _bq[_c];
		if (is_array(_q)) {
			while (array_length(_q) > 0) {
				var _i = array_pop(_q);
				if (_ds[_i] != _c) continue;   // (a stale entry: the texel was reached cheaper since)
				var _x = _i mod _tw, _y = _i div _tw, _cl = max(.2, sin(pi * (_y + .5) / _th));
				for (var _k = 0; _k < 8; _k++) {
					var _ny = _y + _oy[_k]; if (_ny < 0 || _ny >= _th) continue;
					var _nx = (_x + _ox[_k] + _tw) mod _tw, _j = _nx + _ny * _tw;
					var _base = (_k < 4) ? ((_ox[_k] != 0) ? 4 * _cl : 4) : sqrt(sqr(4 * _cl) + 16);
					var _m = 1, _b = _bm[_j];
					if (_el[_j] < _sea) _m = 8;
					else if (_b == 1 || _b == 11 || _b == 9 || _b == 10) _m = 3;
					else if (_b == 12 || _b == 14) _m = 2;
					if (_m == 1 && is_array(_rl) && _rl[_j] > .06) _m = 3;
					var _nc = _c + max(1, round(_base * _m));
					if (_nc > TERR_CMAX || _nc >= _ds[_j]) continue;
					_ds[_j] = _nc; _ow[_j] = _ow[_i];
					if (!is_array(_bq[_nc])) _bq[_nc] = [];
					array_push(_bq[_nc], _j);
				}
				if ((array_length(_q) & 63) == 0 && get_timer() >= _until) { _st.c = _c; return false; }
			}
			_bq[_c] = -1;
		}
		_c++;
		if ((_c & 15) == 0 && get_timer() >= _until) { _st.c = _c; return false; }
	}
	// ---- done: the waters, the borders, the neighbours, the rings, the sheet ----
	var _sds = _st.seeds, _nr = array_length(_sds);
	var _sd = array_create(_n, 99);
	for (var _i = 0; _i < _n; _i++) if (_el[_i] >= _sea) _sd[_i] = 0;
	for (var _p = 1; _p <= 3; _p++) for (var _i = 0; _i < _n; _i++) {
		if (_sd[_i] != 99) continue;
		var _x = _i mod _tw, _y = _i div _tw;
		var _l = ((_x + _tw - 1) mod _tw) + _y * _tw, _r = ((_x + 1) mod _tw) + _y * _tw;
		if (_sd[_l] == _p - 1 || _sd[_r] == _p - 1 || (_y > 0 && _sd[_i - _tw] == _p - 1) || (_y < _th - 1 && _sd[_i + _tw] == _p - 1)) _sd[_i] = _p;
	}
	var _ids = array_create(_n, 0);
	for (var _i = 0; _i < _n; _i++) _ids[_i] = (_sd[_i] <= 3) ? _ow[_i] : 0;
	// THE LAND SMOOTHED (q296; his report: "stray lines off in nowhere"): a land texel whose land neighbours mostly belong to
	// one other region joins it - two passes, the seeds held - so the walk's one-texel enclaves and hairs go before the
	// borders, the neighbours and the crossings are read
	var _isseed = array_create(_n, false);
	for (var _k4 = 0; _k4 < _nr; _k4++) _isseed[_sds[_k4][0] + _sds[_k4][1] * _tw] = true;
	for (var _sp = 0; _sp < 2; _sp++) {
		var _nid = array_create(_n, 0);
		for (var _i4 = 0; _i4 < _n; _i4++) {
			_nid[_i4] = _ids[_i4];
			if (_el[_i4] < _sea || _ids[_i4] == 0 || _isseed[_i4]) continue;
			var _x4 = _i4 mod _tw, _y4 = _i4 div _tw;
			var _nb4 = [((_x4 + _tw - 1) mod _tw) + _y4 * _tw, ((_x4 + 1) mod _tw) + _y4 * _tw, (_y4 > 0) ? _i4 - _tw : -1, (_y4 < _th - 1) ? _i4 + _tw : -1];
			var _va = 0, _vb = 0, _vc = 0, _cnta = 0, _cntb = 0, _cntc = 0, _same = 0, _lnd4 = 0;
			for (var _q4 = 0; _q4 < 4; _q4++) {
				var _j4 = _nb4[_q4]; if (_j4 < 0 || _el[_j4] < _sea || _ids[_j4] == 0) continue;
				_lnd4++;
				var _v4 = _ids[_j4];
				if (_v4 == _ids[_i4]) { _same++; continue; }
				if (_va == 0 || _va == _v4) { _va = _v4; _cnta++; } else if (_vb == 0 || _vb == _v4) { _vb = _v4; _cntb++; } else { _vc = _v4; _cntc++; }
			}
			var _top = max(_cnta, _cntb, _cntc), _tv = (_cnta >= _cntb && _cnta >= _cntc) ? _va : ((_cntb >= _cntc) ? _vb : _vc);
			if (_lnd4 >= 2 && _top > _same && _top >= 2) _nid[_i4] = _tv;
		}
		_ids = _nid;
	}
	// THE COLOURS (q296, his ask: "a seeded region colour"): a hue a region, hashed off the world and its index - the sheet's
	// green carries it to the shader, region_col hands the same colour to the pages
	var _hue = array_create(_nr, 0);
	for (var _k = 0; _k < _nr; _k++) _hue[_k] = hash_mix(_pn.seed, 7000 + _k) mod 256;
	var _adj = array_create(_nr * _nr, false), _area = array_create(_nr, 0), _bord = array_create(_n, 0);
	// THE CROSSINGS (q291): for every pair of neighbours the best texel pair on their border - both on land if it can be
	// (a boat where the border runs through water), off the peaks, near the line between the two seeds - the passes
	// stand on it (region_gen). Keyed "a:b" with a < b (region indices); ta in a, tb in b
	var _cross = {};
	var _xsc = function(_i0, _j0, _a0, _b0, _el0, _bm0, _rl0, _sea0, _sds0, _tw0, _th0) {
		var _s = 0;
		var _la = (_el0[_i0] >= _sea0), _lb = (_el0[_j0] >= _sea0);
		if (!_la) _s += 12; if (!_lb) _s += 12;
		if (_bm0[_i0] == 9 || _bm0[_i0] == 10) _s += 6; if (_bm0[_j0] == 9 || _bm0[_j0] == 10) _s += 6;
		if (is_array(_rl0)) { if (_rl0[_i0] > .06) _s += 2; if (_rl0[_j0] > .06) _s += 2; }
		// the ground distance from the midpoint of the two seeds
		var _sa = _sds0[_a0 - 1], _sb = _sds0[_b0 - 1], _mx = _sa[0], _my = (_sa[1] + _sb[1]) * .5;
		var _ddx = ((_sb[0] - _sa[0] + _tw0 + (_tw0 div 2)) mod _tw0) - (_tw0 div 2); _mx = (((_sa[0] + _ddx * .5) mod _tw0) + _tw0) mod _tw0;
		var _x0 = _i0 mod _tw0, _y0 = _i0 div _tw0, _cl0 = max(.2, sin(pi * (_y0 + .5) / _th0));
		var _dx = ((_x0 - _mx + _tw0 + (_tw0 div 2)) mod _tw0) - (_tw0 div 2);
		return _s + sqrt(sqr(_dx * _cl0) + sqr(_y0 - _my)) * .5;
	};
	for (var _i = 0; _i < _n; _i++) {
		var _a = _ids[_i]; if (_a == 0) continue;
		if (_el[_i] >= _sea) _area[_a - 1]++;
		var _x = _i mod _tw, _y = _i div _tw;
		var _j1 = ((_x + 1) mod _tw) + _y * _tw, _j2 = (_y < _th - 1) ? _i + _tw : -1;
		var _b1 = _ids[_j1];
		if (_b1 != 0 && _b1 != _a) {
			_adj[(_a - 1) * _nr + (_b1 - 1)] = true; _adj[(_b1 - 1) * _nr + (_a - 1)] = true; _bord[_i] = 1; _bord[_j1] = 1;
			var _ck = string(min(_a, _b1) - 1) + ":" + string(max(_a, _b1) - 1), _cs = _xsc(_i, _j1, _a, _b1, _el, _bm, _rl, _sea, _sds, _tw, _th), _cc = _cross[$ _ck];
			if (!is_struct(_cc) || _cs < _cc.s) _cross[$ _ck] = { a : (_a < _b1) ? _i : _j1, b : (_a < _b1) ? _j1 : _i, boat : !(_el[_i] >= _sea && _el[_j1] >= _sea), s : _cs };
		}
		if (_j2 >= 0) { var _b2 = _ids[_j2]; if (_b2 != 0 && _b2 != _a) {
			_adj[(_a - 1) * _nr + (_b2 - 1)] = true; _adj[(_b2 - 1) * _nr + (_a - 1)] = true; _bord[_i] = 1; _bord[_j2] = 1;
			var _ck2 = string(min(_a, _b2) - 1) + ":" + string(max(_a, _b2) - 1), _cs2 = _xsc(_i, _j2, _a, _b2, _el, _bm, _rl, _sea, _sds, _tw, _th), _cc2 = _cross[$ _ck2];
			if (!is_struct(_cc2) || _cs2 < _cc2.s) _cross[$ _ck2] = { a : (_a < _b2) ? _i : _j2, b : (_a < _b2) ? _j2 : _i, boat : !(_el[_i] >= _sea && _el[_j2] >= _sea), s : _cs2 };
		} }
	}
	var _ring = array_create(_nr, -1); _ring[0] = 0;
	var _qq = [0], _qh = 0;
	while (_qh < array_length(_qq)) { var _a = _qq[_qh++]; for (var _b3 = 0; _b3 < _nr; _b3++) if (_adj[_a * _nr + _b3] && _ring[_b3] < 0) { _ring[_b3] = _ring[_a] + 1; array_push(_qq, _b3); } }
	var _lv = array_create(_nr, 0);
	for (var _k = 0; _k < _nr; _k++) _lv[_k] = (_ring[_k] < 0) ? 8 : min(8, round(_ring[_k] * 1.5));
	var _rb = buffer_create(_n * 4, buffer_fixed, 1), _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
	// (the sheet: red the id, green the region's hue, blue the SEA flag - the outline reads the sea as nobody's; q296)
	for (var _i = 0; _i < _n; _i++) { var _o = _i * 4; buffer_poke(_rb, _o + _or, buffer_u8, _ids[_i]); buffer_poke(_rb, _o + _og, buffer_u8, (_ids[_i] > 0) ? _hue[_ids[_i] - 1] : 0); buffer_poke(_rb, _o + _ob, buffer_u8, (_el[_i] < _sea) ? 255 : 0); buffer_poke(_rb, _o + _oa, buffer_u8, 255); }
	if (buffer_exists(_pn[$ "rbuf"] ?? -1)) buffer_delete(_pn.rbuf);
	_pn.rbuf = _rb; _pn.rsurf = -1;
	_pn.terr = { n : _nr, ids : _ids, seeds : _sds, area : _area, adj : _adj, ring : _ring, lv : _lv, cross : _cross, hue : _hue };
	_pn.terr_st = undefined;
	return true;
}
