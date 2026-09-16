/// @description galaxy_nebulae() -> the galaxy's nebulae, [{ x, y, r, col, col2, seed, dn }] (cached a galaxy)
/// THE NEBULAE ARE THINGS (2026-09-16, after his screenshots: the coloured
/// clouds he meant were the sky's three hashed patches, round ones; the
/// map's haze was never them). A few dozen a galaxy, bred where the stars
/// cluster (the blurred density grid weights the pick, a hash of the seed
/// and the cell decides - nothing rolled, nothing saved), each with a
/// radius in plane px, two colours off a vivid palette and its own shape
/// seed. The map draws them where they are (sh_nebula); every star's sky
/// draws the ones in reach at their bearings, sized by their distance
/// (galaxy_sky_build / galaxy_sky_draw).
function galaxy_nebulae() {
	static _list = [];
	static _seed = -1;
	var _sm = starmap_get();
	if (_seed == _sm.seed) return _list;
	var _cfg = starmap_config();
	var _ngw = _sm.ngw, _out = [];
	var _pal = [ rgb(255, 96, 150), rgb(84, 230, 220), rgb(160, 110, 255), rgb(255, 150, 60), rgb(96, 255, 170), rgb(230, 84, 255), rgb(90, 140, 255), rgb(255, 210, 90) ];
	var _want = _cfg[$ "neb_count"] ?? 44, _apart = _cfg[$ "neb_apart"] ?? 260;
	// every cell with stars in it is a candidate, scored by its density and a hash - the dense cells win
	var _cand = [];
	for (var _i = 0; _i < _ngw * _ngw; _i++) {
		var _dn = _sm.ngrid[_i] / max(1, _sm.nmax);
		if (_dn < .05) continue;
		var _h = hash_mix(_sm.seed, _i);
		array_push(_cand, { i : _i, dn : _dn, h : _h, score : power(_dn, .6) * (.35 + .65 * ((_h mod 10000) / 10000)) });
	}
	array_sort(_cand, function(_a, _b) { return (_b.score > _a.score) ? 1 : ((_b.score < _a.score) ? -1 : 0); });
	for (var _k = 0; _k < array_length(_cand) && array_length(_out) < _want; _k++) {
		var _c = _cand[_k], _cx = _c.i mod _ngw, _cy = _c.i div _ngw;
		var _h2 = hash_mix(_c.h, 7), _h3 = hash_mix(_c.h, 13), _h4 = hash_mix(_c.h, 19);
		var _x = (_cx + .5 + ((_h2 mod 1000) / 1000 - .5) * .9) * _sm.ncell;
		var _y = (_cy + .5 + ((_h3 mod 1000) / 1000 - .5) * .9) * _sm.ncell;
		// apart from the ones already placed (two on neighbouring cells would be one cloud twice)
		var _near = false;
		for (var _j = 0; _j < array_length(_out) && !_near; _j++) if (point_distance(_x, _y, _out[_j].x, _out[_j].y) < _apart) _near = true;
		if (_near) continue;
		var _r = (_cfg[$ "neb_r_min"] ?? 90) + _c.dn * (_cfg[$ "neb_r_dn"] ?? 220) + ((_h4 mod 1000) / 1000) * (_cfg[$ "neb_r_rand"] ?? 120);
		var _np = array_length(_pal), _pi = _h2 mod _np, _pj = (_pi + 1 + (_h3 mod (_np - 1))) mod _np;
		array_push(_out, { x : _x, y : _y, r : _r, col : _pal[_pi], col2 : _pal[_pj], seed : (_c.h mod 977) * .173, dn : _c.dn });
	}
	_list = _out; _seed = _sm.seed;
	return _list;
}
