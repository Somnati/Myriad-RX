/// @description mat3_mul(a, b);
/// @param a
/// @param b
/// 3x3 matrix product a*b (row-major 9-arrays): apply b first, then a
function mat3_mul(_a, _b) {

	var _o = array_create(9);
	for (var _r = 0; _r < 3; _r++)
	for (var _c = 0; _c < 3; _c++) {
		_o[_r * 3 + _c] =
			  _a[_r * 3]     * _b[_c]
			+ _a[_r * 3 + 1] * _b[3 + _c]
			+ _a[_r * 3 + 2] * _b[6 + _c];
	}
	return _o;
}
