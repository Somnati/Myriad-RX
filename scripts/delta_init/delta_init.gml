/// @description delta_init([force]) -> g.alluv (the frame macro owns the name delta): ALLUVIUM's whole state (q314) - the heightfield, the silt, the wet, the crops, the marks, the ledger; the terrain grown fresh off a seed when there is none (or force)
/// THE LAND: a slope from the mountains (top) to the sea (bottom) under
/// two octaves of value noise, a shallow valley down the middle to lead
/// the first river, the coast where the slope meets sea level. The spring
/// sits at the top of the valley. Everything the player does from here is
/// water.
function delta_init(_force = false) {
	if (!_force && variable_global_exists("alluv") && is_struct(g.alluv)) return g.alluv;
	var _w = DELTA_W, _h = DELTA_H, _n = _w * _h;
	var _seed = irandom($7fffffff);
	var _d = {
		w : _w, h : _h, sea : DELTA_SEA, seedid : _seed,
		hgt : array_create(_n, 0), silt : array_create(_n, 0), wet : array_create(_n, 0), crop : array_create(_n, 0), lev : array_create(_n, 0), sea0 : array_create(_n, false),
		grain : 25, life : 0, valley : 1,   // (the valley: the prestige - each one settled adds a quarter to every harvest after; kept across the move)
		rain : 1, springs : 1, rich : 1, seed : 0, nlev : 0, nchan : 0, floods : 0,
		flood_t : DELTA_FLOOD_EVERY, flood : 0,
		harvests : 0, silted : 0,
		last : universal_now(), acc : 0,
		drops : [], rate : 0, rate_acc : 0, rate_t : 0,   // (the sparks, and the grain-a-second readout - not saved)
	};
	// the terrain
	var _vn = function(_x, _y, _s, _salt) {   // value noise on a lattice of s cells, smoothstepped
		var _cx = floor(_x / _s), _cy = floor(_y / _s), _fx = (_x / _s) - _cx, _fy = (_y / _s) - _cy;
		_fx = _fx * _fx * (3 - 2 * _fx); _fy = _fy * _fy * (3 - 2 * _fy);
		var _h = function(_a, _b, _slt) { return (hash_mix(_a * 73 + _b * 151, _slt) mod 10000) / 10000; };
		return lerp(lerp(_h(_cx, _cy, _salt), _h(_cx + 1, _cy, _salt), _fx), lerp(_h(_cx, _cy + 1, _salt), _h(_cx + 1, _cy + 1, _salt), _fx), _fy);
	};
	var _cx0 = _w * .5;
	for (var _y = 0; _y < _h; _y++) for (var _x = 0; _x < _w; _x++) {
		var _t = _y / (_h - 1);
		var _base = lerp(.92, -.02, _t);   // (the far sea deep: the delta takes hours to reach it - the twin)
		var _nz = (_vn(_x, _y, 9, _seed) - .5) * .16 + (_vn(_x, _y, 4, _seed + 7) - .5) * .06;
		var _val = .07 * exp(-sqr((_x - _cx0 + 6 * (_vn(0, _y, 12, _seed + 3) - .5)) / 5));   // (the valley wanders a little)
		var _hv = clamp(_base + _nz - _val, -.06, 1);
		_d.hgt[_x + _y * _w] = _hv;
		_d.sea0[_x + _y * _w] = (_hv < DELTA_SEA);
	}
	g.alluv = _d;
	return _d;
}
