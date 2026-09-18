/// @description planet_gully_h(x, y, s) -> 0..1, the gullies' lattice hash (small and exact: every product under 2^53)
function planet_gully_h(_x, _y, _s) {
	var _h = ((_x * 73856093) ^ (_y * 19349663) ^ ((_s mod 1000003) * 83492791)) & $7fffffff;
	_h = ((_h ^ (_h >> 13)) * 48271) mod 2147483647;
	_h = ((_h ^ (_h >> 7)) * 2654435) mod 2147483647;
	return (_h mod 10000) / 10000;
}
