/// @description planet_vn3(seed, u, v, freq) -> 0..1: one octave of 3d value noise ON THE SPHERE at the map point u / v (a lattice in the map's own u / v streaks at the poles; this one is even everywhere), freq cells a radius
/// The gullies' noise (planet_gully) made general (q207): the coasts, the
/// dunes and the plateaus read it. Hashed by planet_gully_h; the lattice is
/// offset by a hundred so no index is negative
function planet_vn3(_seed, _u, _v, _f) {
	var _sl = sin(_v * pi);
	var _x = _sl * cos(_u * 2 * pi) * _f + 100, _y = cos(_v * pi) * _f + 100, _z = _sl * sin(_u * 2 * pi) * _f + 100;
	var _ix = floor(_x), _iy = floor(_y), _iz = floor(_z), _tx = _x - _ix, _ty = _y - _iy, _tz = _z - _iz;
	_tx = _tx * _tx * (3 - 2 * _tx); _ty = _ty * _ty * (3 - 2 * _ty); _tz = _tz * _tz * (3 - 2 * _tz);
	var _c00 = lerp(planet_gully_h(_ix, _iy, _iz * 977 + _seed), planet_gully_h(_ix + 1, _iy, _iz * 977 + _seed), _tx);
	var _c10 = lerp(planet_gully_h(_ix, _iy + 1, _iz * 977 + _seed), planet_gully_h(_ix + 1, _iy + 1, _iz * 977 + _seed), _tx);
	var _c01 = lerp(planet_gully_h(_ix, _iy, (_iz + 1) * 977 + _seed), planet_gully_h(_ix + 1, _iy, (_iz + 1) * 977 + _seed), _tx);
	var _c11 = lerp(planet_gully_h(_ix, _iy + 1, (_iz + 1) * 977 + _seed), planet_gully_h(_ix + 1, _iy + 1, (_iz + 1) * 977 + _seed), _tx);
	return lerp(lerp(_c00, _c10, _ty), lerp(_c01, _c11, _ty), _tz);
}
