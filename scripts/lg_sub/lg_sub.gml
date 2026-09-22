/// @description lg_sub(a, b) -> log10(10^a - 10^b), a >= b; spending everything lands on the COLL_LZ zero sentinel, never log10(0)
function lg_sub(_a, _b) {
	var _r = power(10, _b - _a);
	if (_r >= 1) return COLL_LZ;
	return _a + log10(1 - _r);
}
