/// @description planet_rivers(pn) - RIVERS (2026-09-16): a dozen-odd channels traced from high ground down the steepest slope to the sea, one texel wide, set into the biome map as shallows (the shallows' colour, water to the glint)
/// Once a world, before its bake (planet_bake); hashed off the seed so it
/// is the same rivers on every load. A source is a high land texel (well
/// above the sea); the channel follows the lowest of its eight
/// neighbours (the map wraps east-west) until it meets water, a pit, or
/// four hundred steps. Gas worlds and dry worlds have none.
function planet_rivers(_pn) {
	if (_pn[$ "rivers"] ?? false) return;
	_pn.rivers = true;
	if (_pn.kind == "gas" || _pn.sea <= 0) return;
	var _tw = _pn.tw, _th = _pn.th, _sea = _pn.sea;
	var _nriv = 10 + (hash_mix(_pn.seed, 5151) mod 9);
	var _hi = _sea + .38 * (1 - _sea);
	for (var _r = 0; _r < _nriv; _r++) {
		// the source: a high land texel, up to sixty tries
		var _sx = -1, _sy = -1;
		for (var _t = 0; _t < 60 && _sx < 0; _t++) {
			var _cx = hash_mix(_pn.seed, 7000 + _r * 131 + _t * 2) mod _tw, _cy = 8 + (hash_mix(_pn.seed, 7001 + _r * 131 + _t * 2) mod max(1, _th - 16));
			var _ci = _cx + _cy * _tw;
			var _cb = _pn.biome[_ci];
			if (_pn.elev[_ci] >= _hi && _cb != 0 && _cb != 1 && _cb != 11) { _sx = _cx; _sy = _cy; }
		}
		if (_sx < 0) continue;
		var _x = _sx, _y = _sy, _steps = 0;
		while (_steps < 400) {
			_steps += 1;
			var _cur = _pn.elev[_x + _y * _tw], _bx = -1, _by = -1, _bv = _cur;
			for (var _dy = -1; _dy <= 1; _dy++) for (var _dx = -1; _dx <= 1; _dx++) {
				if (_dx == 0 && _dy == 0) continue;
				var _nx = (_x + _dx + _tw) mod _tw, _ny = _y + _dy;
				if (_ny < 0 || _ny >= _th) continue;
				var _nv = _pn.elev[_nx + _ny * _tw];
				if (_nv < _bv) { _bv = _nv; _bx = _nx; _by = _ny; }
			}
			if (_bx < 0) break;                           // a pit: the river ends in a lake nobody drew
			_x = _bx; _y = _by;
			var _bi = _x + _y * _tw, _b = _pn.biome[_bi];
			if (_b == 0 || _b == 1 || _b == 11) break;    // the sea (or another river)
			_pn.biome[_bi] = 11;                          // the channel: shallows
		}
	}
}
