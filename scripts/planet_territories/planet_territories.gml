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
	var _tw = _pn.tw, _th = _pn.th, _n = _tw * _th, _el = _pn.elev, _bm = _pn.biome, _sea = _pn.sea, _rl = _pn[$ "rlift"], _dt = _pn[$ "det"];
	var _st = _pn[$ "terr_st"];
	if (!is_struct(_st)) {
		// ---- the seeds ----
		var _land = 0;
		for (var _i = 0; _i < _n; _i++) if (_el[_i] >= _sea) _land++;
		var _want = clamp(floor(_land / REGION_AREA), 3, REGION_MAX);
		var _seeds = [];
		var _h = function(_s, _k) { return (hash_mix(_s, 40000 + _k) mod 10000) / 10000; };
		var _okl = function(_b, _e, _s) { return _e >= _s && !(_b == 0 || _b == 1 || _b == 11 || _b == 25 || _b == 9 || _b == 10 || _b == 14); };
		// PLAIN GROUND (q298 / q299, his "who starts a country in a volcano"): a seed never sits on a crest, in a crater or a
		// flow, on a cone's mid flank or above (cmask .15 - the foot keeps its grass and may seed an island that is all footprint), nor on the landmark
		var _plain = method({ rl : _rl, vm : _pn[$ "vmask"], cm : _pn[$ "cmask"], sm : _pn[$ "sigmask"] }, function(_i) {
			if (is_array(rl) && rl[_i] > .10) return false;
			if (is_array(vm) && vm[_i] > 0) return false;
			if (is_array(cm) && cm[_i] >= .15) return false;   // (the mid flank and up; the foot may hold the seed of an island that is all one cone's footprint)
			if (is_array(sm) && sm[_i] > 0) return false;
			return true;
		});
		var _rmin = sqrt(REGION_AREA) * .85;
		var _prow = round(_th * TERR_POLE);   // (the polar rows: nobody's - q297)
		// THE LANDMASSES (q297; first since q299 - the seeds ask after them): every land component (four-connected, off the
		// poles) - one with TERR_ISLE_MIN texels or more and no seed on it gets one at its centroid, so no island of size
		// hangs on a stranger across the water; the walk below never crosses the sea, and the small ones join a neighbour
		// whole (after the walk). A VOLCANO ISLET - a landmass half bare cone or more - is nobody's: never seeded, never
		// joined (q299, his report: "that one island is still grabbing part of the volcano")
		var _comp = array_create(_n, -1), _csz = [], _cx = [], _cy = [], _cfirst = [], _cvol = [], _cmk0 = _pn[$ "cmask"];
		for (var _i0 = 0; _i0 < _n; _i0++) {
			if (_comp[_i0] >= 0 || _el[_i0] < _sea) continue;
			var _y0 = _i0 div _tw; if (_y0 < _prow || _y0 >= _th - _prow) continue;
			var _cid = array_length(_csz), _stk = [_i0], _sz = 0, _sx = 0, _sy = 0, _x00 = _i0 mod _tw, _svol = 0;
			_comp[_i0] = _cid;
			while (array_length(_stk) > 0) {
				var _ci = array_pop(_stk), _cxx = _ci mod _tw, _cyy = _ci div _tw;
				_sz++; _sx += ((_cxx - _x00 + _tw + (_tw div 2)) mod _tw) - (_tw div 2); _sy += _cyy;
				if (is_array(_cmk0) && _cmk0[_ci] >= VOLCANO_BARE) _svol++;   // (the bare cone's texels - q299)
				var _cnb4 = [((_cxx + _tw - 1) mod _tw) + _cyy * _tw, ((_cxx + 1) mod _tw) + _cyy * _tw, (_cyy > 0) ? _ci - _tw : -1, (_cyy < _th - 1) ? _ci + _tw : -1];
				for (var _cq = 0; _cq < 4; _cq++) {
					var _cj = _cnb4[_cq]; if (_cj < 0 || _comp[_cj] >= 0 || _el[_cj] < _sea) continue;
					var _cjy = _cj div _tw; if (_cjy < _prow || _cjy >= _th - _prow) continue;
					_comp[_cj] = _cid; array_push(_stk, _cj);
				}
			}
			array_push(_csz, _sz); array_push(_cx, (((_x00 + round(_sx / _sz)) mod _tw) + _tw) mod _tw); array_push(_cy, clamp(round(_sy / _sz), 0, _th - 1)); array_push(_cfirst, _i0); array_push(_cvol, _svol >= _sz * .5);   // (half bare cone or more: a volcano islet)
		}
		// ---- the seeds: the gate on green off the poles, the rest poisson-spread - plain ground, never a volcano islet ----
		for (var _t = 0; _t < 240 && array_length(_seeds) == 0; _t++) {
			var _x = floor(_h(_pn.seed, _t * 2) * _tw), _y = floor((.18 + .64 * _h(_pn.seed, _t * 2 + 1)) * _th), _i = _x + _y * _tw, _b = _bm[_i];
			if (!_okl(_b, _el[_i], _sea) || !_plain(_i) || _comp[_i] < 0 || _cvol[_comp[_i]]) continue;
			if (_t < 140 && !(_b == 4 || _b == 5 || _b == 6 || _b == 21 || _b == 22)) continue;   // (the gate is green while it can be)
			array_push(_seeds, [_x, _y]);
		}
		if (array_length(_seeds) == 0) for (var _i = 0; _i < _n && array_length(_seeds) == 0; _i++) if (_el[_i] >= _sea) array_push(_seeds, [_i mod _tw, _i div _tw]);
		if (array_length(_seeds) == 0) { _pn.terr = { n : 0, ids : [], seeds : [], area : [], adj : [], ring : [], lv : [] }; return true; }   // (a world with no land at all)
		for (var _t = 0; _t < _want * 40 && array_length(_seeds) < _want; _t++) {
			var _x = floor(_h(_pn.seed, 1000 + _t * 2) * _tw), _y = floor((TERR_POLE + .02 + (1 - 2 * (TERR_POLE + .02)) * _h(_pn.seed, 1001 + _t * 2)) * _th), _i = _x + _y * _tw;
			if (!_okl(_bm[_i], _el[_i], _sea) || !_plain(_i) || _comp[_i] < 0 || _cvol[_comp[_i]]) continue;
			var _cl = max(.2, sin(pi * (_y + .5) / _th)), _ok = true;
			for (var _k = 0; _k < array_length(_seeds) && _ok; _k++) {
				var _dx = abs(_x - _seeds[_k][0]); _dx = min(_dx, _tw - _dx);
				if (sqrt(sqr(_dx * _cl) + sqr(_y - _seeds[_k][1])) < _rmin) _ok = false;
			}
			if (_ok) array_push(_seeds, [_x, _y]);
		}
		var _cseed = array_create(array_length(_csz), false);
		for (var _ck = 0; _ck < array_length(_seeds); _ck++) { var _sc0 = _comp[_seeds[_ck][0] + _seeds[_ck][1] * _tw]; if (_sc0 >= 0) _cseed[_sc0] = true; }
		for (var _c0 = 0; _c0 < array_length(_csz); _c0++) {
			if (_cseed[_c0] || _cvol[_c0] || _csz[_c0] < TERR_ISLE_MIN || array_length(_seeds) >= REGION_MAX) continue;
			// the texel of the component nearest its centroid (the centroid itself may be a lake or a bay) - plain ground (q298 / q299)
			var _cbi = -1, _cbd = 1000000;
			for (var _i1 = 0; _i1 < _n; _i1++) {
				if (_comp[_i1] != _c0) continue;
				if (!_okl(_bm[_i1], _el[_i1], _sea) || !_plain(_i1)) continue;
				var _dx1 = abs((_i1 mod _tw) - _cx[_c0]); _dx1 = min(_dx1, _tw - _dx1);
				var _dd1 = sqr(_dx1) + sqr((_i1 div _tw) - _cy[_c0]);
				if (_dd1 < _cbd) { _cbd = _dd1; _cbi = _i1; }
			}
			if (_cbi >= 0) { array_push(_seeds, [_cbi mod _tw, _cbi div _tw]); _cseed[_c0] = true; }
		}
		// ---- the walk's state: dial's buckets on integer costs ----
		var _dist = array_create(_n, 1000000), _own = array_create(_n, 0), _bk = array_create(TERR_CMAX + 1, -1);
		_bk[0] = [];
		for (var _k = 0; _k < array_length(_seeds); _k++) { var _i = _seeds[_k][0] + _seeds[_k][1] * _tw; _dist[_i] = 0; _own[_i] = _k + 1; array_push(_bk[0], _i); }
		_st = { seeds : _seeds, dist : _dist, own : _own, bk : _bk, c : 0, land : _land, comp : _comp, csz : _csz, cseed : _cseed, cvol : _cvol, prow : _prow };
		_pn.terr_st = _st;
	}
	// ---- the walk, sliced ----
	var _ds = _st.dist, _ow = _st.own, _bq = _st.bk, _c = _st.c, _prw = _st.prow;
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
					var _ny = _y + _oy[_k]; if (_ny < _prw || _ny >= _th - _prw) continue;   // (never the polar rows - q297)
					var _nx = (_x + _ox[_k] + _tw) mod _tw, _j = _nx + _ny * _tw;
					if (_el[_j] < _sea) continue;   // (never the sea: a region ends at its coast; an island of size has a seed, a small one joins a neighbour after - q297)
					// A DIAGONAL STEP only where an orthogonal one would do (q299): the landmasses are four-connected, and the walk
					// leaked across a strait's corner onto the next island - his "island grabbing part of the volcano"
					if (_k >= 4 && _el[_nx + _y * _tw] < _sea && _el[_x + _ny * _tw] < _sea) continue;
					var _base = (_k < 4) ? ((_ox[_k] != 0) ? 4 * _cl : 4) : sqrt(sqr(4 * _cl) + 16);
					var _m = 1, _b = _bm[_j];
					if (_b == 1 || _b == 11) _m = 5; else if (_b == 9 || _b == 10) _m = 3;   // (a river or a lake five times: the fronts meet at the water - q298)
					else if (_b == 12 || _b == 14) _m = 2;
					if (_m == 1 && is_array(_rl) && _rl[_j] > .06) _m = 3;
					// THE SWELL (q300): the detail field under the step, x .7 .. 1.3 - a slow noise, so two fronts on a plain meander
					// where they meet instead of running the octile bisector dead straight
					if (is_array(_dt)) _m *= .7 + .6 * clamp(_dt[_j], 0, 1);
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
	// ---- done: the islands, the waters, the borders, the neighbours, the rings, the sheet ----
	var _sds = _st.seeds, _nr = array_length(_sds), _cmp = _st.comp, _csz2 = _st.csz, _cseed2 = _st.cseed, _cvol2 = _st.cvol, _prw2 = _st.prow;
	// THE SMALL ISLANDS (q297): a landmass with no seed joins the region owning the nearest owned land within TERR_ISLE_REACH
	// texels of ground - the whole of it to one owner; past that reach it is nobody's (a rock in the deep). A volcano islet
	// never joins (q299)
	for (var _c1 = 0; _c1 < array_length(_csz2); _c1++) {
		if (_cseed2[_c1] || _cvol2[_c1]) continue;
		var _bown = 0, _bdd = 1000000;
		for (var _i2 = 0; _i2 < _n; _i2++) {
			if (_cmp[_i2] != _c1) continue;
			var _x2 = _i2 mod _tw, _y2 = _i2 div _tw, _cl2 = max(.2, sin(pi * (_y2 + .5) / _th));
			for (var _dy2 = -TERR_ISLE_REACH; _dy2 <= TERR_ISLE_REACH; _dy2++) {
				var _yy2 = _y2 + _dy2; if (_yy2 < 0 || _yy2 >= _th) continue;
				for (var _dx2 = -TERR_ISLE_REACH; _dx2 <= TERR_ISLE_REACH; _dx2++) {
					var _j2 = ((_x2 + _dx2 + _tw) mod _tw) + _yy2 * _tw;
					if (_ow[_j2] == 0 || _cmp[_j2] == _c1) continue;
					var _dd2 = sqr(_dx2 * _cl2) + sqr(_dy2);
					if (_dd2 < _bdd) { _bdd = _dd2; _bown = _ow[_j2]; }
				}
			}
		}
		if (_bown > 0) for (var _i3 = 0; _i3 < _n; _i3++) if (_cmp[_i3] == _c1) _ow[_i3] = _bown;
	}
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
	// THE CONES WHOLE (q299; his report: "grabbing part of the volcano"): a volcano's bare cone - its crater and summit, cmask
	// at VOLCANO_BARE and over - belongs to ONE region, the one owning most of it. The fronts meet on the costly flank and
	// split the crater; the border runs round the cone now
	var _cmk = _pn[$ "cmask"];
	if (is_array(_cmk)) {
		var _cseen = array_create(_n, false);
		for (var _i5 = 0; _i5 < _n; _i5++) {
			if (_cseen[_i5] || _el[_i5] < _sea || _cmk[_i5] < VOLCANO_BARE) continue;
			var _stk5 = [_i5], _grp = [], _cnt = array_create(_nr + 1, 0);
			_cseen[_i5] = true;
			while (array_length(_stk5) > 0) {
				var _g5 = array_pop(_stk5); array_push(_grp, _g5); _cnt[_ids[_g5]]++;
				var _x5 = _g5 mod _tw, _y5 = _g5 div _tw;
				var _nb5 = [((_x5 + _tw - 1) mod _tw) + _y5 * _tw, ((_x5 + 1) mod _tw) + _y5 * _tw, (_y5 > 0) ? _g5 - _tw : -1, (_y5 < _th - 1) ? _g5 + _tw : -1];
				for (var _q5 = 0; _q5 < 4; _q5++) { var _j5 = _nb5[_q5]; if (_j5 < 0 || _cseen[_j5] || _el[_j5] < _sea || _cmk[_j5] < VOLCANO_BARE) continue; _cseen[_j5] = true; array_push(_stk5, _j5); }
			}
			var _bo = 0, _bc5 = 0;
			for (var _o5 = 1; _o5 <= _nr; _o5++) if (_cnt[_o5] > _bc5) { _bc5 = _cnt[_o5]; _bo = _o5; }
			if (_bo > 0) for (var _g6 = 0; _g6 < array_length(_grp); _g6++) _ids[_grp[_g6]] = _bo;
		}
	}
	// ONE PIECE A REGION (q300): what the smoothing and the cones cut off a region - a texel or three past a front with no
	// road to the seed over its own land - joins the neighbour it touches most. An islet joined whole (a landmass with no
	// seed of its own) is a piece by design and stays
	var _reach = array_create(_n, false), _stk7 = [];
	for (var _k7 = 0; _k7 < _nr; _k7++) { var _s7 = _sds[_k7][0] + _sds[_k7][1] * _tw; if (_ids[_s7] == _k7 + 1) { _reach[_s7] = true; array_push(_stk7, _s7); } }
	while (array_length(_stk7) > 0) {
		var _g7 = array_pop(_stk7), _x7 = _g7 mod _tw, _y7 = _g7 div _tw, _v7 = _ids[_g7];
		var _nb7 = [((_x7 + _tw - 1) mod _tw) + _y7 * _tw, ((_x7 + 1) mod _tw) + _y7 * _tw, (_y7 > 0) ? _g7 - _tw : -1, (_y7 < _th - 1) ? _g7 + _tw : -1];
		for (var _q7 = 0; _q7 < 4; _q7++) { var _j7 = _nb7[_q7]; if (_j7 < 0 || _reach[_j7] || _el[_j7] < _sea || _ids[_j7] != _v7) continue; _reach[_j7] = true; array_push(_stk7, _j7); }
	}
	for (var _i7 = 0; _i7 < _n; _i7++) {
		if (_reach[_i7] || _el[_i7] < _sea || _ids[_i7] == 0) continue;
		var _c7 = _cmp[_i7]; if (_c7 < 0 || !_cseed2[_c7]) continue;
		var _frag = [_i7], _fh = 0, _cnt7 = array_create(_nr + 1, 0), _v8 = _ids[_i7];
		_reach[_i7] = true;
		while (_fh < array_length(_frag)) {
			var _g8 = _frag[_fh++], _x8 = _g8 mod _tw, _y8 = _g8 div _tw;
			var _nb8 = [((_x8 + _tw - 1) mod _tw) + _y8 * _tw, ((_x8 + 1) mod _tw) + _y8 * _tw, (_y8 > 0) ? _g8 - _tw : -1, (_y8 < _th - 1) ? _g8 + _tw : -1];
			for (var _q8 = 0; _q8 < 4; _q8++) {
				var _j8 = _nb8[_q8]; if (_j8 < 0 || _el[_j8] < _sea) continue;
				if (_ids[_j8] == _v8) { if (!_reach[_j8]) { _reach[_j8] = true; array_push(_frag, _j8); } }
				else if (_ids[_j8] > 0) _cnt7[_ids[_j8]]++;
			}
		}
		var _bo8 = 0, _bc8 = 0;
		for (var _o8 = 1; _o8 <= _nr; _o8++) if (_cnt7[_o8] > _bc8) { _bc8 = _cnt7[_o8]; _bo8 = _o8; }
		if (_bo8 > 0) for (var _f8 = 0; _f8 < array_length(_frag); _f8++) _ids[_frag[_f8]] = _bo8;
	}
	// THE COLOURS (q296, his ask: "a seeded region colour"): a hue a region, hashed off the world and its index - the sheet's
	// green carries it to the shader, region_col hands the same colour to the pages
	var _hue = array_create(_nr, 0);
	for (var _k = 0; _k < _nr; _k++) _hue[_k] = hash_mix(_pn.seed, 7000 + _k) mod 256;
	var _adj = array_create(_nr * _nr, false), _area = array_create(_nr, 0), _bord = array_create(_n, 0);
	// THE NAMES (q298, his report: two "green country"s): dealt here from the ground a territory mostly is, unique in the world
	static _lwords = ["field", "forest", "hills", "marsh", "desert", "mountains", "coast", "tundra", "isle"];
	var _landword = function(_b) {
		switch (_b) {
			case 4: case 21: return 0;
			case 5: case 6: case 22: return 1;
			case 23: case 15: case 16: case 17: return 2;
			case 12: return 3;
			case 3: case 13: case 24: return 4;
			case 9: case 10: case 18: return 5;
			case 2: return 6;
			case 7: case 8: case 14: return 7;
		}
		return -1;
	};
	var _tally = array_create(_nr * 9, 0);
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
		if (_el[_i] >= _sea) { _area[_a - 1]++; var _lw0 = _landword(_bm[_i]); if (_lw0 >= 0) _tally[(_a - 1) * 9 + _lw0]++; }   // (the ground it mostly is, for its name - q298)
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
	var _names = array_create(_nr, ""), _rs0 = random_get_seed();
	for (var _k = 0; _k < _nr; _k++) {
		var _bw = 0, _bc = -1;
		for (var _w = 0; _w < 9; _w++) if (_tally[_k * 9 + _w] > _bc) { _bc = _tally[_k * 9 + _w]; _bw = _w; }
		random_set_seed((_pn.seed ^ (8100 + _k * 7919)) & $7fffffff);
		var _nm = "";
		for (var _try = 0; _try < 8; _try++) {
			_nm = region_title(_lwords[_bw]);
			var _dup = false;
			for (var _q = 0; _q < _k; _q++) if (_names[_q] == _nm) _dup = true;
			if (!_dup) break;
		}
		_names[_k] = _nm;
	}
	rng_release(_rs0);
	var _ring = array_create(_nr, -1); _ring[0] = 0;
	var _qq = [0], _qh = 0;
	while (_qh < array_length(_qq)) { var _a = _qq[_qh++]; for (var _b3 = 0; _b3 < _nr; _b3++) if (_adj[_a * _nr + _b3] && _ring[_b3] < 0) { _ring[_b3] = _ring[_a] + 1; array_push(_qq, _b3); } }
	var _lv = array_create(_nr, 0);
	for (var _k = 0; _k < _nr; _k++) _lv[_k] = (_ring[_k] < 0) ? 8 : min(8, round(_ring[_k] * 1.5));
	var _rb = buffer_create(_n * 4, buffer_fixed, 1), _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
	// (the sheet: red the id, green the region's hue, blue the SEA (255) or the CAP (160) - the fronts count the sea as
	// everyone's and the cap as nobody's (q300), alpha the COASTAL flag: a beach, or any land texel on the sea that is not a
	// river's or a lake's - its drawn water is the sea's, so the line hugs a rock coast as it does a beach; never 0 - q298 / q300)
	for (var _i = 0; _i < _n; _i++) {
		var _o = _i * 4, _xs = _i mod _tw, _ys = _i div _tw, _lnd = (_el[_i] >= _sea);
		var _cst = _lnd && (_el[((_xs + _tw - 1) mod _tw) + _ys * _tw] < _sea || _el[((_xs + 1) mod _tw) + _ys * _tw] < _sea || (_ys > 0 && _el[_i - _tw] < _sea) || (_ys < _th - 1 && _el[_i + _tw] < _sea));
		buffer_poke(_rb, _o + _or, buffer_u8, _ids[_i]);
		buffer_poke(_rb, _o + _og, buffer_u8, (_ids[_i] > 0) ? _hue[_ids[_i] - 1] : 0);
		buffer_poke(_rb, _o + _ob, buffer_u8, (!_lnd) ? 255 : ((_ys < _prw2 || _ys >= _th - _prw2) ? 160 : 0));
		buffer_poke(_rb, _o + _oa, buffer_u8, (_bm[_i] == 2 || (_cst && _bm[_i] != 1 && _bm[_i] != 11)) ? 255 : 128);
	}
	if (buffer_exists(_pn[$ "rbuf"] ?? -1)) buffer_delete(_pn.rbuf);
	_pn.rbuf = _rb; _pn.rsurf = -1;
	_pn.terr = { n : _nr, ids : _ids, seeds : _sds, area : _area, adj : _adj, ring : _ring, lv : _lv, cross : _cross, hue : _hue, names : _names };
	_pn.terr_st = undefined;
	return true;
}
