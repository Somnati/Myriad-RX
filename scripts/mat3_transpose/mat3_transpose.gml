/// @description mat3_transpose(m);
/// @param m
/// transpose of a row-major 3x3. for pure rotations this IS the
/// inverse, which is how the planet picker undoes the render rotation
function mat3_transpose(_m) {

	return [
		_m[0], _m[3], _m[6],
		_m[1], _m[4], _m[7],
		_m[2], _m[5], _m[8],
	];
}
