/// @description hash_mix(a, b) -> 0..2^31-1, a small exact hash of two integers
/// Every product stays under 2^53, so a double carries it exactly (the
/// weather's first hash multiplied past that and lost its low bits: two
/// slots read the same). The region's words (region_info) and the sky
/// (region_weather) pick by it.
function hash_mix(_a, _b) {
	var _h = ((floor(_a) & $7fffffff) ^ (((floor(_b) & $7fffffff) * 40503) & $7fffffff)) & $7fffffff;
	_h = (_h * 48271) mod 2147483647;
	_h = ((_h ^ (_h >> 11)) * 2654435) mod 2147483647;
	_h = ((_h ^ (_h >> 7)) * 48271) mod 2147483647;
	return _h;
}
