/// @description planet_gully(pn, u, v, lift) -> the GULLIES' height term at a map coordinate (elevation units, about zero): fine ridges and channels down every range's flank
/// THE GULLIES (his ask, 2026-09-17: "every range to have continuous tiny
/// branches"): a RIDGED value noise on the sphere, three octaves - cells of
/// two texels, one, and a half - whose crests are countless small connected ridges with
/// channels between, masked by the range skeleton's lift so plains stay
/// smooth and every spur carries them. INTO THE HEIGHTS (planet_ranges
/// adds it to pn.elev under every lift and re-runs the biome law): the
/// crests reach the peaks' line, so a range's crown is a spiky, branching
/// thing of rock and snow, and the drainage runs down the channels. (The
/// first cut was height-texture only, a whisper in the shading - "not
/// noticeable... the same noodle look", his report.) Hashed off the seed
function planet_gully(_pn, _u, _v, _lift) {
	if (_lift <= 0) return 0;
	var _m = clamp(_lift / .06, 0, 1);
	var _s = _pn.seed;
	// three octaves of 3d value noise ON THE SPHERE (a lattice in the map's own u / v streaked radially at the poles,
	// where a texel is a sliver - his screenshot, 2026-09-17), each folded into ridges; a cell is about two texels
	// at the equator (freq 25 a radius), then one, then a half. The lattice is offset by a hundred so no index is negative
	var _sl = sin(_v * pi), _px = _sl * cos(_u * 2 * pi), _py = cos(_v * pi), _pz = _sl * sin(_u * 2 * pi);
	var _g = 0, _amp = .5, _f = 25 * (_pn.tw / 320);
	repeat (3) {
		var _x = _px * _f + 100, _y = _py * _f + 100, _z = _pz * _f + 100;
		var _ix = floor(_x), _iy = floor(_y), _iz = floor(_z), _tx = _x - _ix, _ty = _y - _iy, _tz = _z - _iz;
		_tx = _tx * _tx * (3 - 2 * _tx); _ty = _ty * _ty * (3 - 2 * _ty); _tz = _tz * _tz * (3 - 2 * _tz);
		var _c00 = lerp(planet_gully_h(_ix, _iy, _iz * 977 + _s), planet_gully_h(_ix + 1, _iy, _iz * 977 + _s), _tx);
		var _c10 = lerp(planet_gully_h(_ix, _iy + 1, _iz * 977 + _s), planet_gully_h(_ix + 1, _iy + 1, _iz * 977 + _s), _tx);
		var _c01 = lerp(planet_gully_h(_ix, _iy, (_iz + 1) * 977 + _s), planet_gully_h(_ix + 1, _iy, (_iz + 1) * 977 + _s), _tx);
		var _c11 = lerp(planet_gully_h(_ix, _iy + 1, (_iz + 1) * 977 + _s), planet_gully_h(_ix + 1, _iy + 1, (_iz + 1) * 977 + _s), _tx);
		var _n = lerp(lerp(_c00, _c10, _ty), lerp(_c01, _c11, _ty), _tz);
		_g += (1 - abs(2 * _n - 1)) * _amp;   // (ridged: the crests are the lattice's middle crossings - lines)
		_amp = (_amp > .4) ? .3 : .2; _f *= 2; _s += 7919;
	}
	return (_g - .45) * .17 * _m;
}
